import CoreAtlasMap
import MapKit
import SwiftUI

#if os(iOS)
public struct MapKitAtlasMapView: UIViewRepresentable {
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

    public func makeUIView(context: Context) -> MKMapView {
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

        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleMapTap(_:))
        )
        tapGesture.cancelsTouchesInView = false
        tapGesture.isEnabled = state.options.allowsSelection
        mapView.addGestureRecognizer(tapGesture)
        context.coordinator.mapView = mapView
        context.coordinator.tapGestureRecognizer = tapGesture
        context.coordinator.applyCameraIfNeeded(state.camera, to: mapView, animated: false)

        return mapView
    }

    public func updateUIView(_ mapView: MKMapView, context: Context) {
        applyOptions(state.options, to: mapView)
        context.coordinator.applyCameraIfNeeded(state.camera, to: mapView, animated: false)
        context.coordinator.tapGestureRecognizer?.isEnabled = state.options.allowsSelection
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
        if #available(iOS 16.0, *) {
            let configuration = MKStandardMapConfiguration(elevationStyle: .flat)
            configuration.emphasisStyle = .muted
            configuration.pointOfInterestFilter = .excludingAll
            mapView.preferredConfiguration = configuration
            if #available(iOS 17.0, *) {
                mapView.selectableMapFeatures = []
            }
        } else {
            mapView.mapType = .mutedStandard
            mapView.pointOfInterestFilter = .excludingAll
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
        weak var tapGestureRecognizer: UITapGestureRecognizer?

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
                    annotation is MapKitFeatureLabelAnnotation || annotation is MapKitPointAnnotation
                }
            )

            let overlays = MapKitFeatureOverlayAdapter.makeOverlays(from: snapshot)
            let labelAnnotations = showsLabels
                ? MapKitFeatureOverlayAdapter.makeLabelPoints(from: snapshot).map(makeMapKitFeatureLabelAnnotation)
                : []
            let pointAnnotations = snapshot?.pointAnnotations.map(MapKitPointAnnotation.init(point:)) ?? []
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
                guard let featureAnnotation = annotation as? MapKitFeatureLabelAnnotation,
                      featureAnnotation.featureID == featureID,
                      let annotationView = mapView.view(for: featureAnnotation) else {
                    continue
                }
                configureMapKitFeatureLabelAnnotationView(
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
                guard let pointAnnotation = annotation as? MapKitPointAnnotation,
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
        func handleMapTap(_ recognizer: UITapGestureRecognizer) {
            guard let mapView else { return }

            let point = recognizer.location(in: mapView)
            let mapCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let mapPoint = MKMapPoint(mapCoordinate)

            if let featureID = mapView.atlasFeatureID(containing: mapPoint) {
                onSelectionChanged(featureID == selectedFeatureID ? nil : featureID)
                onPointAnnotationSelectionChanged(nil)
                return
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
            if let pointAnnotation = annotation as? MapKitPointAnnotation {
                return makePointAnnotationView(for: pointAnnotation, on: mapView)
            }

            guard let featureAnnotation = annotation as? MapKitFeatureLabelAnnotation else {
                return nil
            }
            let isSelected = featureAnnotation.featureID == selectedFeatureID

            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: MapKitAtlasMapView.featureLabelReuseIdentifier
            ) ?? MKAnnotationView(
                annotation: featureAnnotation,
                reuseIdentifier: MapKitAtlasMapView.featureLabelReuseIdentifier
            )

            configureMapKitFeatureLabelAnnotationView(
                annotationView,
                annotation: featureAnnotation,
                isSelected: isSelected
            )

            return annotationView
        }

        private func configureMapKitFeatureLabelAnnotationView(
            _ annotationView: MKAnnotationView,
            annotation featureAnnotation: MapKitFeatureLabelAnnotation,
            isSelected: Bool
        ) {
            annotationView.annotation = featureAnnotation
            annotationView.canShowCallout = false
            annotationView.isEnabled = false
            annotationView.centerOffset = CGPoint(x: 0, y: -4)
            annotationView.backgroundColor = isSelected ? selectedLabelBackgroundColor : labelBackgroundColor
            annotationView.layer.cornerRadius = 5
            annotationView.layer.borderWidth = isSelected ? 1.0 : 0.75
            annotationView.layer.borderColor = (isSelected ? selectedLabelBorderColor : labelBorderColor).cgColor
            annotationView.layer.shadowColor = labelShadowColor.cgColor
            annotationView.layer.shadowOpacity = isSelected ? 0.26 : 0.18
            annotationView.layer.shadowRadius = isSelected ? 4 : 3
            annotationView.layer.shadowOffset = CGSize(width: 0, height: isSelected ? 2 : 1)

            let label: UILabel
            if let existingLabel = annotationView.subviews.first as? UILabel {
                label = existingLabel
            } else {
                label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textAlignment = .center
                label.numberOfLines = 1
                label.backgroundColor = .clear
                label.setContentCompressionResistancePriority(.required, for: .horizontal)
                annotationView.addSubview(label)
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: annotationView.leadingAnchor),
                    label.trailingAnchor.constraint(equalTo: annotationView.trailingAnchor),
                    label.topAnchor.constraint(equalTo: annotationView.topAnchor),
                    label.bottomAnchor.constraint(equalTo: annotationView.bottomAnchor)
                ])
            }

            label.text = featureAnnotation.featureName
            label.font = .systemFont(ofSize: isSelected ? 11 : 10.5, weight: isSelected ? .bold : .semibold)
            label.textColor = isSelected ? selectedLabelTextColor : labelTextColor
            label.sizeToFit()
            annotationView.frame = label.bounds.insetBy(dx: isSelected ? -7 : -6, dy: isSelected ? -4 : -3)
        }

        public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MapKitPointAnnotation else { return }
            onSelectionChanged(nil)
            onPointAnnotationSelectionChanged(
                annotation.pointID == selectedPointAnnotationID ? nil : annotation.pointID
            )
            mapView.deselectAnnotation(annotation, animated: false)
        }

        private func makePointAnnotationView(
            for annotation: MapKitPointAnnotation,
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
            annotation: MapKitPointAnnotation,
            isSelected: Bool
        ) {
            annotationView.annotation = annotation
            annotationView.canShowCallout = false
            annotationView.isEnabled = true
            annotationView.centerOffset = CGPoint(x: 0, y: -11)
            annotationView.bounds = CGRect(x: 0, y: 0, width: isSelected ? 24 : 20, height: isSelected ? 24 : 20)
            annotationView.backgroundColor = .clear
            annotationView.layer.shadowColor = pointShadowColor.cgColor
            annotationView.layer.shadowOpacity = isSelected ? 0.34 : 0.24
            annotationView.layer.shadowRadius = isSelected ? 5 : 4
            annotationView.layer.shadowOffset = CGSize(width: 0, height: 2)

            let marker = pointMarkerView(in: annotationView)
            marker.backgroundColor = isSelected ? selectedPointColor : pointColor
            marker.layer.cornerRadius = isSelected ? 12 : 10
            marker.layer.borderWidth = isSelected ? 3 : 2
            marker.layer.borderColor = pointBorderColor.cgColor
            marker.frame = annotationView.bounds
        }

        private func pointMarkerView(in annotationView: MKAnnotationView) -> UIView {
            if let marker = annotationView.subviews.first(where: { $0.tag == 31_815 }) {
                return marker
            }

            let marker = UIView()
            marker.tag = 31_815
            marker.isUserInteractionEnabled = false
            annotationView.addSubview(marker)
            return marker
        }

        private func makeMapKitFeatureLabelAnnotation(from point: MapKitFeatureLabelPoint) -> MapKitFeatureLabelAnnotation {
            MapKitFeatureLabelAnnotation(
                featureID: point.featureID,
                featureName: point.featureName,
                coordinate: point.coordinate
            )
        }

        private var labelTextColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.96, green: 0.92, blue: 0.84, alpha: 0.88)
                }
                return UIColor(red: 0.26, green: 0.20, blue: 0.12, alpha: 0.84)
            }
        }

        private var labelBackgroundColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.22, green: 0.18, blue: 0.12, alpha: 0.42)
                }
                return UIColor(red: 0.94, green: 0.89, blue: 0.78, alpha: 0.58)
            }
        }

        private var labelBorderColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.88, green: 0.80, blue: 0.64, alpha: 0.22)
                }
                return UIColor(red: 0.38, green: 0.29, blue: 0.15, alpha: 0.18)
            }
        }

        private var labelShadowColor: UIColor {
            UIColor.black.withAlphaComponent(0.4)
        }

        private var selectedLabelTextColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.99, green: 0.96, blue: 0.88, alpha: 0.96)
                }
                return UIColor(red: 0.32, green: 0.20, blue: 0.06, alpha: 0.96)
            }
        }

        private var selectedLabelBackgroundColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.34, green: 0.25, blue: 0.12, alpha: 0.62)
                }
                return UIColor(red: 0.93, green: 0.82, blue: 0.56, alpha: 0.72)
            }
        }

        private var selectedLabelBorderColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.96, green: 0.89, blue: 0.72, alpha: 0.42)
                }
                return UIColor(red: 0.46, green: 0.31, blue: 0.12, alpha: 0.34)
            }
        }

        private var pointColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.83, green: 0.39, blue: 0.21, alpha: 0.92)
                }
                return UIColor(red: 0.70, green: 0.22, blue: 0.12, alpha: 0.92)
            }
        }

        private var selectedPointColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 1.00, green: 0.66, blue: 0.29, alpha: 0.98)
                }
                return UIColor(red: 0.92, green: 0.40, blue: 0.10, alpha: 0.98)
            }
        }

        private var pointBorderColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.12, green: 0.09, blue: 0.06, alpha: 0.94)
                }
                return UIColor(red: 0.98, green: 0.92, blue: 0.78, alpha: 0.96)
            }
        }

        private var pointShadowColor: UIColor {
            UIColor.black.withAlphaComponent(0.5)
        }
    }
}
#endif
