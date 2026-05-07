import Foundation

public struct AtlasMapSnapshot: Equatable, Sendable {
    public let features: [AtlasMapFeature]
    public let labels: [AtlasMapLabel]
    public let pointAnnotations: [AtlasMapPointAnnotation]

    public init(
        features: [AtlasMapFeature],
        labels: [AtlasMapLabel] = [],
        pointAnnotations: [AtlasMapPointAnnotation] = []
    ) {
        self.features = features
        self.labels = labels
        self.pointAnnotations = pointAnnotations
    }
}
