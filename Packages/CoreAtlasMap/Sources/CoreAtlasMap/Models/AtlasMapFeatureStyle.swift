import Foundation

public struct AtlasMapFeatureStyle: Equatable, Sendable {
    public let strokeKind: StrokeKind
    public let fillKind: FillKind
    public let emphasis: Emphasis

    public init(
        strokeKind: StrokeKind,
        fillKind: FillKind,
        emphasis: Emphasis = .normal
    ) {
        self.strokeKind = strokeKind
        self.fillKind = fillKind
        self.emphasis = emphasis
    }

    public enum StrokeKind: Equatable, Sendable {
        case precise
        case approximate
        case uncertain
        case zone
    }

    public enum FillKind: Equatable, Sendable {
        case none
        case subtle
        case strong
    }

    public enum Emphasis: Equatable, Sendable {
        case normal
        case selected
        case muted
    }
}
