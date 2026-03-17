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
        lineWidth = isSelected ? 2.0 : 1.4
        lineJoin = .round
        lineCap = .round
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
                return PlatformColor(red: 0.96, green: 0.90, blue: 0.78, alpha: 0.78)
            }
            return PlatformColor(red: 0.28, green: 0.22, blue: 0.14, alpha: 0.82)
        }
    }

    private var atlasFillColor: PlatformColor {
        PlatformColor { traits in
            if traits.userInterfaceStyle == .dark {
                return PlatformColor(red: 0.88, green: 0.76, blue: 0.56, alpha: 0.05)
            }
            return PlatformColor(red: 0.56, green: 0.42, blue: 0.20, alpha: 0.06)
        }
    }

    private var selectedStrokeColor: PlatformColor {
        PlatformColor { traits in
            if traits.userInterfaceStyle == .dark {
                return PlatformColor(red: 0.98, green: 0.93, blue: 0.82, alpha: 0.96)
            }
            return PlatformColor(red: 0.42, green: 0.28, blue: 0.12, alpha: 0.96)
        }
    }

    private var selectedFillColor: PlatformColor {
        PlatformColor { traits in
            if traits.userInterfaceStyle == .dark {
                return PlatformColor(red: 0.90, green: 0.76, blue: 0.48, alpha: 0.18)
            }
            return PlatformColor(red: 0.76, green: 0.58, blue: 0.24, alpha: 0.18)
        }
    }
    #elseif canImport(AppKit)
    private var atlasStrokeColor: PlatformColor {
        if #available(macOS 10.14, *) {
            return PlatformColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                if isDark {
                    return PlatformColor(calibratedRed: 0.96, green: 0.90, blue: 0.78, alpha: 0.78)
                }
                return PlatformColor(calibratedRed: 0.28, green: 0.22, blue: 0.14, alpha: 0.82)
            }
        }

        return PlatformColor(calibratedRed: 0.28, green: 0.22, blue: 0.14, alpha: 0.82)
    }

    private var atlasFillColor: PlatformColor {
        if #available(macOS 10.14, *) {
            return PlatformColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                if isDark {
                    return PlatformColor(calibratedRed: 0.88, green: 0.76, blue: 0.56, alpha: 0.05)
                }
                return PlatformColor(calibratedRed: 0.56, green: 0.42, blue: 0.20, alpha: 0.06)
            }
        }

        return PlatformColor(calibratedRed: 0.56, green: 0.42, blue: 0.20, alpha: 0.06)
    }

    private var selectedStrokeColor: PlatformColor {
        if #available(macOS 10.14, *) {
            return PlatformColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                if isDark {
                    return PlatformColor(calibratedRed: 0.98, green: 0.93, blue: 0.82, alpha: 0.96)
                }
                return PlatformColor(calibratedRed: 0.42, green: 0.28, blue: 0.12, alpha: 0.96)
            }
        }

        return PlatformColor(calibratedRed: 0.42, green: 0.28, blue: 0.12, alpha: 0.96)
    }

    private var selectedFillColor: PlatformColor {
        if #available(macOS 10.14, *) {
            return PlatformColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                if isDark {
                    return PlatformColor(calibratedRed: 0.90, green: 0.76, blue: 0.48, alpha: 0.18)
                }
                return PlatformColor(calibratedRed: 0.76, green: 0.58, blue: 0.24, alpha: 0.18)
            }
        }

        return PlatformColor(calibratedRed: 0.76, green: 0.58, blue: 0.24, alpha: 0.18)
    }
    #endif
}
