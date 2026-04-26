import Foundation

public struct AtlasMapSnapshotBuilder: Sendable {
    private let labelPlacement: AtlasMapLabelPlacement

    public init(labelPlacement: AtlasMapLabelPlacement = AtlasMapLabelPlacement()) {
        self.labelPlacement = labelPlacement
    }

    public func makeSnapshot(
        features: [AtlasMapFeature],
        pointAnnotations: [AtlasMapPointAnnotation] = []
    ) -> AtlasMapSnapshot {
        AtlasMapSnapshot(
            features: features,
            labels: features.compactMap(labelPlacement.makeLabel(for:)),
            pointAnnotations: pointAnnotations
        )
    }
}
