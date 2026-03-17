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
            .accessibilityValue(yearRangeLabelsAccessibilityValue)

            Toggle(isOn: $preferencesController.showLoadingIndicator) {
                Label(AppStrings.Settings.Map.showLoadingIndicator, systemImage: "progress.indicator")
            }
            .accessibilityValue(loadingIndicatorAccessibilityValue)
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

    private var yearRangeLabelsAccessibilityValue: String {
        LocalizedStringFormat.resolve(
            AppStrings.Accessibility.MapSettings.yearRangeLabelsValueFormat,
            locale: .current,
            accessibilityOnOffValue(for: preferencesController.showYearRangeLabels)
        )
    }

    private var loadingIndicatorAccessibilityValue: String {
        LocalizedStringFormat.resolve(
            AppStrings.Accessibility.MapSettings.loadingIndicatorValueFormat,
            locale: .current,
            accessibilityOnOffValue(for: preferencesController.showLoadingIndicator)
        )
    }

    private func accessibilityOnOffValue(for isEnabled: Bool) -> String {
        String(localized: isEnabled ? AppStrings.Accessibility.Common.on : AppStrings.Accessibility.Common.off)
    }
}

#if DEBUG
struct MapSettingsScene_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            mapPreview(localeIdentifier: "en", layoutDirection: .leftToRight)
                .previewDisplayName(PreviewDisplayName.english("Map"))

            mapPreview(localeIdentifier: "fa", layoutDirection: .rightToLeft)
                .previewDisplayName(PreviewDisplayName.persianRTL("Map"))
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
