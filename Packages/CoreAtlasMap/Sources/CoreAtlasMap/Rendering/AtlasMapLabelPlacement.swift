import Foundation

public struct AtlasMapLabelPlacement: Sendable {
    public let minimumFeatureAreaForLabel: Double

    public init(minimumFeatureAreaForLabel: Double = 0.05) {
        self.minimumFeatureAreaForLabel = minimumFeatureAreaForLabel
    }

    public func makeLabel(for feature: AtlasMapFeature) -> AtlasMapLabel? {
        let trimmedTitle = feature.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty,
              let polygon = largestPolygon(in: feature.polygons),
              AtlasMapGeometryMetrics.approximateArea(of: polygon) >= minimumFeatureAreaForLabel,
              let coordinate = AtlasMapGeometryMetrics.representativeCoordinate(for: polygon) else {
            return nil
        }

        return AtlasMapLabel(
            id: feature.id,
            title: trimmedTitle,
            coordinate: coordinate,
            emphasis: feature.style.emphasis == .selected ? .selected : .normal
        )
    }

    private func largestPolygon(in polygons: [AtlasMapPolygon]) -> AtlasMapPolygon? {
        polygons.max { lhs, rhs in
            AtlasMapGeometryMetrics.approximateArea(of: lhs) < AtlasMapGeometryMetrics.approximateArea(of: rhs)
        }
    }
}
