import SwiftUI
import CoreAtlasDomain

struct AtlasControlPanelView: View {
    let displayYear: Int
    let availableYears: [Int]
    let isLoading: Bool
    let showLoadingIndicator: Bool
    @Binding var showsPointsOfInterest: Bool
    let selectedCountrySnapshot: HistoricalCountrySnapshot?
    let selectedCountryBorderConfidenceText: LocalizedStringResource
    let selectedCountrySourceCount: Int
    let selectedPOI: HistoricalPOI?
    let selectedPOIConfidenceText: LocalizedStringResource
    let selectedPOISourceCount: Int
    let visibleSnapshots: [HistoricalCountrySnapshot]
    let selectedCountryID: String?
    let errorMessage: String?
    let onYearChanged: (Int) -> Void
    let onSelectedCountryTapped: (HistoricalCountrySnapshot) -> Void
    let onSelectedPOIDismissed: () -> Void

    @Environment(\.atlasTheme) private var theme
    @Environment(\.atlasGlassEnabled) private var glassEnabled

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow

            YearSliderView(
                selectedYear: Binding(
                    get: { displayYear },
                    set: { onYearChanged($0) }
                ),
                availableYears: availableYears
            )

            poiToggleRow

            if selectedPOI != nil {
                selectedPOISection
            }

            if selectedCountrySnapshot != nil || !visibleSnapshots.isEmpty {
                countrySummarySection
            }

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .padding(16)
        .atlasCardSurface(cornerRadius: 20)
        .overlay {
            if glassEnabled {
                glassHighlightOverlay
            }
        }
        .shadow(
            color: glassEnabled ? Color.black.opacity(0.10) : .clear,
            radius: glassEnabled ? 18 : 0,
            x: 0,
            y: glassEnabled ? 10 : 0
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }

    private var headerRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(displayYear == 0 ? String(localized: AppStrings.Common.unavailableValue) : "\(displayYear)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(theme.primaryText)

            Spacer()

            if isLoading && showLoadingIndicator {
                ProgressView()
                    .controlSize(.small)
            }
        }
    }

    private var poiToggleRow: some View {
        Toggle(isOn: $showsPointsOfInterest) {
            Label(AppStrings.Home.showPOIsTitle, systemImage: "mappin.and.ellipse")
                .font(.subheadline)
                .foregroundStyle(theme.primaryText)
        }
        .toggleStyle(.switch)
        .tint(theme.selectionFill)
    }

    private var countrySummarySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let selectedCountrySnapshot {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.Home.selectedCountryTitle)
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)

                    Button {
                        onSelectedCountryTapped(selectedCountrySnapshot)
                    } label: {
                        HStack(spacing: 8) {
                            Text(selectedCountrySnapshot.displayName)
                                .font(.headline)
                                .foregroundStyle(theme.primaryText)

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(theme.secondaryText)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(theme.selectionFill, in: Capsule())
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    HStack(spacing: 12) {
                        LabeledContent {
                            Text(selectedCountryBorderConfidenceText)
                                .foregroundStyle(theme.primaryText)
                        } label: {
                            Text(AppStrings.Home.borderConfidenceTitle)
                                .foregroundStyle(theme.secondaryText)
                        }

                        if selectedCountrySourceCount > 0 {
                            LabeledContent {
                                Text(
                                    LocalizedStringFormat.resolve(
                                        AppStrings.Home.sourceCountFormat,
                                        locale: .current,
                                        selectedCountrySourceCount
                                    )
                                )
                                .foregroundStyle(theme.primaryText)
                            } label: {
                                Text(AppStrings.Home.sourcesTitle)
                                    .foregroundStyle(theme.secondaryText)
                            }
                        }
                    }
                    .font(.caption)
                }
            }

            Text(AppStrings.Home.countriesTitle)
                .font(.caption)
                .foregroundStyle(theme.secondaryText)

            let remainingCountries = visibleSnapshots.filter { $0.id != selectedCountryID }
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

    @ViewBuilder
    private var selectedPOISection: some View {
        if let selectedPOI {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(AppStrings.Home.selectedPOITitle)
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)

                    Spacer()

                    Button(action: onSelectedPOIDismissed) {
                        Image(systemName: "xmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(theme.secondaryText)
                            .padding(6)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(AppStrings.Home.selectedPOIDismissAccessibilityLabel)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedPOI.title)
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)
                        .lineLimit(2)

                    Text(selectedPOI.summary)
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)
                        .lineLimit(3)
                }

                HStack(spacing: 12) {
                    LabeledContent {
                        Text(selectedPOIConfidenceText)
                            .foregroundStyle(theme.primaryText)
                    } label: {
                        Text(AppStrings.Home.selectedPOIConfidenceTitle)
                            .foregroundStyle(theme.secondaryText)
                    }

                    if selectedPOISourceCount > 0 {
                        LabeledContent {
                            Text(
                                LocalizedStringFormat.resolve(
                                    AppStrings.Home.sourceCountFormat,
                                    locale: .current,
                                    selectedPOISourceCount
                                )
                            )
                            .foregroundStyle(theme.primaryText)
                        } label: {
                            Text(AppStrings.Home.selectedPOISourcesTitle)
                                .foregroundStyle(theme.secondaryText)
                        }
                    }
                }
                .font(.caption)
            }
            .padding(12)
            .background(theme.selectionFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var glassHighlightOverlay: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.34),
                        Color.white.opacity(0.14),
                        Color.white.opacity(0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.18),
                                Color.white.opacity(0.05),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .allowsHitTesting(false)
            }
            .allowsHitTesting(false)
    }
}
