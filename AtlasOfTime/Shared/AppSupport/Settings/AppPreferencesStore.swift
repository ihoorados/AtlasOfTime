import Foundation

protocol AppPreferencesStore {
    func loadPreferences() -> AppPreferences
    func savePreferences(_ preferences: AppPreferences)
}
