import SwiftUI

struct SettingsScene: View {
    @ObservedObject var appearanceController: AppearanceController
    @ObservedObject var preferencesController: AppPreferencesController

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        AppearanceSettingsScene(appearanceController: appearanceController)
                    } label: {
                        settingsRow(title: AppStrings.Settings.Root.appearance, systemImage: "circle.lefthalf.filled")
                    }

                    NavigationLink {
                        MapSettingsScene(preferencesController: preferencesController)
                    } label: {
                        settingsRow(title: AppStrings.Settings.Root.map, systemImage: "map")
                    }

                    NavigationLink {
                        DataSettingsScene()
                    } label: {
                        settingsRow(title: AppStrings.Settings.Root.data, systemImage: "internaldrive")
                    }
                }
            }
            .navigationTitle(AppStrings.Settings.Root.title)
        }
    }

    private func settingsRow(
        title: LocalizedStringResource,
        systemImage: String
    ) -> some View {
        Label(title, systemImage: systemImage)
            .font(.body)
    }
}

#if DEBUG
struct SettingsScene_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            settingsPreview(localeIdentifier: "en", layoutDirection: .leftToRight)
                .previewDisplayName(PreviewDisplayName.english("Settings"))

            settingsPreview(localeIdentifier: "fa", layoutDirection: .rightToLeft)
                .previewDisplayName(PreviewDisplayName.persianRTL("Settings"))
        }
    }

    private static func settingsPreview(
        localeIdentifier: String,
        layoutDirection: LayoutDirection
    ) -> some View {
        SettingsScene(
            appearanceController: AppearanceController(),
            preferencesController: AppPreferencesController()
        )
        .environment(\.locale, Locale(identifier: localeIdentifier))
        .environment(\.layoutDirection, layoutDirection)
    }
}
#endif
