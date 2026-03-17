import SwiftUI

struct MapSettingsScene: View {
    @ObservedObject var preferencesController: AppPreferencesController

    var body: some View {
        Form {
            controlsSection
            resetSection
        }
        .navigationTitle(AppStrings.Settings.Map.title)
    }

    private var controlsSection: some View {
        Section {
            Toggle(isOn: $preferencesController.showYearRangeLabels) {
                Label(AppStrings.Settings.Map.showYearRangeLabels, systemImage: "textformat.123")
            }

            Toggle(isOn: $preferencesController.showLoadingIndicator) {
                Label(AppStrings.Settings.Map.showLoadingIndicator, systemImage: "progress.indicator")
            }
        } header: {
            Text(AppStrings.Settings.Map.presentationTitle)
        } footer: {
            Text(AppStrings.Settings.Map.presentationFooter)
        }
    }

    private var resetSection: some View {
        Section {
            Button(AppStrings.Settings.Map.reset, role: .destructive) {
                preferencesController.resetToDefaults()
            }
        }
    }
}

#if DEBUG
struct MapSettingsScene_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            mapPreview(localeIdentifier: "en", layoutDirection: .leftToRight)
                .previewDisplayName("Map · English")

            mapPreview(localeIdentifier: "fa", layoutDirection: .rightToLeft)
                .previewDisplayName("Map · Persian RTL")
        }
    }

    private static func mapPreview(
        localeIdentifier: String,
        layoutDirection: LayoutDirection
    ) -> some View {
        NavigationStack {
            MapSettingsScene(preferencesController: AppPreferencesController())
        }
        .environment(\.locale, Locale(identifier: localeIdentifier))
        .environment(\.layoutDirection, layoutDirection)
    }
}
#endif
