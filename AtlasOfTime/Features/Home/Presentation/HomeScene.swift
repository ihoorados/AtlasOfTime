import SwiftUI

struct HomeScene: View {
    @ObservedObject var viewModel: AtlasViewModel
    let onSelectedCountryTapped: (HistoricalCountrySnapshot) -> Void

    var body: some View {
        AtlasScreen(
            viewModel: viewModel,
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
            onSelectedCountryTapped: { _ in }
        )
    }
}
#endif
