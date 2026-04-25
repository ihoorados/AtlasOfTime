import CoreAtlasAppSettings
import SwiftUI

struct AppearanceSettingsScene: View {
    @ObservedObject var appearanceController: AppearanceController
    @ObservedObject var languageController: AppLanguageController
    @Environment(\.atlasTheme) private var theme

    var body: some View {
        Form {
            appearanceSection
            liquidGlassSection
            previewSection
            resetSection
        }
        .navigationTitle(AppStrings.Settings.Appearance.title)
    }

    private var appearanceSection: some View {
        Section {
            Picker(AppStrings.Settings.Appearance.appAppearance, selection: $appearanceController.selectedAppearance) {
                ForEach(CoreAtlasAppSettings.AppAppearanceOption.allCases) { option in
                    Label(option.title, systemImage: option.systemImage)
                        .tag(option)
                }
            }
            .accessibilityValue(appearanceSelectionAccessibilityValue)

            Picker(AppStrings.Settings.Appearance.appLanguage, selection: $languageController.selectedLanguage) {
                ForEach(CoreAtlasAppSettings.AppLanguageOption.allCases) { option in
                    Text(option.title)
                        .tag(option)
                }
            }
            .accessibilityValue(languageSelectionAccessibilityValue)
        } header: {
            Text(AppStrings.Settings.Appearance.sectionTitle)
        } footer: {
            VStack(alignment: .leading, spacing: 8) {
                Text(appearanceController.selectedAppearance.summary)
                Text(AppStrings.Settings.Appearance.languageFooter)
            }
        }
    }

    private var liquidGlassSection: some View {
        Section {
            Toggle(isOn: $appearanceController.glassEnabled) {
                Label(AppStrings.Settings.Appearance.glassSurfaces, systemImage: "sparkles")
            }
            .accessibilityValue(glassSurfacesAccessibilityValue)
        } header: {
            Text(AppStrings.Settings.Appearance.liquidGlassTitle)
        } footer: {
            Text(AppStrings.Settings.Appearance.liquidGlassFooter)
        }
    }

    private var previewSection: some View {
        Section(AppStrings.Settings.Appearance.previewTitle) {
            VStack(alignment: .leading, spacing: 14) {
                Text(AppStrings.Settings.Appearance.previewCardTitle)
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text(AppStrings.Common.appName)
                        .font(.title3.weight(.semibold))

                    Text(previewSummary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        previewPill(title: AppStrings.Settings.Appearance.previewLight, isSelected: appearanceController.selectedAppearance == .light)
                        previewPill(title: AppStrings.Settings.Appearance.previewDark, isSelected: appearanceController.selectedAppearance == .dark)
                        previewPill(title: AppStrings.Settings.Appearance.previewGlass, isSelected: appearanceController.glassEnabled)
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

    private var resetSection: some View {
        Section {
            Button(AppStrings.Settings.Appearance.reset, role: .destructive) {
                appearanceController.resetToDefaults()
            }
        }
    }

    private var previewSummary: String {
        let appearance = appearanceController.selectedAppearance.title
        let glass = appearanceController.glassEnabled
            ? String(localized: AppStrings.Settings.Appearance.previewGlassEnabled)
            : String(localized: AppStrings.Settings.Appearance.previewGlassReduced)
        return LocalizedStringFormat.resolve(
            AppStrings.Settings.Appearance.previewSummaryFormat,
            locale: .current,
            comment: "Appearance preview summary",
            appearance,
            glass
        )
    }

    private func previewPill(title: LocalizedStringResource, isSelected: Bool) -> some View {
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

    private var appearanceSelectionAccessibilityValue: String {
        LocalizedStringFormat.resolve(
            AppStrings.Accessibility.AppearanceSettings.appAppearanceValueFormat,
            locale: .current,
            appearanceController.selectedAppearance.title
        )
    }

    private var glassSurfacesAccessibilityValue: String {
        LocalizedStringFormat.resolve(
            AppStrings.Accessibility.AppearanceSettings.glassSurfacesValueFormat,
            locale: .current,
            accessibilityOnOffValue(for: appearanceController.glassEnabled)
        )
    }

    private var languageSelectionAccessibilityValue: String {
        LocalizedStringFormat.resolve(
            AppStrings.Accessibility.AppearanceSettings.appLanguageValueFormat,
            locale: .current,
            String(localized: languageController.selectedLanguage.title)
        )
    }

    private func accessibilityOnOffValue(for isEnabled: Bool) -> String {
        String(localized: isEnabled ? AppStrings.Accessibility.Common.on : AppStrings.Accessibility.Common.off)
    }
}

#if DEBUG
struct AppearanceSettingsScene_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            appearancePreview(localeIdentifier: "en", layoutDirection: .leftToRight)
                .previewDisplayName(PreviewDisplayName.english("Appearance"))

            appearancePreview(localeIdentifier: "fa", layoutDirection: .rightToLeft)
                .previewDisplayName(PreviewDisplayName.persianRTL("Appearance"))
        }
    }

    private static func appearancePreview(
        localeIdentifier: String,
        layoutDirection: LayoutDirection
    ) -> some View {
        NavigationStack {
            SettingsPreviewFactory.makeAppearanceSettingsScene()
        }
        .environment(\.locale, Locale(identifier: localeIdentifier))
        .environment(\.layoutDirection, layoutDirection)
    }
}
#endif
