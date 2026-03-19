import Foundation

struct UserDefaultsAppPreferencesStore: AppPreferencesStore {
    private enum StorageKey {
        static let showYearRangeLabels = "atlas.showYearRangeLabels"
        static let showLoadingIndicator = "atlas.showLoadingIndicator"
    }

    @UserDefaultValue(key: StorageKey.showYearRangeLabels, defaultValue: true)
    private var showYearRangeLabels: Bool

    @UserDefaultValue(key: StorageKey.showLoadingIndicator, defaultValue: true)
    private var showLoadingIndicator: Bool

    init(defaults: UserDefaults = .standard) {
        self._showYearRangeLabels = UserDefaultValue(
            key: StorageKey.showYearRangeLabels,
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
        self._showLoadingIndicator = UserDefaultValue(
            key: StorageKey.showLoadingIndicator,
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

    func loadPreferences() -> AppPreferences {
        return AppPreferences(
            showYearRangeLabels: showYearRangeLabels,
            showLoadingIndicator: showLoadingIndicator
        )
    }

    func savePreferences(_ preferences: AppPreferences) {
        showYearRangeLabels = preferences.showYearRangeLabels
        showLoadingIndicator = preferences.showLoadingIndicator
    }
}
