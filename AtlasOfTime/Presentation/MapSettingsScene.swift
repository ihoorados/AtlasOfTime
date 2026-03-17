import SwiftUI

struct MapSettingsScene: View {
    @ObservedObject var preferencesController: AppPreferencesController

    var body: some View {
        Form {
            controlsSection
            resetSection
        }
        .navigationTitle("Map")
    }

    private var controlsSection: some View {
        Section {
            Toggle(isOn: $preferencesController.showYearRangeLabels) {
                Label("Show Year Range Labels", systemImage: "textformat.123")
            }

            Toggle(isOn: $preferencesController.showLoadingIndicator) {
                Label("Show Loading Indicator", systemImage: "progress.indicator")
            }
        } header: {
            Text("Presentation")
        } footer: {
            Text("These controls adjust the map panel and timeline presentation without affecting the underlying historical data.")
        }
    }

    private var resetSection: some View {
        Section {
            Button("Reset Map Settings", role: .destructive) {
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
