import Foundation

public struct AtlasMapFeature: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let polygons: [AtlasMapPolygon]
    public let style: AtlasMapFeatureStyle
    public let isSelectable: Bool

    public init(
        id: String,
        title: String,
        polygons: [AtlasMapPolygon],
        style: AtlasMapFeatureStyle,
        isSelectable: Bool = true
    ) {
        self.id = id
        self.title = title
        self.polygons = polygons
        self.style = style
        self.isSelectable = isSelectable
    }
}
