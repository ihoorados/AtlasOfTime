import Foundation

protocol AppPreferencesStore: Sendable {
    func loadPreferences() -> AppPreferences
    func savePreferences(_ preferences: AppPreferences)
}
