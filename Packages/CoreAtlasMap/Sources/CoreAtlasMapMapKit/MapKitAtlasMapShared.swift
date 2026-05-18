import CoreAtlasMap
import MapKit

final class MapKitFeatureLabelAnnotation: NSObject, MKAnnotation {
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

final class MapKitPointAnnotation: NSObject, MKAnnotation {
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

struct MapKitAtlasRenderIndex {
    let featureOverlaysByID: [String: [MKPolygon]]
    let featureLabelAnnotationsByID: [String: [MapKitFeatureLabelAnnotation]]
    let pointAnnotationsByID: [String: MapKitPointAnnotation]

    init() {
        self.featureOverlaysByID = [:]
        self.featureLabelAnnotationsByID = [:]
        self.pointAnnotationsByID = [:]
    }

    @MainActor
    init(
        overlays: [MKOverlay],
        labelAnnotations: [MapKitFeatureLabelAnnotation],
        pointAnnotations: [MapKitPointAnnotation]
    ) {
        self.featureOverlaysByID = Dictionary(grouping: overlays.compactMap { overlay -> MKPolygon? in
            guard let polygon = overlay as? MKPolygon,
                  polygon.atlasFeatureID != nil else {
                return nil
            }
            return polygon
        }) { polygon in
            polygon.atlasFeatureID ?? ""
        }

        self.featureLabelAnnotationsByID = Dictionary(grouping: labelAnnotations) { annotation in
            annotation.featureID
        }

        self.pointAnnotationsByID = pointAnnotations.reduce(into: [:]) { result, annotation in
            result[annotation.pointID] = annotation
        }
    }
}

extension MKMapView {
    @MainActor
    func atlasFeatureID(containing mapPoint: MKMapPoint) -> String? {
        for overlay in overlays.reversed() {
            guard let polygon = overlay as? MKPolygon,
                  let featureID = polygon.atlasFeatureID,
                  polygon.boundingMapRect.contains(mapPoint),
                  let renderer = renderer(for: polygon) as? MKPolygonRenderer,
                  let path = renderer.path else {
                continue
            }

            let rendererPoint = renderer.point(for: mapPoint)
            if path.contains(rendererPoint) {
                return featureID
            }
        }

        return nil
    }
}

extension AtlasMapCameraState {
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
