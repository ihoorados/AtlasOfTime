import SwiftUI

struct HomeScene: View {
    @ObservedObject var viewModel: AtlasViewModel
    let makeCountryDetailScene: (HistoricalCountrySnapshot) -> CountryDetailScene
    @State private var selectedDetailSnapshot: HistoricalCountrySnapshot?

    var body: some View {
        NavigationStack {
            AtlasScreen(
                viewModel: viewModel,
                onSelectedCountryTapped: { snapshot in
                    selectedDetailSnapshot = snapshot
                }
            )
            .navigationDestination(item: $selectedDetailSnapshot) { snapshot in
                makeCountryDetailScene(snapshot)
            }
        }
    }
}

#if DEBUG
struct HomeScene_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        HomeScene(
            viewModel: HomePreviewFactory.makeViewModel(),
            makeCountryDetailScene: HomePreviewFactory.makeCountryDetailScene(snapshot:)
        )
    }
}
#endif
