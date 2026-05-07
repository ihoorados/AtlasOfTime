import CoreAtlasMap
import SwiftUI
import CoreAtlasDomain

struct AtlasScreen: View {
    @ObservedObject var viewModel: AtlasViewModel
    let mapViewFactory: any AtlasMapViewFactory
    let onSelectedCountryTapped: (HistoricalCountrySnapshot) -> Void
    @Environment(\.atlasShowLoadingIndicator) private var showLoadingIndicator
    private let mapSnapshotMapper = AtlasMapSnapshotMapper()

    var body: some View {
        ZStack(alignment: .bottom) {
            mapViewFactory.makeMapView(
                state: AtlasMapViewState(
                    snapshot: mapSnapshotMapper.makeSnapshot(
                        from: viewModel.renderSnapshot,
                        pointsOfInterest: viewModel.showsPointsOfInterest ? viewModel.pointsOfInterest : [],
                        selectedCountryID: viewModel.selectedCountryID,
                        selectedPOIID: viewModel.showsPointsOfInterest ? viewModel.selectedPOIID : nil
                    ),
                    camera: .world,
                    selection: AtlasMapSelectionState(
                        selectedFeatureID: viewModel.selectedCountryID,
                        selectedPointAnnotationID: viewModel.showsPointsOfInterest ? viewModel.selectedPOIID : nil
                    ),
                    options: AtlasMapViewOptions(
                        showsLabels: true,
                        allowsSelection: true,
                        allowsZoom: true,
                        allowsPan: true
                    )
                ),
                onSelectionChanged: viewModel.selectCountry(id:),
                onPointAnnotationSelectionChanged: viewModel.selectPOI(id:)
            )
                .ignoresSafeArea()

            controlPanel
                .frame(maxWidth: controlPanelMaxWidth, alignment: .bottom)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    private var controlPanel: some View {
        AtlasControlPanelView(
            displayYear: viewModel.displayYear,
            availableYears: viewModel.availableYears,
            isLoading: viewModel.isLoading,
            showLoadingIndicator: showLoadingIndicator,
            showsPointsOfInterest: Binding(
                get: { viewModel.showsPointsOfInterest },
                set: { viewModel.showsPointsOfInterest = $0 }
            ),
            selectedCountrySnapshot: viewModel.selectedCountrySnapshot,
            selectedCountryBorderConfidenceText: viewModel.selectedCountryBorderConfidenceText,
            selectedCountrySourceCount: viewModel.selectedCountrySourceCount,
            selectedPOI: viewModel.showsPointsOfInterest ? viewModel.selectedPOI : nil,
            selectedPOIConfidenceText: viewModel.selectedPOIConfidenceText,
            selectedPOISourceCount: viewModel.selectedPOISourceCount,
            visibleSnapshots: viewModel.visibleSnapshots,
            selectedCountryID: viewModel.selectedCountryID,
            errorMessage: viewModel.errorMessage,
            onYearChanged: viewModel.onYearChanged(year:),
            onSelectedCountryTapped: onSelectedCountryTapped,
            onSelectedPOIDismissed: { viewModel.selectPOI(id: nil) }
        )
    }

    private var controlPanelMaxWidth: CGFloat? {
        #if os(macOS)
        680
        #else
        nil
        #endif
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
            mapViewFactory: HomePreviewFactory.makeMapViewFactory(),
            onSelectedCountryTapped: { _ in }
        )
            .environment(\.locale, Locale(identifier: localeIdentifier))
            .environment(\.layoutDirection, layoutDirection)
    }
}
#endif
