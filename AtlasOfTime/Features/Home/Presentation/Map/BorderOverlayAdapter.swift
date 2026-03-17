import MapKit

enum BorderOverlayAdapter {
    static func makeOverlays(from snapshot: YearSnapshot?) -> [MKPolygon] {
        guard let snapshot else { return [] }
        return snapshot.countries
            .flatMap(\.polygons)
            .map { makePolygonOverlay(from: $0) }
    }

    private static func makePolygonOverlay(from polygon: GeoPolygon) -> MKPolygon {
        var outerCoordinates = polygon.outer.map {
            CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon)
        }

        let holes: [MKPolygon] = polygon.holes.map { ring in
            var holeCoordinates = ring.map {
                CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon)
            }
            return MKPolygon(coordinates: &holeCoordinates, count: holeCoordinates.count)
        }

        return MKPolygon(
            coordinates: &outerCoordinates,
            count: outerCoordinates.count,
            interiorPolygons: holes.isEmpty ? nil : holes
        )
    }
}
