import Foundation

protocol AppearanceSettingsStore: Sendable {
    func loadAppearanceSettings() -> AppAppearanceSettings
    func saveAppearanceSettings(_ settings: AppAppearanceSettings)
}
