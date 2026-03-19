import SwiftUI

struct AtlasScreen: View {
    @ObservedObject var viewModel: AtlasViewModel
    let onSelectedCountryTapped: (HistoricalCountrySnapshot) -> Void
    @Environment(\.atlasShowLoadingIndicator) private var showLoadingIndicator

    var body: some View {
        ZStack(alignment: .bottom) {
            AtlasMapView(
                snapshot: viewModel.renderSnapshot,
                selectedCountryID: viewModel.selectedCountryID,
                onCountrySelectionChanged: viewModel.selectCountry(id:)
            )
                .ignoresSafeArea()

            AtlasControlPanelView(
                displayYear: viewModel.displayYear,
                availableYears: viewModel.availableYears,
                isLoading: viewModel.isLoading,
                showLoadingIndicator: showLoadingIndicator,
                selectedCountrySnapshot: viewModel.selectedCountrySnapshot,
                selectedCountryBorderConfidenceText: viewModel.selectedCountryBorderConfidenceText,
                selectedCountrySourceCount: viewModel.selectedCountrySourceCount,
                visibleSnapshots: viewModel.visibleSnapshots,
                selectedCountryID: viewModel.selectedCountryID,
                errorMessage: viewModel.errorMessage,
                onYearChanged: viewModel.onYearChanged(year:),
                onSelectedCountryTapped: onSelectedCountryTapped
            )
        }
        .onAppear {
            viewModel.onAppear()
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
        AtlasScreen(
            viewModel: HomePreviewFactory.makeViewModel(),
            onSelectedCountryTapped: { _ in }
        )
            .environment(\.locale, Locale(identifier: localeIdentifier))
            .environment(\.layoutDirection, layoutDirection)
    }
}
#endif
