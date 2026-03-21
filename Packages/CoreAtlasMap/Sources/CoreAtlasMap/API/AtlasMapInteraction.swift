import Foundation

public struct AtlasMapInteraction: Sendable {
    public let selectedFeatureID: String?
    public let onSelectionChanged: @MainActor @Sendable (String?) -> Void

    public init(
        selectedFeatureID: String?,
        onSelectionChanged: @escaping @MainActor @Sendable (String?) -> Void
    ) {
        self.selectedFeatureID = selectedFeatureID
        self.onSelectionChanged = onSelectionChanged
    }
}
