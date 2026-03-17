import SwiftUI

struct SettingsScene: View {
    @ObservedObject var appearanceController: AppearanceController
    @ObservedObject var preferencesController: AppPreferencesController

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        Color.clear
                            .navigationTitle("Appearance")
                    } label: {
                        settingsRow(title: "Appearance", systemImage: "circle.lefthalf.filled")
                    }

                    NavigationLink {
                        Color.clear
                            .navigationTitle("Map")
                    } label: {
                        settingsRow(title: "Map", systemImage: "map")
                    }

                    NavigationLink {
                        Color.clear
                            .navigationTitle("Data")
                    } label: {
                        settingsRow(title: "Data", systemImage: "internaldrive")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func settingsRow(
        title: String,
        systemImage: String
    ) -> some View {
        Label(title, systemImage: systemImage)
            .font(.body)
    }
}

#if DEBUG
struct SettingsScene_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScene(
            appearanceController: AppearanceController(),
            preferencesController: AppPreferencesController()
        )
    }
}
#endif
