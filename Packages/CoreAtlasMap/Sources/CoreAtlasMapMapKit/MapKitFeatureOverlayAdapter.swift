import CoreAtlasMap
import MapKit
import ObjectiveC

enum MapKitFeatureOverlayAdapter {
    @MainActor
    static func makeOverlays(from snapshot: AtlasMapSnapshot?) -> [MKPolygon] {
        guard let snapshot else { return [] }
        return snapshot.features.flatMap { feature in
            feature.polygons.map { polygon in
                makePolygonOverlay(from: polygon, feature: feature)
            }
        }
    }

    static func makeLabelPoints(from snapshot: AtlasMapSnapshot?) -> [MapKitFeatureLabelPoint] {
        guard let snapshot else { return [] }
        return snapshot.labels.map { label in
            MapKitFeatureLabelPoint(
                featureID: label.id,
                featureName: label.title,
                coordinate: CLLocationCoordinate2D(
                    latitude: label.coordinate.latitude,
                    longitude: label.coordinate.longitude
                )
            )
        }
    }

    @MainActor
    private static func makePolygonOverlay(
        from polygon: AtlasMapPolygon,
        feature: AtlasMapFeature
    ) -> MKPolygon {
        var outerCoordinates = polygon.outerRing.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }

        let holes: [MKPolygon] = polygon.holes.map { ring in
            var holeCoordinates = ring.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            }
            return MKPolygon(coordinates: &holeCoordinates, count: holeCoordinates.count)
        }

        let overlay = MKPolygon(
            coordinates: &outerCoordinates,
            count: outerCoordinates.count,
            interiorPolygons: holes.isEmpty ? nil : holes
        )
        overlay.atlasFeatureID = feature.id
        overlay.atlasFeatureName = feature.title
        overlay.atlasFeatureStyle = feature.style
        return overlay
    }
}

struct MapKitFeatureLabelPoint: Equatable, Sendable {
    let featureID: String
    let featureName: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: MapKitFeatureLabelPoint, rhs: MapKitFeatureLabelPoint) -> Bool {
        lhs.featureID == rhs.featureID &&
        lhs.featureName == rhs.featureName &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

@MainActor
private let atlasFeatureIDAssociationKey = UnsafeRawPointer(UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1))
@MainActor
private let atlasFeatureNameAssociationKey = UnsafeRawPointer(UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1))
@MainActor
private let atlasFeatureStyleAssociationKey = UnsafeRawPointer(UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1))

@MainActor
extension MKPolygon {
    var atlasFeatureID: String? {
        get { objc_getAssociatedObject(self, atlasFeatureIDAssociationKey) as? String }
        set { objc_setAssociatedObject(self, atlasFeatureIDAssociationKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    var atlasFeatureName: String? {
        get { objc_getAssociatedObject(self, atlasFeatureNameAssociationKey) as? String }
        set { objc_setAssociatedObject(self, atlasFeatureNameAssociationKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    var atlasFeatureStyle: AtlasMapFeatureStyle? {
        get { objc_getAssociatedObject(self, atlasFeatureStyleAssociationKey) as? AtlasMapFeatureStyle }
        set { objc_setAssociatedObject(self, atlasFeatureStyleAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
