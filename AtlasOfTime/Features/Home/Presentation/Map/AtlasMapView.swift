import MapKit
import SwiftUI

struct AtlasMapView: UIViewRepresentable {
    let snapshot: YearSnapshot?

    func makeCoordinator() -> Coordinator {
        Coordinator()
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

        return mapView
    }

    private func configureBaseMap(for mapView: MKMapView) {
        if #available(iOS 16.0, *) {
            let configuration = MKStandardMapConfiguration(elevationStyle: .flat)
            configuration.emphasisStyle = .muted
            configuration.pointOfInterestFilter = .excludingAll
            configuration.elevationStyle = .realistic
            mapView.preferredConfiguration = configuration
        } else {
            mapView.mapType = .mutedStandard
            mapView.pointOfInterestFilter = .excludingAll
        }
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.render(snapshot: snapshot, on: mapView)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        private var lastSnapshotIdentifier: String?

        func render(snapshot: YearSnapshot?, on mapView: MKMapView) {
            let identifier = snapshot.map { "\($0.year)-\($0.polygons.count)" } ?? "nil"
            guard identifier != lastSnapshotIdentifier else { return }

            mapView.removeOverlays(mapView.overlays)

            let overlays = BorderOverlayAdapter.makeOverlays(from: snapshot)
            mapView.addOverlays(overlays)

            fitIfNeeded(overlays: overlays, mapView: mapView)
            lastSnapshotIdentifier = identifier
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polygon = overlay as? MKPolygon else {
                return MKOverlayRenderer(overlay: overlay)
            }
            return BorderOverlayRenderer(polygon: polygon)
        }

        private func fitIfNeeded(overlays: [MKPolygon], mapView: MKMapView) {
            guard !overlays.isEmpty else { return }

            let unionRect = overlays
                .map(\.boundingMapRect)
                .reduce(MKMapRect.null) { current, next in
                    current.isNull ? next : current.union(next)
                }

            guard !unionRect.isNull, !unionRect.isEmpty else { return }

            mapView.setVisibleMapRect(
                unionRect,
                edgePadding: UIEdgeInsets(top: 24, left: 16, bottom: 180, right: 16),
                animated: false
            )
        }
    }
}
