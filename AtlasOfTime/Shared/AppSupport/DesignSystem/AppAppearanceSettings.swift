import Foundation

struct AppAppearanceSettings: Equatable, Sendable {
    var appearance: AppAppearanceOption
    var glassEnabled: Bool

    static let `default` = AppAppearanceSettings(
        appearance: .system,
        glassEnabled: true
    )
}
