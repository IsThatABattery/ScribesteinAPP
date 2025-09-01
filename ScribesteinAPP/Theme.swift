import SwiftUI

enum SColor {
    static let background = Color("Surface/Background")
    static let surface = Color("Surface/Default")
    static let surfaceAlt = Color("Surface/Alt")
    static let surfaceActive = Color("Surface/Active")

    static let text = Color("Text/Primary")
    static let textSecondary = Color("Text/Secondary")
    static let textMuted = Color("Text/Muted")

    static let accent = Color("Brand/Gold/600")
    static let accentOn = Color("Brand/Navy/1000")

    static let stroke = Color("Stroke/Primary")
    static let strokeStrong = Color("Stroke/Strong")

    static let success = Color("State/Success")
    static let warning = Color("State/Warning")
    static let danger = Color("State/Danger")
    static let info = Color("State/Info")
}

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

enum SRadius: CGFloat {
    case tight = 4
    case standard = 6
    case loose = 8
}

struct SButtonPrimary: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .default))
            .fontWeight(.semibold)
            .foregroundStyle(SColor.accentOn)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(SColor.accent.opacity(configuration.isPressed ? 0.9 : 1.0))
            .clipShape(RoundedRectangle(cornerRadius: SRadius.standard.rawValue, style: .continuous))
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
            .background(SColor.surface)
            .overlay(
                RoundedRectangle(cornerRadius: SRadius.standard.rawValue, style: .continuous)
                    .stroke(SColor.accent.opacity(configuration.isPressed ? 1.0 : 0.9), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: SRadius.standard.rawValue, style: .continuous))
    }
}

struct SButtonTertiary: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.callout, design: .default))
            .fontWeight(.medium)
            .foregroundStyle(SColor.accent.opacity(configuration.isPressed ? 0.8 : 1.0))
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
    }
}

struct SInputFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(SColor.surfaceAlt)
            .overlay(
                RoundedRectangle(cornerRadius: SRadius.standard.rawValue, style: .continuous)
                    .stroke(SColor.stroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: SRadius.standard.rawValue, style: .continuous))
            .foregroundStyle(SColor.text)
    }
}

extension View {
    func sInputStyle() -> some View {
        modifier(SInputFieldModifier())
    }
}


