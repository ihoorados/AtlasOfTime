import CoreAtlasMap
import SwiftUI

@MainActor
public struct MapKitAtlasMapViewFactory: AtlasMapViewFactory {
    public init() {}

    public func makeMapView(
        state: AtlasMapViewState,
        onSelectionChanged: @escaping @MainActor @Sendable (String?) -> Void,
        onPointAnnotationSelectionChanged: @escaping @MainActor @Sendable (String?) -> Void
    ) -> AnyView {
        AnyView(
            MapKitAtlasMapView(
                state: state,
                onSelectionChanged: onSelectionChanged,
                onPointAnnotationSelectionChanged: onPointAnnotationSelectionChanged
            )
        )
    }
}
