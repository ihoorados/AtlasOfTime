import Foundation

struct UserDefaultsLanguageSettingsStore: LanguageSettingsStore {
    private enum StorageKey {
        static let selectedLanguage = "atlas.selectedLanguage"
    }

    @UserDefaultRawRepresentable(
        key: StorageKey.selectedLanguage,
        defaultValue: .system
    )
    private var selectedLanguage: AppLanguageOption

    init(defaults: UserDefaults = .standard) {
        self._selectedLanguage = UserDefaultRawRepresentable(
            key: StorageKey.selectedLanguage,
            defaultValue: .system,
            defaults: defaults
        )
    }

    func loadSelectedLanguage() -> AppLanguageOption {
        selectedLanguage
    }

    func saveSelectedLanguage(_ language: AppLanguageOption) {
        selectedLanguage = language
    }
}
