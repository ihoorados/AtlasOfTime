import Foundation

// Lightweight blueprint for feature-level DI containers.
@MainActor
protocol FeatureDIContainerBlueprint {
    associatedtype FeatureViewModel
    func makeFeatureViewModel() -> FeatureViewModel
}

