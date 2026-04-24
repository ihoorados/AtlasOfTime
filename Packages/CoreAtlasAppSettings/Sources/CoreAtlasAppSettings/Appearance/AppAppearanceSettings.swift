import Foundation

public struct AppAppearanceSettings: Equatable, Sendable {
    public var appearance: AppAppearanceOption
    public var glassEnabled: Bool

    public static let `default` = AppAppearanceSettings(
        appearance: .system,
        glassEnabled: true
    )

    public init(appearance: AppAppearanceOption, glassEnabled: Bool) {
        self.appearance = appearance
        self.glassEnabled = glassEnabled
    }
}
