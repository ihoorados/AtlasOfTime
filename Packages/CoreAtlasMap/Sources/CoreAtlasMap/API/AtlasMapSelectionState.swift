import Foundation

public struct AtlasMapSelectionState: Sendable, Equatable {
    public let selectedFeatureID: String?

    public init(selectedFeatureID: String? = nil) {
        self.selectedFeatureID = selectedFeatureID
    }
}
