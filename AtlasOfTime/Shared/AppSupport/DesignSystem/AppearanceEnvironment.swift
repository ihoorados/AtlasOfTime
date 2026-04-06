import CoreAtlasAppSettings
import SwiftUI

extension EnvironmentValues {
    var atlasAppearance: CoreAtlasAppSettings.AppAppearanceOption {
        get { self[AtlasAppearanceKey.self] }
        set { self[AtlasAppearanceKey.self] = newValue }
    }

    var atlasGlassEnabled: Bool {
        get { self[AtlasGlassEnabledKey.self] }
        set { self[AtlasGlassEnabledKey.self] = newValue }
    }

    var atlasTheme: AtlasTheme {
        get { self[AtlasThemeKey.self] }
        set { self[AtlasThemeKey.self] = newValue }
    }
}

private struct AtlasAppearanceKey: EnvironmentKey {
    static let defaultValue: CoreAtlasAppSettings.AppAppearanceOption = .system
}

private struct AtlasGlassEnabledKey: EnvironmentKey {
    static let defaultValue = true
}

private struct AtlasThemeKey: EnvironmentKey {
    static let defaultValue = AtlasTheme.resolve(colorScheme: .light, glassEnabled: true)
}

struct AtlasCardSurfaceModifier: ViewModifier {
    @Environment(\.atlasGlassEnabled) private var atlasGlassEnabled
    @Environment(\.atlasTheme) private var theme

    let cornerRadius: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26, *), atlasGlassEnabled {
            content
                .compositingGroup()
                .glassEffect(.regular.tint(theme.glassTint), in: .rect(cornerRadius: cornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(theme.panelStroke, lineWidth: 1)
                }
        } else {
            content
                .background(
                    theme.panelFallbackFill,
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(theme.panelStroke, lineWidth: 1)
                }
        }
    }
}

extension View {
    func atlasCardSurface(cornerRadius: CGFloat = 20) -> some View {
        modifier(AtlasCardSurfaceModifier(cornerRadius: cornerRadius))
    }
}
