import Combine
import SwiftUI

@MainActor
final class AppearanceController: ObservableObject {
    private enum StorageKey {
        static let appearance = "atlas.appAppearance"
        static let glassEnabled = "atlas.glassEnabled"
    }

    @Published var selectedAppearance: AppAppearanceOption {
        didSet {
            defaults.set(selectedAppearance.rawValue, forKey: StorageKey.appearance)
        }
    }

    @Published var glassEnabled: Bool {
        didSet {
            defaults.set(glassEnabled, forKey: StorageKey.glassEnabled)
        }
    }

    var preferredColorScheme: ColorScheme? {
        selectedAppearance.preferredColorScheme
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.selectedAppearance = AppAppearanceOption(
            rawValue: defaults.string(forKey: StorageKey.appearance) ?? AppAppearanceOption.system.rawValue
        ) ?? .system
        if defaults.object(forKey: StorageKey.glassEnabled) == nil {
            self.glassEnabled = true
        } else {
            self.glassEnabled = defaults.bool(forKey: StorageKey.glassEnabled)
        }
    }

    func resetToDefaults() {
        selectedAppearance = .system
        glassEnabled = true
    }
}
