import Foundation

public struct AtlasMapSnapshot: Equatable, Sendable {
    public let features: [AtlasMapFeature]
    public let labels: [AtlasMapLabel]

    public init(
        features: [AtlasMapFeature],
        labels: [AtlasMapLabel] = []
    ) {
        self.features = features
        self.labels = labels
    }
}
