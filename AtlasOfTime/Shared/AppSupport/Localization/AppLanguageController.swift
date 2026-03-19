import Combine
import Foundation

@MainActor
final class AppLanguageController: ObservableObject {
    @Published var selectedLanguage: AppLanguageOption {
        didSet {
            store.saveSelectedLanguage(selectedLanguage)
        }
    }

    private let store: any LanguageSettingsStore

    init(store: any LanguageSettingsStore = UserDefaultsLanguageSettingsStore()) {
        self.store = store
        self.selectedLanguage = store.loadSelectedLanguage()
    }

    func resetToDefaults() {
        selectedLanguage = .system
    }
}
