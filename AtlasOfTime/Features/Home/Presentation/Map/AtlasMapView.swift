import MapKit
import SwiftUI

struct AtlasMapView: UIViewRepresentable {
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

            let overlays = BorderOverlayAdapter.makeOverlays(from: snapshot)
            mapView.addOverlays(overlays)
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
    }
}
