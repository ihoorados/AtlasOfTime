import CoreAtlasMap
import MapKit
import SwiftUI

#if os(macOS)
import AppKit

public struct MapKitAtlasMapView: NSViewRepresentable {
    private static let featureLabelReuseIdentifier = "MapKitAtlasFeatureLabel"
    private static let pointAnnotationReuseIdentifier = "MapKitAtlasPointAnnotation"

    let state: AtlasMapViewState
    let onSelectionChanged: @MainActor @Sendable (String?) -> Void
    let onPointAnnotationSelectionChanged: @MainActor @Sendable (String?) -> Void

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onSelectionChanged: onSelectionChanged,
            onPointAnnotationSelectionChanged: onPointAnnotationSelectionChanged
        )
    }

    public func makeNSView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        configureBaseMap(for: mapView)
        mapView.isPitchEnabled = false
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        mapView.showsUserLocation = false
        mapView.isRotateEnabled = false
        applyOptions(state.options, to: mapView)
        mapView.setRegion(state.camera.mkCoordinateRegion, animated: false)

        let clickGesture = NSClickGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleMapClick(_:))
        )
        clickGesture.isEnabled = state.options.allowsSelection
        mapView.addGestureRecognizer(clickGesture)
        context.coordinator.mapView = mapView
        context.coordinator.clickGestureRecognizer = clickGesture
        context.coordinator.applyCameraIfNeeded(state.camera, to: mapView, animated: false)

        return mapView
    }

    public func updateNSView(_ mapView: MKMapView, context: Context) {
        applyOptions(state.options, to: mapView)
        context.coordinator.applyCameraIfNeeded(state.camera, to: mapView, animated: false)
        context.coordinator.clickGestureRecognizer?.isEnabled = state.options.allowsSelection
        context.coordinator.render(
            snapshot: state.snapshot,
            selectedFeatureID: state.selection.selectedFeatureID,
            selectedPointAnnotationID: state.selection.selectedPointAnnotationID,
            showsLabels: state.options.showsLabels,
            on: mapView
        )
    }

    private func applyOptions(_ options: AtlasMapViewOptions, to mapView: MKMapView) {
        mapView.isScrollEnabled = options.allowsPan
        mapView.isZoomEnabled = options.allowsZoom
    }

    private func configureBaseMap(for mapView: MKMapView) {
        let configuration = MKStandardMapConfiguration(elevationStyle: .flat)
        configuration.emphasisStyle = .muted
        configuration.pointOfInterestFilter = .excludingAll
        mapView.preferredConfiguration = configuration
    }

    final class FeatureLabelAnnotation: NSObject, MKAnnotation {
        let featureID: String
        let featureName: String
        let coordinate: CLLocationCoordinate2D

        init(
            featureID: String,
            featureName: String,
            coordinate: CLLocationCoordinate2D
        ) {
            self.featureID = featureID
            self.featureName = featureName
            self.coordinate = coordinate
        }

        var title: String? {
            featureName
        }
    }

    final class PointAnnotation: NSObject, MKAnnotation {
        let pointID: String
        let pointTitle: String
        let pointSubtitle: String?
        let emphasis: AtlasMapPointAnnotation.Emphasis
        let coordinate: CLLocationCoordinate2D

        init(point: AtlasMapPointAnnotation) {
            self.pointID = point.id
            self.pointTitle = point.title
            self.pointSubtitle = point.subtitle
            self.emphasis = point.emphasis
            self.coordinate = CLLocationCoordinate2D(
                latitude: point.coordinate.latitude,
                longitude: point.coordinate.longitude
            )
        }

        var title: String? {
            pointTitle
        }

        var subtitle: String? {
            pointSubtitle
        }
    }

    public final class Coordinator: NSObject, MKMapViewDelegate {
        private var lastSnapshot: AtlasMapSnapshot?
        private var lastShowsLabels: Bool?
        private var lastAppliedCamera: AtlasMapCameraState?
        private var selectedFeatureID: String?
        private var selectedPointAnnotationID: String?
        private let onSelectionChanged: @MainActor @Sendable (String?) -> Void
        private let onPointAnnotationSelectionChanged: @MainActor @Sendable (String?) -> Void

        weak var mapView: MKMapView?
        weak var clickGestureRecognizer: NSClickGestureRecognizer?

        init(
            onSelectionChanged: @escaping @MainActor @Sendable (String?) -> Void,
            onPointAnnotationSelectionChanged: @escaping @MainActor @Sendable (String?) -> Void
        ) {
            self.onSelectionChanged = onSelectionChanged
            self.onPointAnnotationSelectionChanged = onPointAnnotationSelectionChanged
        }

        func applyCameraIfNeeded(
            _ camera: AtlasMapCameraState,
            to mapView: MKMapView,
            animated: Bool
        ) {
            guard camera != lastAppliedCamera else { return }
            mapView.setRegion(camera.mkCoordinateRegion, animated: animated)
            lastAppliedCamera = camera
        }

        func render(
            snapshot: AtlasMapSnapshot?,
            selectedFeatureID: String?,
            selectedPointAnnotationID: String?,
            showsLabels: Bool,
            on mapView: MKMapView
        ) {
            let previousFeatureID = self.selectedFeatureID
            let previousPointAnnotationID = self.selectedPointAnnotationID
            let contentChanged = snapshot != lastSnapshot || showsLabels != lastShowsLabels
            let selectionChanged = previousFeatureID != selectedFeatureID ||
                previousPointAnnotationID != selectedPointAnnotationID

            self.selectedFeatureID = selectedFeatureID
            self.selectedPointAnnotationID = selectedPointAnnotationID

            guard contentChanged else {
                if selectionChanged {
                    refreshSelection(
                        on: mapView,
                        previousFeatureID: previousFeatureID,
                        currentFeatureID: selectedFeatureID,
                        previousPointAnnotationID: previousPointAnnotationID,
                        currentPointAnnotationID: selectedPointAnnotationID
                    )
                }
                return
            }

            mapView.removeOverlays(mapView.overlays)
            mapView.removeAnnotations(
                mapView.annotations.filter { annotation in
                    annotation is FeatureLabelAnnotation || annotation is PointAnnotation
                }
            )

            let overlays = MapKitFeatureOverlayAdapter.makeOverlays(from: snapshot)
            let labelAnnotations = showsLabels
                ? MapKitFeatureOverlayAdapter.makeLabelPoints(from: snapshot).map(makeFeatureLabelAnnotation)
                : []
            let pointAnnotations = snapshot?.pointAnnotations.map(PointAnnotation.init(point:)) ?? []
            mapView.addOverlays(overlays)
            mapView.addAnnotations(labelAnnotations + pointAnnotations)
            lastSnapshot = snapshot
            lastShowsLabels = showsLabels
        }

        private func refreshSelection(
            on mapView: MKMapView,
            previousFeatureID: String?,
            currentFeatureID: String?,
            previousPointAnnotationID: String?,
            currentPointAnnotationID: String?
        ) {
            if previousFeatureID != currentFeatureID {
                refreshFeatureSelection(previousFeatureID, isSelected: false, on: mapView)
                refreshFeatureSelection(currentFeatureID, isSelected: true, on: mapView)
            }

            if previousPointAnnotationID != currentPointAnnotationID {
                refreshPointAnnotationSelection(previousPointAnnotationID, on: mapView)
                refreshPointAnnotationSelection(currentPointAnnotationID, on: mapView)
            }
        }

        private func refreshFeatureSelection(
            _ featureID: String?,
            isSelected: Bool,
            on mapView: MKMapView
        ) {
            guard let featureID else { return }

            for overlay in mapView.overlays {
                guard let polygon = overlay as? MKPolygon,
                      polygon.atlasFeatureID == featureID,
                      let renderer = mapView.renderer(for: polygon) as? MapKitFeatureRenderer else {
                    continue
                }
                renderer.applySelection(isSelected)
            }

            for annotation in mapView.annotations {
                guard let featureAnnotation = annotation as? FeatureLabelAnnotation,
                      featureAnnotation.featureID == featureID,
                      let annotationView = mapView.view(for: featureAnnotation) else {
                    continue
                }
                configureFeatureLabelAnnotationView(
                    annotationView,
                    annotation: featureAnnotation,
                    isSelected: isSelected
                )
            }
        }

        private func refreshPointAnnotationSelection(
            _ pointAnnotationID: String?,
            on mapView: MKMapView
        ) {
            guard let pointAnnotationID else { return }

            for annotation in mapView.annotations {
                guard let pointAnnotation = annotation as? PointAnnotation,
                      pointAnnotation.pointID == pointAnnotationID,
                      let annotationView = mapView.view(for: pointAnnotation) else {
                    continue
                }
                configurePointAnnotationView(
                    annotationView,
                    annotation: pointAnnotation,
                    isSelected: pointAnnotation.pointID == selectedPointAnnotationID
                )
            }
        }

        @objc
        func handleMapClick(_ recognizer: NSClickGestureRecognizer) {
            guard let mapView else { return }

            let point = recognizer.location(in: mapView)
            let mapCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let mapPoint = MKMapPoint(mapCoordinate)

            for overlay in mapView.overlays.reversed() {
                guard let polygon = overlay as? MKPolygon,
                      let featureID = polygon.atlasFeatureID,
                      let renderer = mapView.renderer(for: polygon) as? MKPolygonRenderer,
                      let path = renderer.path else {
                    continue
                }

                let rendererPoint = renderer.point(for: mapPoint)
                if path.contains(rendererPoint) {
                    onSelectionChanged(featureID == selectedFeatureID ? nil : featureID)
                    onPointAnnotationSelectionChanged(nil)
                    return
                }
            }

            onSelectionChanged(nil)
            onPointAnnotationSelectionChanged(nil)
        }

        public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polygon = overlay as? MKPolygon,
                  let style = polygon.atlasFeatureStyle else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let isSelected = polygon.atlasFeatureID == selectedFeatureID
            return MapKitFeatureRenderer(
                polygon: polygon,
                style: style,
                isSelected: isSelected
            )
        }

        public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let pointAnnotation = annotation as? PointAnnotation {
                return makePointAnnotationView(for: pointAnnotation, on: mapView)
            }

            guard let featureAnnotation = annotation as? FeatureLabelAnnotation else {
                return nil
            }

            let isSelected = featureAnnotation.featureID == selectedFeatureID
            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: MapKitAtlasMapView.featureLabelReuseIdentifier
            ) ?? MKAnnotationView(
                annotation: featureAnnotation,
                reuseIdentifier: MapKitAtlasMapView.featureLabelReuseIdentifier
            )

            configureFeatureLabelAnnotationView(
                annotationView,
                annotation: featureAnnotation,
                isSelected: isSelected
            )

            return annotationView
        }

        private func configureFeatureLabelAnnotationView(
            _ annotationView: MKAnnotationView,
            annotation featureAnnotation: FeatureLabelAnnotation,
            isSelected: Bool
        ) {
            annotationView.annotation = featureAnnotation
            annotationView.canShowCallout = false
            annotationView.isEnabled = false
            annotationView.centerOffset = CGPoint(x: 0, y: -4)
            annotationView.wantsLayer = true
            annotationView.layer?.backgroundColor = (isSelected ? selectedLabelBackgroundColor : labelBackgroundColor).cgColor
            annotationView.layer?.cornerRadius = 5
            annotationView.layer?.borderWidth = isSelected ? 1.0 : 0.75
            annotationView.layer?.borderColor = (isSelected ? selectedLabelBorderColor : labelBorderColor).cgColor
            annotationView.shadow = makeShadow(color: labelShadowColor, opacity: isSelected ? 0.26 : 0.18, radius: isSelected ? 4 : 3)

            let label = labelView(in: annotationView)
            label.stringValue = featureAnnotation.featureName
            label.font = .systemFont(ofSize: isSelected ? 11 : 10.5, weight: isSelected ? .bold : .semibold)
            label.textColor = isSelected ? selectedLabelTextColor : labelTextColor
            label.sizeToFit()
            annotationView.frame = label.bounds.insetBy(dx: isSelected ? -7 : -6, dy: isSelected ? -4 : -3)
            label.frame = annotationView.bounds
        }

        public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? PointAnnotation else { return }
            onSelectionChanged(nil)
            onPointAnnotationSelectionChanged(
                annotation.pointID == selectedPointAnnotationID ? nil : annotation.pointID
            )
            mapView.deselectAnnotation(annotation, animated: false)
        }

        private func labelView(in annotationView: MKAnnotationView) -> NSTextField {
            if let label = annotationView.subviews.first(where: { $0.tag == 31_814 }) as? NSTextField {
                return label
            }

            let label = NSTextField(labelWithString: "")
            label.tag = 31_814
            label.alignment = .center
            label.lineBreakMode = .byTruncatingTail
            label.backgroundColor = .clear
            label.isBordered = false
            label.isEditable = false
            label.isSelectable = false
            annotationView.addSubview(label)
            return label
        }

        private func makePointAnnotationView(
            for annotation: PointAnnotation,
            on mapView: MKMapView
        ) -> MKAnnotationView {
            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: MapKitAtlasMapView.pointAnnotationReuseIdentifier
            ) ?? MKAnnotationView(
                annotation: annotation,
                reuseIdentifier: MapKitAtlasMapView.pointAnnotationReuseIdentifier
            )

            let isSelected = annotation.pointID == selectedPointAnnotationID || annotation.emphasis == .selected
            configurePointAnnotationView(
                annotationView,
                annotation: annotation,
                isSelected: isSelected
            )

            return annotationView
        }

        private func configurePointAnnotationView(
            _ annotationView: MKAnnotationView,
            annotation: PointAnnotation,
            isSelected: Bool
        ) {
            annotationView.annotation = annotation
            annotationView.canShowCallout = false
            annotationView.isEnabled = true
            annotationView.centerOffset = CGPoint(x: 0, y: -11)
            annotationView.bounds = CGRect(x: 0, y: 0, width: isSelected ? 24 : 20, height: isSelected ? 24 : 20)
            annotationView.wantsLayer = true
            annotationView.layer?.backgroundColor = NSColor.clear.cgColor
            annotationView.shadow = makeShadow(color: pointShadowColor, opacity: isSelected ? 0.34 : 0.24, radius: isSelected ? 5 : 4)

            let marker = pointMarkerView(in: annotationView)
            marker.wantsLayer = true
            marker.layer?.backgroundColor = (isSelected ? selectedPointColor : pointColor).cgColor
            marker.layer?.cornerRadius = isSelected ? 12 : 10
            marker.layer?.borderWidth = isSelected ? 3 : 2
            marker.layer?.borderColor = pointBorderColor.cgColor
            marker.frame = annotationView.bounds
        }

        private func pointMarkerView(in annotationView: MKAnnotationView) -> NSView {
            let markerIdentifier = NSUserInterfaceItemIdentifier("MapKitAtlasPointMarker")
            if let marker = annotationView.subviews.first(where: { $0.identifier == markerIdentifier }) {
                return marker
            }

            let marker = NSView()
            marker.identifier = markerIdentifier
            annotationView.addSubview(marker)
            return marker
        }

        private func makeShadow(color: NSColor, opacity: Float, radius: CGFloat) -> NSShadow {
            let shadow = NSShadow()
            shadow.shadowColor = color.withAlphaComponent(CGFloat(opacity))
            shadow.shadowBlurRadius = radius
            shadow.shadowOffset = CGSize(width: 0, height: -1)
            return shadow
        }

        private func makeFeatureLabelAnnotation(from point: MapKitFeatureLabelPoint) -> FeatureLabelAnnotation {
            FeatureLabelAnnotation(
                featureID: point.featureID,
                featureName: point.featureName,
                coordinate: point.coordinate
            )
        }

        private var labelTextColor: NSColor {
            NSColor(calibratedRed: 0.26, green: 0.20, blue: 0.12, alpha: 0.84)
        }

        private var labelBackgroundColor: NSColor {
            NSColor(calibratedRed: 0.94, green: 0.89, blue: 0.78, alpha: 0.58)
        }

        private var labelBorderColor: NSColor {
            NSColor(calibratedRed: 0.38, green: 0.29, blue: 0.15, alpha: 0.18)
        }

        private var labelShadowColor: NSColor {
            NSColor.black
        }

        private var selectedLabelTextColor: NSColor {
            NSColor(calibratedRed: 0.32, green: 0.20, blue: 0.06, alpha: 0.96)
        }

        private var selectedLabelBackgroundColor: NSColor {
            NSColor(calibratedRed: 0.93, green: 0.82, blue: 0.56, alpha: 0.72)
        }

        private var selectedLabelBorderColor: NSColor {
            NSColor(calibratedRed: 0.46, green: 0.31, blue: 0.12, alpha: 0.34)
        }

        private var pointColor: NSColor {
            NSColor(calibratedRed: 0.70, green: 0.22, blue: 0.12, alpha: 0.92)
        }

        private var selectedPointColor: NSColor {
            NSColor(calibratedRed: 0.92, green: 0.40, blue: 0.10, alpha: 0.98)
        }

        private var pointBorderColor: NSColor {
            NSColor(calibratedRed: 0.98, green: 0.92, blue: 0.78, alpha: 0.96)
        }

        private var pointShadowColor: NSColor {
            NSColor.black
        }
    }
}

private extension AtlasMapCameraState {
    var mkCoordinateRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: center.latitude,
                longitude: center.longitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: latitudeDelta,
                longitudeDelta: longitudeDelta
            )
        )
    }
}
#endif
