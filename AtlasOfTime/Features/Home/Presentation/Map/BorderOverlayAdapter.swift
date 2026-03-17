import MapKit
import ObjectiveC

enum BorderOverlayAdapter {
    @MainActor
    static func makeOverlays(from snapshot: YearSnapshot?) -> [MKPolygon] {
        guard let snapshot else { return [] }
        return snapshot.countries
            .flatMap { country in
                country.polygons.map { polygon in
                    makePolygonOverlay(from: polygon, country: country)
                }
            }
    }

    @MainActor
    private static func makePolygonOverlay(
        from polygon: GeoPolygon,
        country: HistoricalCountry
    ) -> MKPolygon {
        var outerCoordinates = polygon.outer.map {
            CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon)
        }

        let holes: [MKPolygon] = polygon.holes.map { ring in
            var holeCoordinates = ring.map {
                CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon)
            }
            return MKPolygon(coordinates: &holeCoordinates, count: holeCoordinates.count)
        }

        let overlay = MKPolygon(
            coordinates: &outerCoordinates,
            count: outerCoordinates.count,
            interiorPolygons: holes.isEmpty ? nil : holes
        )
        overlay.atlasCountryID = country.id
        overlay.atlasCountryName = country.displayName
        return overlay
    }
}

@MainActor
private let atlasCountryIDAssociationKey = UnsafeRawPointer(UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1))
@MainActor
private let atlasCountryNameAssociationKey = UnsafeRawPointer(UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1))

@MainActor
extension MKPolygon {
    var atlasCountryID: String? {
        get { objc_getAssociatedObject(self, atlasCountryIDAssociationKey) as? String }
        set { objc_setAssociatedObject(self, atlasCountryIDAssociationKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    var atlasCountryName: String? {
        get { objc_getAssociatedObject(self, atlasCountryNameAssociationKey) as? String }
        set { objc_setAssociatedObject(self, atlasCountryNameAssociationKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
}
