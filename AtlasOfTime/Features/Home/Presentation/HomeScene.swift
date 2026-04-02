import CoreAtlasMap
import SwiftUI

struct HomeScene: View {
    @ObservedObject var viewModel: AtlasViewModel
    let mapViewFactory: any AtlasMapViewFactory
    let onSelectedCountryTapped: (HistoricalCountrySnapshot) -> Void

    var body: some View {
        AtlasScreen(
            viewModel: viewModel,
            mapViewFactory: mapViewFactory,
            onSelectedCountryTapped: onSelectedCountryTapped
        )
    }
}

#if DEBUG
struct HomeScene_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        HomeScene(
            viewModel: HomePreviewFactory.makeViewModel(),
            mapViewFactory: HomePreviewFactory.makeMapViewFactory(),
            onSelectedCountryTapped: { _ in }
        )
    }
}
#endif
