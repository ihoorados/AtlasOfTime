import SwiftUI

struct SettingsScene: View {
    @ObservedObject var appearanceController: AppearanceController
    @ObservedObject var preferencesController: AppPreferencesController
    @Environment(\.atlasTheme) private var theme

    var body: some View {
        NavigationStack {
            Form {
                appearanceSection
                liquidGlassSection
                mapAndDataSection
                previewSection
                resetSection
            }
            .navigationTitle("Settings")
        }
    }

    private var appearanceSection: some View {
        Section {
            Picker("App Appearance", selection: $appearanceController.selectedAppearance) {
                ForEach(AppAppearanceOption.allCases) { option in
                    Label(option.title, systemImage: option.systemImage)
                        .tag(option)
                }
            }
        } header: {
            Text("Appearance")
        } footer: {
            Text(appearanceController.selectedAppearance.summary)
        }
    }

    private var liquidGlassSection: some View {
        Section {
            Toggle(isOn: $appearanceController.glassEnabled) {
                Label("Glass Surfaces", systemImage: "sparkles")
            }
        } header: {
            Text("Liquid Glass")
        } footer: {
            Text("The native tab bar uses the system Liquid Glass style automatically. This setting controls custom glass panels inside the app.")
        }
    }

    private var previewSection: some View {
        Section("Preview") {
            VStack(alignment: .leading, spacing: 14) {
                Text("Theme Preview")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Atlas of Time")
                        .font(.title3.weight(.semibold))

                    Text(previewSummary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        previewPill(title: "Light", isSelected: appearanceController.selectedAppearance == .light)
                        previewPill(title: "Dark", isSelected: appearanceController.selectedAppearance == .dark)
                        previewPill(title: "Glass", isSelected: appearanceController.glassEnabled)
                    }
                }
                .padding(16)
                .atlasCardSurface(cornerRadius: 18)
            }
            .padding(.vertical, 4)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowBackground(Color.clear)
        }
    }

    private var mapAndDataSection: some View {
        Section {
            Toggle(isOn: $preferencesController.showYearRangeLabels) {
                Label("Show Year Range Labels", systemImage: "textformat.123")
            }

            Toggle(isOn: $preferencesController.showLoadingIndicator) {
                Label("Show Loading Indicator", systemImage: "progress.indicator")
            }
        } header: {
            Text("Map & Data")
        } footer: {
            Text("These controls adjust the map panel and timeline behavior without affecting the historical data itself.")
        }
    }

    private var resetSection: some View {
        Section {
            Button("Reset Appearance Settings", role: .destructive) {
                appearanceController.resetToDefaults()
                preferencesController.resetToDefaults()
            }
        }
    }

    private var previewSummary: String {
        let appearance = appearanceController.selectedAppearance.title
        let glass = appearanceController.glassEnabled ? "glass surfaces on" : "glass surfaces reduced"
        return "\(appearance) mode with \(glass)."
    }

    private func previewPill(title: String, isSelected: Bool) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(isSelected ? theme.primaryText : theme.secondaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? theme.selectionFill : theme.subtleFill)
            )
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
