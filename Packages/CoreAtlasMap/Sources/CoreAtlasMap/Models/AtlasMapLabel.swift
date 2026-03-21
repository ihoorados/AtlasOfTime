import Foundation

public struct AtlasMapLabel: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let coordinate: AtlasMapCoordinate
    public let emphasis: Emphasis

    public init(
        id: String,
        title: String,
        coordinate: AtlasMapCoordinate,
        emphasis: Emphasis = .normal
    ) {
        self.id = id
        self.title = title
        self.coordinate = coordinate
        self.emphasis = emphasis
    }

    public enum Emphasis: Equatable, Sendable {
        case normal
        case selected
    }
}
