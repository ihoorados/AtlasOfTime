import SwiftUI

extension EnvironmentValues {
    var atlasAppearance: AppAppearanceOption {
        get { self[AtlasAppearanceKey.self] }
        set { self[AtlasAppearanceKey.self] = newValue }
    }

    var atlasGlassEnabled: Bool {
        get { self[AtlasGlassEnabledKey.self] }
        set { self[AtlasGlassEnabledKey.self] = newValue }
    }
}

private struct AtlasAppearanceKey: EnvironmentKey {
    static let defaultValue: AppAppearanceOption = .system
}

private struct AtlasGlassEnabledKey: EnvironmentKey {
    static let defaultValue = true
}

struct AtlasCardSurfaceModifier: ViewModifier {
    @Environment(\.atlasGlassEnabled) private var atlasGlassEnabled

    let cornerRadius: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26, *), atlasGlassEnabled {
            content
                .compositingGroup()
                .glassEffect(.regular.tint(.white.opacity(0.08)), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(
                    .thinMaterial,
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
        }
    }
}

extension View {
    func atlasCardSurface(cornerRadius: CGFloat = 20) -> some View {
        modifier(AtlasCardSurfaceModifier(cornerRadius: cornerRadius))
    }
}
