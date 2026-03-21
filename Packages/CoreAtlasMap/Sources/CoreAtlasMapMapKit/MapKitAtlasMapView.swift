import CoreAtlasMap
import MapKit
import SwiftUI

public struct MapKitAtlasMapView: UIViewRepresentable {
    private static let featureLabelReuseIdentifier = "MapKitAtlasFeatureLabel"

    let snapshot: AtlasMapSnapshot?
    let camera: AtlasMapCameraState
    let interaction: AtlasMapInteraction

    public func makeCoordinator() -> Coordinator {
        Coordinator(interaction: interaction)
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
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.setRegion(camera.mkCoordinateRegion, animated: false)

        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleMapTap(_:))
        )
        tapGesture.cancelsTouchesInView = false
        mapView.addGestureRecognizer(tapGesture)
        context.coordinator.mapView = mapView

        return mapView
    }

    public func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.render(
            snapshot: snapshot,
            selectedFeatureID: interaction.selectedFeatureID,
            on: mapView
        )
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

    public final class Coordinator: NSObject, MKMapViewDelegate {
        private var lastRenderIdentifier: String?
        private var selectedFeatureID: String?
        private let interaction: AtlasMapInteraction

        weak var mapView: MKMapView?

        init(interaction: AtlasMapInteraction) {
            self.interaction = interaction
        }

        func render(
            snapshot: AtlasMapSnapshot?,
            selectedFeatureID: String?,
            on mapView: MKMapView
        ) {
            self.selectedFeatureID = selectedFeatureID
            let identifier = renderIdentifier(
                for: snapshot,
                selectedFeatureID: selectedFeatureID
            )
            guard identifier != lastRenderIdentifier else { return }

            mapView.removeOverlays(mapView.overlays)
            mapView.removeAnnotations(mapView.annotations.filter { $0 is FeatureLabelAnnotation })

            let overlays = MapKitFeatureOverlayAdapter.makeOverlays(from: snapshot)
            let annotations = MapKitFeatureOverlayAdapter.makeLabelPoints(from: snapshot).map(makeFeatureLabelAnnotation)
            mapView.addOverlays(overlays)
            mapView.addAnnotations(annotations)
            lastRenderIdentifier = identifier
        }

        @objc
        func handleMapTap(_ recognizer: UITapGestureRecognizer) {
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
                    interaction.onSelectionChanged(featureID == selectedFeatureID ? nil : featureID)
                    return
                }
            }

            interaction.onSelectionChanged(nil)
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

            return annotationView
        }

        private func renderIdentifier(
            for snapshot: AtlasMapSnapshot?,
            selectedFeatureID: String?
        ) -> String {
            guard let snapshot else { return "nil" }
            return "\(snapshot.features.count)-\(snapshot.labels.count)-\(selectedFeatureID ?? "none")"
        }

        private func makeFeatureLabelAnnotation(from point: MapKitFeatureLabelPoint) -> FeatureLabelAnnotation {
            FeatureLabelAnnotation(
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
