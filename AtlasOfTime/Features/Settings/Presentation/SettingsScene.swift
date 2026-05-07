import SwiftUI

struct SettingsScene: View {
    let onRouteSelected: (SettingsRoute) -> Void

    var body: some View {
        Form {
            Section {
                settingsButton(
                    title: AppStrings.Settings.Root.appearance,
                    systemImage: "circle.lefthalf.filled",
                    route: .appearance
                )

                settingsButton(
                    title: AppStrings.Settings.Root.map,
                    systemImage: "map",
                    route: .map
                )

                settingsButton(
                    title: AppStrings.Settings.Root.data,
                    systemImage: "internaldrive",
                    route: .data
                )
            }
        }
        .navigationTitle(AppStrings.Settings.Root.title)
        .atlasMacSettingsContentWidth()
    }

    private func settingsButton(
        title: LocalizedStringResource,
        systemImage: String,
        route: SettingsRoute
    ) -> some View {
        Button {
            onRouteSelected(route)
        } label: {
            settingsRow(title: title, systemImage: systemImage)
        }
        .buttonStyle(.plain)
    }

    private func settingsRow(
        title: LocalizedStringResource,
        systemImage: String
    ) -> some View {
        HStack(spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.body)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
}

private extension View {
    @ViewBuilder
    func atlasMacSettingsContentWidth() -> some View {
        #if os(macOS)
        frame(maxWidth: 640, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        #else
        self
        #endif
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
        SettingsPreviewFactory.makeSettingsScene()
            .environment(\.locale, Locale(identifier: localeIdentifier))
            .environment(\.layoutDirection, layoutDirection)
    }
}
#endif
