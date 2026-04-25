import Foundation

public struct UserDefaultsLanguageSettingsStore: LanguageSettingsStore {
    private enum StorageKey {
        static let selectedLanguage = "atlas.selectedLanguage"
    }

    @UserDefaultRawRepresentable(
        key: StorageKey.selectedLanguage,
        defaultValue: .system
    )
    private var selectedLanguage: AppLanguageOption

    public init(defaults: UserDefaults = .standard) {
        self._selectedLanguage = UserDefaultRawRepresentable(
            key: StorageKey.selectedLanguage,
            defaultValue: .system,
            defaults: defaults
        )
    }

    public func loadSelectedLanguage() -> AppLanguageOption {
        selectedLanguage
    }

    public func saveSelectedLanguage(_ language: AppLanguageOption) {
        selectedLanguage = language
    }
}
