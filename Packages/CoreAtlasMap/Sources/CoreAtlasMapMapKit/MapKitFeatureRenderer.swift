import CoreAtlasMap
import MapKit

#if canImport(UIKit)
import UIKit
typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
typealias PlatformColor = NSColor
#endif

final class MapKitFeatureRenderer: MKPolygonRenderer {
    init(
        polygon: MKPolygon,
        style: AtlasMapFeatureStyle,
        isSelected: Bool
    ) {
        self.style = style
        super.init(polygon: polygon)

        applySelection(isSelected)
        lineJoin = .round
        lineCap = .round
        lineDashPattern = dashPatternForStrokeKind(style.strokeKind)
    }

    func applySelection(_ isSelected: Bool) {
        fillColor = isSelected ? selectedFillColor : atlasFillColor
        strokeColor = isSelected ? selectedStrokeColor : atlasStrokeColor
        lineWidth = isSelected ? 2.6 : lineWidthForStrokeKind(style.strokeKind)
        alpha = isSelected ? 1.0 : alphaForStrokeKind(style.strokeKind)
        setNeedsDisplay()
    }

    @available(*, unavailable)
    override init(polygon: MKPolygon) {
        fatalError("Use init(polygon:style:isSelected:)")
    }

    private let style: AtlasMapFeatureStyle

    private func lineWidthForStrokeKind(_ strokeKind: AtlasMapFeatureStyle.StrokeKind) -> CGFloat {
        switch strokeKind {
        case .precise:
            1.15
        case .approximate:
            1.3
        case .uncertain:
            1.5
        case .zone:
            1.8
        }
    }

    private func alphaForStrokeKind(_ strokeKind: AtlasMapFeatureStyle.StrokeKind) -> CGFloat {
        switch strokeKind {
        case .precise:
            0.9
        case .approximate:
            0.88
        case .uncertain:
            0.82
        case .zone:
            0.72
        }
    }

    private func dashPatternForStrokeKind(_ strokeKind: AtlasMapFeatureStyle.StrokeKind) -> [NSNumber]? {
        switch strokeKind {
        case .precise, .approximate:
            nil
        case .uncertain:
            [5, 4]
        case .zone:
            [3, 4]
        }
    }

    #if canImport(UIKit)
    private var atlasStrokeColor: PlatformColor {
        PlatformColor { traits in
            if traits.userInterfaceStyle == .dark {
                return PlatformColor(red: 0.90, green: 0.84, blue: 0.72, alpha: 0.54)
            }
            return PlatformColor(red: 0.26, green: 0.20, blue: 0.12, alpha: 0.58)
        }
    }

    private var atlasFillColor: PlatformColor {
        PlatformColor { traits in
            let alpha: CGFloat
            switch self.style.fillKind {
            case .none:
                alpha = 0
            case .subtle:
                alpha = traits.userInterfaceStyle == .dark ? 0.025 : 0.03
            case .strong:
                alpha = traits.userInterfaceStyle == .dark ? 0.14 : 0.12
            }

            if traits.userInterfaceStyle == .dark {
                return PlatformColor(red: 0.82, green: 0.70, blue: 0.50, alpha: alpha)
            }
            return PlatformColor(red: 0.54, green: 0.40, blue: 0.18, alpha: alpha)
        }
    }

    private var selectedStrokeColor: PlatformColor {
        PlatformColor { traits in
            if traits.userInterfaceStyle == .dark {
                return PlatformColor(red: 0.99, green: 0.94, blue: 0.82, alpha: 1.0)
            }
            return PlatformColor(red: 0.48, green: 0.31, blue: 0.11, alpha: 1.0)
        }
    }

    private var selectedFillColor: PlatformColor {
        PlatformColor { traits in
            if traits.userInterfaceStyle == .dark {
                return PlatformColor(red: 0.92, green: 0.78, blue: 0.50, alpha: 0.24)
            }
            return PlatformColor(red: 0.80, green: 0.60, blue: 0.22, alpha: 0.22)
        }
    }
    #elseif canImport(AppKit)
    private var atlasStrokeColor: PlatformColor {
        PlatformColor(calibratedRed: 0.26, green: 0.20, blue: 0.12, alpha: 0.58)
    }

    private var atlasFillColor: PlatformColor {
        let alpha: CGFloat
        switch style.fillKind {
        case .none:
            alpha = 0
        case .subtle:
            alpha = 0.03
        case .strong:
            alpha = 0.12
        }
        return PlatformColor(calibratedRed: 0.54, green: 0.40, blue: 0.18, alpha: alpha)
    }

    private var selectedStrokeColor: PlatformColor {
        PlatformColor(calibratedRed: 0.48, green: 0.31, blue: 0.11, alpha: 1.0)
    }

    private var selectedFillColor: PlatformColor {
        PlatformColor(calibratedRed: 0.80, green: 0.60, blue: 0.22, alpha: 0.22)
    }
    #endif
}
