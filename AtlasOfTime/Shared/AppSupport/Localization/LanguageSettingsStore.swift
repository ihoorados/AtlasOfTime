import Foundation

protocol LanguageSettingsStore: Sendable {
    func loadSelectedLanguage() -> AppLanguageOption
    func saveSelectedLanguage(_ language: AppLanguageOption)
}
