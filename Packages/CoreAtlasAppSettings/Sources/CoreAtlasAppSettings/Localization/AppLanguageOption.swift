import Foundation

public enum AppLanguageOption: String, CaseIterable, Identifiable, Sendable {
    case system
    case english
    case persian

    public var id: String { rawValue }

    public var localeIdentifier: String? {
        switch self {
        case .system:
            nil
        case .english:
            "en"
        case .persian:
            "fa"
        }
    }

    public var isRightToLeft: Bool? {
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
