import SwiftUI

extension EnvironmentValues {
    var atlasShowYearRangeLabels: Bool {
        get { self[AtlasShowYearRangeLabelsKey.self] }
        set { self[AtlasShowYearRangeLabelsKey.self] = newValue }
    }

    var atlasShowLoadingIndicator: Bool {
        get { self[AtlasShowLoadingIndicatorKey.self] }
        set { self[AtlasShowLoadingIndicatorKey.self] = newValue }
    }
}

private struct AtlasShowYearRangeLabelsKey: EnvironmentKey {
    static let defaultValue = true
}

private struct AtlasShowLoadingIndicatorKey: EnvironmentKey {
    static let defaultValue = true
}
