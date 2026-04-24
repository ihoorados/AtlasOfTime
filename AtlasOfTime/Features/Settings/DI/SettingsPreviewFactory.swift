import SwiftUI

@MainActor
enum SettingsPreviewFactory {
    static func makeAppearanceController() -> AppearanceController {
        AppearanceController()
    }

    static func makeLanguageController() -> AppLanguageController {
        AppLanguageController()
    }

    static func makePreferencesController() -> MapPreferencesController {
        MapPreferencesController()
    }

    static func makeSettingsScene() -> SettingsScene {
        SettingsScene(
            onRouteSelected: { _ in }
        )
    }

    static func makeAppearanceSettingsScene() -> AppearanceSettingsScene {
        AppearanceSettingsScene(
            appearanceController: makeAppearanceController(),
            languageController: makeLanguageController()
        )
    }

    static func makeMapSettingsScene() -> MapSettingsScene {
        MapSettingsScene(preferencesController: makePreferencesController())
    }

    static func makeDataSettingsScene() -> DataSettingsScene {
        DataSettingsScene()
    }
}
