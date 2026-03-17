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
        NavigationStack {
            MapSettingsScene(preferencesController: AppPreferencesController())
        }
    }
}
#endif
