import SwiftUI

struct AtlasScreen: View {
    @ObservedObject var viewModel: AtlasViewModel
    @Environment(\.atlasTheme) private var theme
    @Environment(\.atlasShowLoadingIndicator) private var showLoadingIndicator

    var body: some View {
        ZStack(alignment: .bottom) {
            AtlasMapView(
                snapshot: viewModel.renderSnapshot,
                selectedCountryID: viewModel.selectedCountryID,
                onCountrySelectionChanged: viewModel.selectCountry(id:)
            )
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text(viewModel.displayYear == 0 ? String(localized: AppStrings.Common.unavailableValue) : "\(viewModel.displayYear)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(theme.primaryText)

                    Spacer()

                    if viewModel.isLoading && showLoadingIndicator {
                        ProgressView()
                            .controlSize(.small)
                    }
                }

                YearSliderView(
                    selectedYear: Binding(
                        get: { viewModel.displayYear },
                        set: { viewModel.onYearChanged(year: $0) }
                    ),
                    availableYears: viewModel.availableYears
                )

                if viewModel.selectedCountry != nil || !viewModel.visibleSnapshots.isEmpty {
                    countrySummarySection
                }

                if let message = viewModel.errorMessage, !message.isEmpty {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding(16)
            .atlasCardSurface(cornerRadius: 16)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    private var countrySummarySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let selectedCountry = viewModel.selectedCountry {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.Home.selectedCountryTitle)
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)

                    Text(selectedCountry.displayName)
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(theme.selectionFill, in: Capsule())
                }
            }

            Text(AppStrings.Home.countriesTitle)
                .font(.caption)
                .foregroundStyle(theme.secondaryText)

            let remainingCountries = viewModel.visibleSnapshots.filter { $0.id != viewModel.selectedCountryID }
            let visibleNames = Array(remainingCountries.prefix(3)).map(\.displayName)
            let remainingCount = max(0, remainingCountries.count - visibleNames.count)

            if !visibleNames.isEmpty {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(visibleNames.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(theme.primaryText)
                        .lineLimit(2)

                    if remainingCount > 0 {
                        Text(
                            LocalizedStringFormat.resolve(
                                AppStrings.Home.countriesMoreFormat,
                                locale: .current,
                                remainingCount
                            )
                        )
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct AtlasScreen_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        Group {
            atlasPreview(localeIdentifier: "en", layoutDirection: .leftToRight)
                .previewDisplayName(PreviewDisplayName.english("Home Panel"))

            atlasPreview(localeIdentifier: "fa", layoutDirection: .rightToLeft)
                .previewDisplayName(PreviewDisplayName.persianRTL("Home Panel"))
        }
    }

    @MainActor
    private static func atlasPreview(
        localeIdentifier: String,
        layoutDirection: LayoutDirection
    ) -> some View {
        AtlasScreen(viewModel: HomePreviewFactory.makeViewModel())
            .environment(\.locale, Locale(identifier: localeIdentifier))
            .environment(\.layoutDirection, layoutDirection)
    }
}
#endif
