import SwiftUI

struct SettingsScene: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.secondarySystemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Group {
                    if #available(iOS 26, *) {
                        GlassEffectContainer(spacing: 20) {
                            settingsContent
                        }
                    } else {
                        settingsContent
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var settingsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                settingsSection(
                    title: "Appearance",
                    items: [
                        "The app uses the native Liquid Glass tab bar on supported systems.",
                        "Theme controls can be added here later."
                    ]
                )

                settingsSection(
                    title: "Data",
                    items: [
                        "Historical dataset configuration can live here.",
                        "Cache and loading preferences can be added later."
                    ]
                )

                settingsSection(
                    title: "About",
                    items: [
                        "Atlas of Time",
                        "Version and app details can be added here."
                    ]
                )
            }
            .padding(20)
        }
    }

    @ViewBuilder
    private func settingsSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .modifier(SettingsCardGlassSurface())
        }
    }
}

private struct SettingsCardGlassSurface: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: 20))
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
        }
    }
}

#if DEBUG
struct SettingsScene_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScene()
    }
}
#endif
