import Foundation
import SwiftUI

@MainActor
public protocol AtlasMapViewFactory {
    func makeMapView(
        snapshot: AtlasMapSnapshot?,
        camera: AtlasMapCameraState,
        interaction: AtlasMapInteraction
    ) -> AnyView
}
