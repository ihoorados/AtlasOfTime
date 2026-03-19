import SwiftUI

@MainActor
final class AppDestinationFactory {
    private let atlasFeatureContainer: AtlasFeatureDIContainer

    init(atlasFeatureContainer: AtlasFeatureDIContainer) {
        self.atlasFeatureContainer = atlasFeatureContainer
    }

    func makeCountryDetailScene(
        snapshot: HistoricalCountrySnapshot
    ) -> CountryDetailScene {
        atlasFeatureContainer.makeCountryDetailScene(snapshot: snapshot)
    }
}
