import Testing
@testable import CoreAtlasMap

struct CoreAtlasMapTests {
    @Test
    func snapshotBuilderCreatesLabelForLargeFeature() {
        let feature = AtlasMapFeature(
            id: "feature:a",
            title: "Example",
            polygons: [
                AtlasMapPolygon(
                    outerRing: [
                        AtlasMapCoordinate(latitude: 0, longitude: 0),
                        AtlasMapCoordinate(latitude: 0, longitude: 2),
                        AtlasMapCoordinate(latitude: 2, longitude: 2),
                        AtlasMapCoordinate(latitude: 2, longitude: 0),
                        AtlasMapCoordinate(latitude: 0, longitude: 0)
                    ]
                )
            ],
            style: AtlasMapFeatureStyle(
                strokeKind: .precise,
                fillKind: .subtle
            )
        )

        let snapshot = AtlasMapSnapshotBuilder().makeSnapshot(features: [feature])

        #expect(snapshot.features.count == 1)
        #expect(snapshot.labels.count == 1)
        #expect(snapshot.labels.first?.title == "Example")
    }
}
