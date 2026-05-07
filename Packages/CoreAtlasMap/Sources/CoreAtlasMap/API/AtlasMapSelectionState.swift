import Foundation

public struct AtlasMapSelectionState: Sendable, Equatable {
    public let selectedFeatureID: String?
    public let selectedPointAnnotationID: String?

    public init(
        selectedFeatureID: String? = nil,
        selectedPointAnnotationID: String? = nil
    ) {
        self.selectedFeatureID = selectedFeatureID
        self.selectedPointAnnotationID = selectedPointAnnotationID
    }
}
