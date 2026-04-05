import Foundation

public protocol LanguageSettingsStore {
    func loadSelectedLanguage() -> AppLanguageOption
    func saveSelectedLanguage(_ language: AppLanguageOption)
}
