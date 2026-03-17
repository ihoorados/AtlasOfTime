import MapKit

#if canImport(UIKit)
import UIKit
public typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias PlatformColor = NSColor
#endif

final class BorderOverlayRenderer: MKPolygonRenderer {
    init(polygon: MKPolygon, isSelected: Bool) {
        self.isSelected = isSelected
        super.init(polygon: polygon)
        fillColor = isSelected ? selectedFillColor : atlasFillColor
        #if canImport(UIKit)
        strokeColor = isSelected ? selectedStrokeColor : atlasStrokeColor
        #elseif canImport(AppKit)
        strokeColor = isSelected ? selectedStrokeColor : atlasStrokeColor
        #endif
        lineWidth = isSelected ? 2.6 : 1.15
        lineJoin = .round
        lineCap = .round
        alpha = isSelected ? 1.0 : 0.88
    }

    @available(*, unavailable)
    override init(polygon: MKPolygon) {
        fatalError("Use init(polygon:isSelected:)")
    }

    private let isSelected: Bool

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
            if traits.userInterfaceStyle == .dark {
                return PlatformColor(red: 0.82, green: 0.70, blue: 0.50, alpha: 0.025)
            }
            return PlatformColor(red: 0.54, green: 0.40, blue: 0.18, alpha: 0.03)
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
        if #available(macOS 10.14, *) {
            return PlatformColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                if isDark {
                    return PlatformColor(calibratedRed: 0.90, green: 0.84, blue: 0.72, alpha: 0.54)
                }
                return PlatformColor(calibratedRed: 0.26, green: 0.20, blue: 0.12, alpha: 0.58)
            }
        }

        return PlatformColor(calibratedRed: 0.26, green: 0.20, blue: 0.12, alpha: 0.58)
    }

    private var atlasFillColor: PlatformColor {
        if #available(macOS 10.14, *) {
            return PlatformColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                if isDark {
                    return PlatformColor(calibratedRed: 0.82, green: 0.70, blue: 0.50, alpha: 0.025)
                }
                return PlatformColor(calibratedRed: 0.54, green: 0.40, blue: 0.18, alpha: 0.03)
            }
        }

        return PlatformColor(calibratedRed: 0.54, green: 0.40, blue: 0.18, alpha: 0.03)
    }

    private var selectedStrokeColor: PlatformColor {
        if #available(macOS 10.14, *) {
            return PlatformColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                if isDark {
                    return PlatformColor(calibratedRed: 0.99, green: 0.94, blue: 0.82, alpha: 1.0)
                }
                return PlatformColor(calibratedRed: 0.48, green: 0.31, blue: 0.11, alpha: 1.0)
            }
        }

        return PlatformColor(calibratedRed: 0.48, green: 0.31, blue: 0.11, alpha: 1.0)
    }

    private var selectedFillColor: PlatformColor {
        if #available(macOS 10.14, *) {
            return PlatformColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                if isDark {
                    return PlatformColor(calibratedRed: 0.92, green: 0.78, blue: 0.50, alpha: 0.24)
                }
                return PlatformColor(calibratedRed: 0.80, green: 0.60, blue: 0.22, alpha: 0.22)
            }
        }

        return PlatformColor(calibratedRed: 0.80, green: 0.60, blue: 0.22, alpha: 0.22)
    }
    #endif
}
