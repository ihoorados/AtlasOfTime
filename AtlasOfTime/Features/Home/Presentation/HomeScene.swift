import SwiftUI

struct HomeScene: View {
    @ObservedObject var viewModel: AtlasViewModel

    var body: some View {
        AtlasScreen(viewModel: viewModel)
    }
}

#if DEBUG
struct HomeScene_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        HomeScene(viewModel: HomePreviewFactory.makeViewModel())
    }
}
#endif
