import Combine
import CoreAtlasAppSettings
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

    private let store: any CoreAtlasAppSettings.AppPreferencesStore

    init(
        store: any CoreAtlasAppSettings.AppPreferencesStore = CoreAtlasAppSettings.UserDefaultsAppPreferencesStore()
    ) {
        self.store = store
        let preferences = store.loadPreferences()
        self.showYearRangeLabels = preferences.showYearRangeLabels
        self.showLoadingIndicator = preferences.showLoadingIndicator
    }

    func resetToDefaults() {
        showYearRangeLabels = CoreAtlasAppSettings.AppPreferences.default.showYearRangeLabels
        showLoadingIndicator = CoreAtlasAppSettings.AppPreferences.default.showLoadingIndicator
    }

    private func persist() {
        store.savePreferences(
            CoreAtlasAppSettings.AppPreferences(
                showYearRangeLabels: showYearRangeLabels,
                showLoadingIndicator: showLoadingIndicator
            )
        )
    }
}
