import CoreAtlasMap
import SwiftUI

@MainActor
public struct MapKitAtlasMapViewFactory: AtlasMapViewFactory {
    public init() {}

    public func makeMapView(
        snapshot: AtlasMapSnapshot?,
        camera: AtlasMapCameraState,
        interaction: AtlasMapInteraction
    ) -> AnyView {
        AnyView(
            MapKitAtlasMapView(
                snapshot: snapshot,
                camera: camera,
                interaction: interaction
            )
        )
    }
}
