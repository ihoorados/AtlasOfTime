import Foundation

struct AppPreferences: Equatable, Sendable {
    var showYearRangeLabels: Bool
    var showLoadingIndicator: Bool

    static let `default` = AppPreferences(
        showYearRangeLabels: true,
        showLoadingIndicator: true
    )
}
