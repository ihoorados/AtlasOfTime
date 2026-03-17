import Combine
import Foundation

@MainActor
final class AppLanguageController: ObservableObject {
    private enum StorageKey {
        static let selectedLanguage = "atlas.selectedLanguage"
    }

    @Published var selectedLanguage: AppLanguageOption {
        didSet {
            defaults.set(selectedLanguage.rawValue, forKey: StorageKey.selectedLanguage)
        }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.selectedLanguage = AppLanguageOption(
            rawValue: defaults.string(forKey: StorageKey.selectedLanguage) ?? AppLanguageOption.system.rawValue
        ) ?? .system
    }

    func resetToDefaults() {
        selectedLanguage = .system
    }
}
