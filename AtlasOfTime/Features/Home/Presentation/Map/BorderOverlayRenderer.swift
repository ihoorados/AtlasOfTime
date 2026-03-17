import MapKit

#if canImport(UIKit)
import UIKit
public typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias PlatformColor = NSColor
#endif

final class BorderOverlayRenderer: MKPolygonRenderer {
    override init(polygon: MKPolygon) {
        super.init(polygon: polygon)
        fillColor = .clear
        #if canImport(UIKit)
        strokeColor = PlatformColor.label.withAlphaComponent(0.9)
        #elseif canImport(AppKit)
        // On macOS, use labelColor equivalent
        strokeColor = PlatformColor.labelColor.withAlphaComponent(0.9)
        #endif
        lineWidth = 1.0
        lineJoin = .round
        lineCap = .round
    }
}
