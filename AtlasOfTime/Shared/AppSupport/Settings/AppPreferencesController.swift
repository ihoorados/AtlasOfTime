import Combine
import SwiftUI

@MainActor
final class AppPreferencesController: ObservableObject {
    @Published var showYearRangeLabels: Bool {
        didSet {
            persist()
        }
    }

    @Published var showLoadingIndicator: Bool {
        didSet {
            persist()
        }
    }

    private let store: any AppPreferencesStore

    init(store: any AppPreferencesStore = UserDefaultsAppPreferencesStore()) {
        self.store = store
        let preferences = store.loadPreferences()
        self.showYearRangeLabels = preferences.showYearRangeLabels
        self.showLoadingIndicator = preferences.showLoadingIndicator
    }

    func resetToDefaults() {
        showYearRangeLabels = AppPreferences.default.showYearRangeLabels
        showLoadingIndicator = AppPreferences.default.showLoadingIndicator
    }

    private func persist() {
        store.savePreferences(
            AppPreferences(
                showYearRangeLabels: showYearRangeLabels,
                showLoadingIndicator: showLoadingIndicator
            )
        )
    }
}
