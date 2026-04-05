import Foundation

public struct UserDefaultsAppearanceSettingsStore: AppearanceSettingsStore {
    private enum StorageKey {
        static let appearance = "atlas.appAppearance"
        static let glassEnabled = "atlas.glassEnabled"
    }

    @UserDefaultRawRepresentable(
        key: StorageKey.appearance,
        defaultValue: .system
    )
    private var appearance: AppAppearanceOption

    @UserDefaultValue(key: StorageKey.glassEnabled, defaultValue: true)
    private var glassEnabled: Bool

    public init(defaults: UserDefaults = .standard) {
        self._appearance = UserDefaultRawRepresentable(
            key: StorageKey.appearance,
            defaultValue: .system,
            defaults: defaults
        )
        self._glassEnabled = UserDefaultValue(
            key: StorageKey.glassEnabled,
            defaultValue: true,
            defaults: defaults,
            getter: { defaults, key, defaultValue in
                guard defaults.object(forKey: key) != nil else { return defaultValue }
                return defaults.bool(forKey: key)
            },
            setter: { defaults, key, value in
                defaults.set(value, forKey: key)
            }
        )
    }

    public func loadAppearanceSettings() -> AppAppearanceSettings {
        AppAppearanceSettings(
            appearance: appearance,
            glassEnabled: glassEnabled
        )
    }

    public func saveAppearanceSettings(_ settings: AppAppearanceSettings) {
        appearance = settings.appearance
        glassEnabled = settings.glassEnabled
    }
}
