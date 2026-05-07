import Foundation

public struct AtlasMapPointAnnotation: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let coordinate: AtlasMapCoordinate
    public let emphasis: Emphasis

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        coordinate: AtlasMapCoordinate,
        emphasis: Emphasis = .normal
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.emphasis = emphasis
    }

    public enum Emphasis: Equatable, Sendable {
        case normal
        case selected
    }
}
