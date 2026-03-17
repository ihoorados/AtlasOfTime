import Foundation

enum AppLanguageOption: String, CaseIterable, Identifiable, Sendable {
    case system
    case english
    case persian

    var id: String { rawValue }

    var localeIdentifier: String? {
        switch self {
        case .system:
            nil
        case .english:
            "en"
        case .persian:
            "fa"
        }
    }

    var isRightToLeft: Bool? {
        switch self {
        case .system:
            nil
        case .english:
            false
        case .persian:
            true
        }
    }
}
