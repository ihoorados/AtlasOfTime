import Foundation
import SwiftUI

@MainActor
public protocol AtlasMapViewFactory {
    func makeMapView(
        state: AtlasMapViewState,
        onSelectionChanged: @escaping @MainActor @Sendable (String?) -> Void,
        onPointAnnotationSelectionChanged: @escaping @MainActor @Sendable (String?) -> Void
    ) -> AnyView
}
