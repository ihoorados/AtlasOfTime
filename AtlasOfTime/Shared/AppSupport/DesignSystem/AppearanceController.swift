import Combine
import CoreAtlasAppSettings
import SwiftUI

@MainActor
final class AppearanceController: ObservableObject {
    @Published var selectedAppearance: CoreAtlasAppSettings.AppAppearanceOption {
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

    private let store: any CoreAtlasAppSettings.AppearanceSettingsStore

    init(
        store: any CoreAtlasAppSettings.AppearanceSettingsStore = CoreAtlasAppSettings.UserDefaultsAppearanceSettingsStore()
    ) {
        self.store = store
        let settings = store.loadAppearanceSettings()
        self.selectedAppearance = settings.appearance
        self.glassEnabled = settings.glassEnabled
    }

    func resetToDefaults() {
        selectedAppearance = CoreAtlasAppSettings.AppAppearanceSettings.default.appearance
        glassEnabled = CoreAtlasAppSettings.AppAppearanceSettings.default.glassEnabled
    }

    private func persist() {
        store.saveAppearanceSettings(
            CoreAtlasAppSettings.AppAppearanceSettings(
                appearance: selectedAppearance,
                glassEnabled: glassEnabled
            )
        )
    }
}
