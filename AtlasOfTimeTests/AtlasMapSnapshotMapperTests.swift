import CoreAtlasDomain
import CoreAtlasMap
import Testing
@testable import AtlasOfTime

struct AtlasMapSnapshotMapperTests {
    @Test
    func mapsPOIsToPointAnnotations() throws {
        let poi = HistoricalPOI(
            id: "waterloo-1815",
            year: 1815,
            title: "Battle of Waterloo",
            summary: "Napoleon was defeated near Waterloo.",
            coordinate: Coordinate(lat: 50.6806, lon: 4.4125),
            category: .battle,
            confidence: .high
        )

        let snapshot = try #require(
            AtlasMapSnapshotMapper().makeSnapshot(
                from: YearSnapshot(year: 1815, polygons: [samplePolygon]),
                pointsOfInterest: [poi]
            )
        )

        let point = try #require(snapshot.pointAnnotations.first)
        #expect(snapshot.pointAnnotations.count == 1)
        #expect(point.id == poi.id)
        #expect(point.title == poi.title)
        #expect(point.subtitle == poi.summary)
        #expect(point.coordinate == AtlasMapCoordinate(latitude: 50.6806, longitude: 4.4125))
        #expect(point.emphasis == .normal)
    }

    private var samplePolygon: GeoPolygon {
        GeoPolygon(
            outer: [
                Coordinate(lat: 0, lon: 0),
                Coordinate(lat: 0, lon: 1),
                Coordinate(lat: 1, lon: 1),
                Coordinate(lat: 1, lon: 0),
                Coordinate(lat: 0, lon: 0)
            ],
            holes: []
        )
    }
}
