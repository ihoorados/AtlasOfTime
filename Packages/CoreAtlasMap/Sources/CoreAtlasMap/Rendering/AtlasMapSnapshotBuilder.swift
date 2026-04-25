import Foundation

public struct AtlasMapSnapshotBuilder: Sendable {
    private let labelPlacement: AtlasMapLabelPlacement

    public init(labelPlacement: AtlasMapLabelPlacement = AtlasMapLabelPlacement()) {
        self.labelPlacement = labelPlacement
    }

    public func makeSnapshot(features: [AtlasMapFeature]) -> AtlasMapSnapshot {
        AtlasMapSnapshot(
            features: features,
            labels: features.compactMap(labelPlacement.makeLabel(for:))
        )
    }
}
