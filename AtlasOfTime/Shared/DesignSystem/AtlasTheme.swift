import SwiftUI

struct AtlasTheme: Sendable {
    let glassTint: Color
    let panelFallbackFill: Color
    let panelStroke: Color
    let groupedBackground: Color
    let selectionFill: Color
    let subtleFill: Color
    let primaryText: Color
    let secondaryText: Color

    static func resolve(
        colorScheme: ColorScheme,
        glassEnabled: Bool
    ) -> AtlasTheme {
        switch colorScheme {
        case .dark:
            return AtlasTheme(
                glassTint: glassEnabled ? .white.opacity(0.10) : .white.opacity(0.04),
                panelFallbackFill: Color.white.opacity(0.08),
                panelStroke: Color.white.opacity(0.10),
                groupedBackground: Color.black.opacity(0.16),
                selectionFill: Color.white.opacity(0.18),
                subtleFill: Color.white.opacity(0.09),
                primaryText: .white,
                secondaryText: Color.white.opacity(0.70)
            )
        case .light:
            return AtlasTheme(
                glassTint: glassEnabled ? .white.opacity(0.16) : .white.opacity(0.10),
                panelFallbackFill: Color.white.opacity(0.88),
                panelStroke: Color.black.opacity(0.06),
                groupedBackground: Color.black.opacity(0.04),
                selectionFill: Color.primary.opacity(0.12),
                subtleFill: Color.black.opacity(0.06),
                primaryText: .primary,
                secondaryText: .secondary
            )
        @unknown default:
            return AtlasTheme.resolve(colorScheme: .light, glassEnabled: glassEnabled)
        }
    }
}
