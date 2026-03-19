import Combine
import SwiftUI

@MainActor
final class AppearanceController: ObservableObject {
    @Published var selectedAppearance: AppAppearanceOption {
        didSet {
            persist()
        }
    }

    @Published var glassEnabled: Bool {
        didSet {
            persist()
        }
    }

    var preferredColorScheme: ColorScheme? {
        selectedAppearance.preferredColorScheme
    }

    private let store: any AppearanceSettingsStore

    init(store: any AppearanceSettingsStore = UserDefaultsAppearanceSettingsStore()) {
        self.store = store
        let settings = store.loadAppearanceSettings()
        self.selectedAppearance = settings.appearance
        self.glassEnabled = settings.glassEnabled
    }

    func resetToDefaults() {
        selectedAppearance = AppAppearanceSettings.default.appearance
        glassEnabled = AppAppearanceSettings.default.glassEnabled
    }

    private func persist() {
        store.saveAppearanceSettings(
            AppAppearanceSettings(
                appearance: selectedAppearance,
                glassEnabled: glassEnabled
            )
        )
    }
}
