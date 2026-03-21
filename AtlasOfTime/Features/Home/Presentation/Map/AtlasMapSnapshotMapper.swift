import CoreAtlasMap
import Foundation

struct AtlasMapSnapshotMapper {
    private let snapshotBuilder: AtlasMapSnapshotBuilder

    init(snapshotBuilder: AtlasMapSnapshotBuilder = AtlasMapSnapshotBuilder()) {
        self.snapshotBuilder = snapshotBuilder
    }

    func makeSnapshot(
        from snapshot: YearSnapshot?,
        selectedCountryID: String?
    ) -> AtlasMapSnapshot? {
        guard let snapshot else { return nil }

        let features = snapshot.snapshots.compactMap { countrySnapshot in
            makeFeature(
                from: countrySnapshot,
                selectedCountryID: selectedCountryID
            )
        }

        return snapshotBuilder.makeSnapshot(features: features)
    }

    private func makeFeature(
        from snapshot: HistoricalCountrySnapshot,
        selectedCountryID: String?
    ) -> AtlasMapFeature? {
        let polygons = snapshot.extents.flatMap(\.polygons).map(makePolygon)
        guard !polygons.isEmpty else { return nil }

        // The current Home flow selects whole country snapshots, not individual extents.
        // Collapse extent geometry into one renderable feature for now so provider swapping
        // does not force a premature change to app selection semantics.
        return AtlasMapFeature(
            id: snapshot.id,
            title: snapshot.displayName,
            polygons: polygons,
            style: makeFeatureStyle(
                from: snapshot.extents,
                isSelected: snapshot.id == selectedCountryID
            )
        )
    }

    private func makeFeatureStyle(
        from extents: [HistoricalExtent],
        isSelected: Bool
    ) -> AtlasMapFeatureStyle {
        let dominantBorderModel = extents.first?.borderModel ?? .approximateLine

        return AtlasMapFeatureStyle(
            strokeKind: makeStrokeKind(from: dominantBorderModel),
            fillKind: isSelected ? .strong : .subtle,
            emphasis: isSelected ? .selected : .normal
        )
    }

    private func makeStrokeKind(from borderModel: HistoricalBorderModel) -> AtlasMapFeatureStyle.StrokeKind {
        switch borderModel {
        case .preciseLine:
            .precise
        case .approximateLine:
            .approximate
        case .lineWithUncertainty:
            .uncertain
        case .zone:
            .zone
        }
    }

    private func makePolygon(from polygon: GeoPolygon) -> AtlasMapPolygon {
        AtlasMapPolygon(
            outerRing: polygon.outer.map(makeCoordinate),
            holes: polygon.holes.map { ring in
                ring.map(makeCoordinate)
            }
        )
    }

    private func makeCoordinate(from coordinate: Coordinate) -> AtlasMapCoordinate {
        AtlasMapCoordinate(
            latitude: coordinate.lat,
            longitude: coordinate.lon
        )
    }
}
