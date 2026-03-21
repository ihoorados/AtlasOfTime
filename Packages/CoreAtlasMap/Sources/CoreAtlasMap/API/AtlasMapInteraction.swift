import Foundation

public struct AtlasMapInteraction: Sendable {
    public let selectedFeatureID: String?
    public let onSelectionChanged: @Sendable (String?) -> Void

    public init(
        selectedFeatureID: String?,
        onSelectionChanged: @escaping @Sendable (String?) -> Void
    ) {
        self.selectedFeatureID = selectedFeatureID
        self.onSelectionChanged = onSelectionChanged
    }
}
