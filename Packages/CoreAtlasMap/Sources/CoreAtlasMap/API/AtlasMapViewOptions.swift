import Foundation

public struct AtlasMapViewOptions: Sendable, Equatable {
    public let showsLabels: Bool
    public let allowsSelection: Bool
    public let allowsZoom: Bool
    public let allowsPan: Bool

    public init(
        showsLabels: Bool = true,
        allowsSelection: Bool = true,
        allowsZoom: Bool = true,
        allowsPan: Bool = true
    ) {
        self.showsLabels = showsLabels
        self.allowsSelection = allowsSelection
        self.allowsZoom = allowsZoom
        self.allowsPan = allowsPan
    }
}
