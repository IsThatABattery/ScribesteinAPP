import SwiftUI

// MARK: - Color Tokens

enum SColor {
    // Surfaces (used as fallback tints behind glass)
    static let background = Color("Surface/Background")
    static let surface = Color("Surface/Default")
    static let surfaceAlt = Color("Surface/Alt")
    static let surfaceActive = Color("Surface/Active")

    // Text
    static let text = Color("Text/Primary")
    static let textSecondary = Color("Text/Secondary")
    static let textMuted = Color("Text/Muted")

    // Brand accents
    static let accent = Color("Brand/Gold/600")
    static let accentSoft = Color("Brand/Gold/500")
    static let accentOn = Color("Brand/Navy/1000")
    static let blue = Color("Brand/Blue/500")
    static let blueBright = Color("Brand/Blue/600")

    // Strokes
    static let stroke = Color("Stroke/Primary")
    static let strokeStrong = Color("Stroke/Strong")

    // Semantic states
    static let success = Color("State/Success")
    static let warning = Color("State/Warning")
    static let danger = Color("State/Danger")
    static let info = Color("State/Info")

    // Glass-specific
    static let glassBorder = Color.white.opacity(0.15)
    static let glassBorderGold = Color("Brand/Gold/600").opacity(0.2)
    static let glassHighlight = Color.white.opacity(0.08)
}

// MARK: - Spacing Scale

enum SSpace: CGFloat {
    case xxs = 4
    case xs = 8
    case s = 12
    case m = 16
    case l = 24
    case xl = 32
    case xxl = 48
    case xxxl = 64
}

// MARK: - Corner Radii (updated for glass aesthetic)

enum SRadius: CGFloat {
    case tight = 8
    case standard = 16
    case loose = 24
}

// MARK: - Glass Background Gradient

struct GlassBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color("Brand/Navy/1000"),
                Color("Brand/Navy/950"),
                Color("Brand/Navy/900").opacity(0.8),
                Color("Brand/Blue/600").opacity(0.15),
                Color("Brand/Navy/1000")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Glass Card Component

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = SRadius.standard.rawValue
    var borderColor: Color = SColor.glassBorder
    var padding: CGFloat = SSpace.m.rawValue
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .glassBackground(cornerRadius: cornerRadius, borderColor: borderColor)
    }
}

// MARK: - Glass Background Modifier

struct GlassBackgroundModifier: ViewModifier {
    var cornerRadius: CGFloat = SRadius.standard.rawValue
    var borderColor: Color = SColor.glassBorder

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .glassEffect(.regular.tint(SColor.background.opacity(0.3)), in: .rect(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(borderColor, lineWidth: 0.5)
                )
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(borderColor, lineWidth: 0.5)
                )
        }
    }
}

extension View {
    func glassBackground(cornerRadius: CGFloat = SRadius.standard.rawValue, borderColor: Color = SColor.glassBorder) -> some View {
        modifier(GlassBackgroundModifier(cornerRadius: cornerRadius, borderColor: borderColor))
    }
}

// MARK: - Button Styles

struct SButtonPrimary: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .default))
            .fontWeight(.semibold)
            .foregroundStyle(SColor.accentOn)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                SColor.accent.opacity(configuration.isPressed ? 0.85 : 1.0),
                in: RoundedRectangle(cornerRadius: SRadius.tight.rawValue, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SButtonSecondary: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .default))
            .fontWeight(.semibold)
            .foregroundStyle(SColor.accent)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .glassBackground(cornerRadius: SRadius.tight.rawValue, borderColor: SColor.glassBorderGold)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SButtonTertiary: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.callout, design: .default))
            .fontWeight(.medium)
            .foregroundStyle(SColor.accent.opacity(configuration.isPressed ? 0.7 : 1.0))
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
    }
}

// MARK: - Input Field Modifier

struct SInputFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: SRadius.tight.rawValue, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SRadius.tight.rawValue, style: .continuous)
                    .stroke(SColor.glassBorder, lineWidth: 0.5)
            )
            .foregroundStyle(SColor.text)
    }
}

extension View {
    func sInputStyle() -> some View {
        modifier(SInputFieldModifier())
    }
}

// MARK: - Section Header Style

struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(SColor.textSecondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

extension View {
    func sectionHeaderStyle() -> some View {
        modifier(SectionHeaderStyle())
    }
}
