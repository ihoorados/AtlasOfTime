import Combine
import CoreAtlasAppSettings
import Foundation

@MainActor
final class AppLanguageController: ObservableObject {
    @Published var selectedLanguage: CoreAtlasAppSettings.AppLanguageOption {
        didSet {
            store.saveSelectedLanguage(selectedLanguage)
        }
    }

    private let store: any CoreAtlasAppSettings.LanguageSettingsStore

    init(
        store: any CoreAtlasAppSettings.LanguageSettingsStore = CoreAtlasAppSettings.UserDefaultsLanguageSettingsStore()
    ) {
        self.store = store
        self.selectedLanguage = store.loadSelectedLanguage()
    }

    func resetToDefaults() {
        selectedLanguage = .system
    }
}
