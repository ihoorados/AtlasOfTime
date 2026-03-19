import Foundation

protocol AppearanceSettingsStore {
    func loadAppearanceSettings() -> AppAppearanceSettings
    func saveAppearanceSettings(_ settings: AppAppearanceSettings)
}
