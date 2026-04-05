import Foundation

public struct AppPreferences: Equatable, Sendable {
    public var showYearRangeLabels: Bool
    public var showLoadingIndicator: Bool

    public static let `default` = AppPreferences(
        showYearRangeLabels: true,
        showLoadingIndicator: true
    )

    public init(showYearRangeLabels: Bool, showLoadingIndicator: Bool) {
        self.showYearRangeLabels = showYearRangeLabels
        self.showLoadingIndicator = showLoadingIndicator
    }
}
