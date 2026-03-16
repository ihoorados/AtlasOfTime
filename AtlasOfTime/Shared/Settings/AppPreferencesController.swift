import Combine
import SwiftUI

@MainActor
final class AppPreferencesController: ObservableObject {
    private enum StorageKey {
        static let showYearRangeLabels = "atlas.showYearRangeLabels"
        static let showLoadingIndicator = "atlas.showLoadingIndicator"
    }

    @Published var showYearRangeLabels: Bool {
        didSet {
            defaults.set(showYearRangeLabels, forKey: StorageKey.showYearRangeLabels)
        }
    }

    @Published var showLoadingIndicator: Bool {
        didSet {
            defaults.set(showLoadingIndicator, forKey: StorageKey.showLoadingIndicator)
        }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if defaults.object(forKey: StorageKey.showYearRangeLabels) == nil {
            self.showYearRangeLabels = true
        } else {
            self.showYearRangeLabels = defaults.bool(forKey: StorageKey.showYearRangeLabels)
        }

        if defaults.object(forKey: StorageKey.showLoadingIndicator) == nil {
            self.showLoadingIndicator = true
        } else {
            self.showLoadingIndicator = defaults.bool(forKey: StorageKey.showLoadingIndicator)
        }
    }

    func resetToDefaults() {
        showYearRangeLabels = true
        showLoadingIndicator = true
    }
}
