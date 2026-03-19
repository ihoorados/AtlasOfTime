import MapKit
import SwiftUI

struct AtlasMapView: UIViewRepresentable {
    private static let countryLabelReuseIdentifier = "AtlasCountryLabel"

    let snapshot: YearSnapshot?
    let selectedCountryID: String?
    let onCountrySelectionChanged: (String?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onCountrySelectionChanged: onCountrySelectionChanged)
    }

    func makeUIView(context: Context) -> MKMapView {
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

        let initialRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 150, longitudeDelta: 360)
        )
        mapView.setRegion(initialRegion, animated: false)
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
        tapGesture.cancelsTouchesInView = false
        mapView.addGestureRecognizer(tapGesture)
        context.coordinator.mapView = mapView

        return mapView
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

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.render(
            snapshot: snapshot,
            selectedCountryID: selectedCountryID,
            on: mapView
        )
    }

    final class CountryLabelAnnotation: NSObject, MKAnnotation {
        let countryID: String
        let countryName: String
        let coordinate: CLLocationCoordinate2D

        init(
            countryID: String,
            countryName: String,
            coordinate: CLLocationCoordinate2D
        ) {
            self.countryID = countryID
            self.countryName = countryName
            self.coordinate = coordinate
        }

        var title: String? {
            countryName
        }
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        private var lastSnapshotIdentifier: String?
        private var selectedCountryID: String?
        weak var mapView: MKMapView?
        private let onCountrySelectionChanged: (String?) -> Void

        init(onCountrySelectionChanged: @escaping (String?) -> Void) {
            self.onCountrySelectionChanged = onCountrySelectionChanged
        }

        func render(snapshot: YearSnapshot?, selectedCountryID: String?, on mapView: MKMapView) {
            self.selectedCountryID = selectedCountryID
            let identifier = snapshot.map { "\($0.year)-\($0.polygons.count)-\(selectedCountryID ?? "none")" } ?? "nil"
            guard identifier != lastSnapshotIdentifier else { return }

            mapView.removeOverlays(mapView.overlays)
            mapView.removeAnnotations(mapView.annotations.filter { $0 is CountryLabelAnnotation })

            let overlays = BorderOverlayAdapter.makeOverlays(from: snapshot)
            let annotations = BorderOverlayAdapter.makeCountryLabelPoints(from: snapshot).map(makeCountryLabelAnnotation)
            mapView.addOverlays(overlays)
            mapView.addAnnotations(annotations)
            lastSnapshotIdentifier = identifier
        }

        @objc
        func handleMapTap(_ recognizer: UITapGestureRecognizer) {
            guard let mapView else { return }

            let point = recognizer.location(in: mapView)
            let mapCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let mapPoint = MKMapPoint(mapCoordinate)

            for overlay in mapView.overlays.reversed() {
                guard let polygon = overlay as? MKPolygon,
                      let countryID = polygon.atlasCountryID,
                      let renderer = mapView.renderer(for: polygon) as? MKPolygonRenderer,
                      let path = renderer.path else {
                    continue
                }

                let rendererPoint = renderer.point(for: mapPoint)
                if path.contains(rendererPoint) {
                    onCountrySelectionChanged(countryID == selectedCountryID ? nil : countryID)
                    return
                }
            }

            onCountrySelectionChanged(nil)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polygon = overlay as? MKPolygon else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let isSelected = polygon.atlasCountryID == selectedCountryID
            return BorderOverlayRenderer(polygon: polygon, isSelected: isSelected)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let countryAnnotation = annotation as? CountryLabelAnnotation else {
                return nil
            }
            let isSelected = countryAnnotation.countryID == selectedCountryID

            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: AtlasMapView.countryLabelReuseIdentifier
            ) ?? MKAnnotationView(
                annotation: countryAnnotation,
                reuseIdentifier: AtlasMapView.countryLabelReuseIdentifier
            )

            annotationView.annotation = countryAnnotation
            annotationView.canShowCallout = false
            annotationView.isEnabled = false
            annotationView.centerOffset = CGPoint(x: 0, y: -4)
            annotationView.backgroundColor = isSelected ? selectedAtlasLabelBackgroundColor : atlasLabelBackgroundColor
            annotationView.layer.cornerRadius = 5
            annotationView.layer.borderWidth = isSelected ? 1.0 : 0.75
            annotationView.layer.borderColor = (isSelected ? selectedAtlasLabelBorderColor : atlasLabelBorderColor).cgColor
            annotationView.layer.shadowColor = atlasLabelShadowColor.cgColor
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

            label.text = countryAnnotation.countryName
            label.font = .systemFont(ofSize: isSelected ? 11 : 10.5, weight: isSelected ? .bold : .semibold)
            label.textColor = isSelected ? selectedAtlasLabelTextColor : atlasLabelTextColor
            label.sizeToFit()
            annotationView.frame = label.bounds.insetBy(dx: isSelected ? -7 : -6, dy: isSelected ? -4 : -3)

            return annotationView
        }

        private func makeCountryLabelAnnotation(from point: CountryLabelPoint) -> CountryLabelAnnotation {
            CountryLabelAnnotation(
                countryID: point.countryID,
                countryName: point.countryName,
                coordinate: point.coordinate
            )
        }

        private var atlasLabelTextColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.96, green: 0.92, blue: 0.84, alpha: 0.88)
                }
                return UIColor(red: 0.26, green: 0.20, blue: 0.12, alpha: 0.84)
            }
        }

        private var atlasLabelBackgroundColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.22, green: 0.18, blue: 0.12, alpha: 0.42)
                }
                return UIColor(red: 0.94, green: 0.89, blue: 0.78, alpha: 0.58)
            }
        }

        private var atlasLabelBorderColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.88, green: 0.80, blue: 0.64, alpha: 0.22)
                }
                return UIColor(red: 0.38, green: 0.29, blue: 0.15, alpha: 0.18)
            }
        }

        private var atlasLabelShadowColor: UIColor {
            UIColor.black.withAlphaComponent(0.4)
        }

        private var selectedAtlasLabelTextColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.99, green: 0.96, blue: 0.88, alpha: 0.96)
                }
                return UIColor(red: 0.32, green: 0.20, blue: 0.06, alpha: 0.96)
            }
        }

        private var selectedAtlasLabelBackgroundColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.34, green: 0.25, blue: 0.12, alpha: 0.62)
                }
                return UIColor(red: 0.93, green: 0.82, blue: 0.56, alpha: 0.72)
            }
        }

        private var selectedAtlasLabelBorderColor: UIColor {
            UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.96, green: 0.89, blue: 0.72, alpha: 0.42)
                }
                return UIColor(red: 0.46, green: 0.31, blue: 0.12, alpha: 0.34)
            }
        }
    }
}
