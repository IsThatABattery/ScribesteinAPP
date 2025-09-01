Scribestein — Design System

Last updated: 2025-08-13
Owner: Design + iOS

## Vision
A disciplined, editorial interface for fraternity operations. Dark navy surfaces with precise gold accents. Crisp edges, subtle elevation, clear hierarchy. Avoid the default iOS “bubble” look: no oversized corner radii, no pill buttons, no frothy shadows.

## Brand Principles
- Authority over whimsy
- Precision over decoration
- Editorial hierarchy over chrome
- Gold is precious: use sparingly to guide action

## Color System (Dark-first)

### Brand Palette
- Navy 1000: #060D1A — app background
- Navy 950: #0A162B — primary surface
- Navy 900: #0F1F3D — elevated surface
- Navy 800: #14284D — interactive hover/pressed surface
- Gold 600: #C49A2A — primary accent (actions, focus)
- Gold 500: #D4AF37 — accent hover/focus ring
- Slate 500: #8FA1C1 — secondary text
- Slate 300: #C1CBE0 — muted text/placeholder
- Slate 200: #D6DEEF — hairlines on dark
- Success: #2ED573
- Warning: #F1C40F
- Danger: #FF6B6B
- Info: #2FA4F5

### Semantic Tokens
- Background: Navy 1000
- Surface: Navy 950
- Surface/Alt (elevated): Navy 900
- Surface/Active: Navy 800
- Stroke/Primary: rgba(214, 222, 239, 0.12) over dark
- Stroke/Strong: rgba(214, 222, 239, 0.22)
- Text/Primary: #E8EEF9
- Text/Secondary: Slate 500
- Text/Muted: Slate 300
- Accent/Fill: Gold 600
- Accent/On: Navy 1000
- Focus Ring: Gold 500 at 2pt
- Link: Gold 500
- Success/Fill: Success
- Danger/Fill: Danger
- Warning/Fill: Warning

Rules:
- Maintain ≥ 4.5:1 contrast for all body text.
- Use gold primarily for CTAs, selection indicators, and focus—not general text.

## Typography

- Primary: SF Pro Text
- Alternate for headings (editorial): New York (serif) where available
- Weights: Regular, Medium, Semibold
- Sizes (dynamic type aware):
  - Display: 34/40
  - Title: 28/34
  - Headline: 20/26
  - Body: 17/24
  - Callout: 16/22
  - Footnote: 13/18
  - Caption: 12/16
- Numerics: Monospaced digits for ledger-like content
- Line height: generous; avoid cramping in dark mode

## Layout, Spacing, Radii, Elevation

- Grid: 8pt base (use 4pt for micro)
- Spacing scale: 4, 8, 12, 16, 24, 32, 48, 64
- Corner radii: 4 (tight), 6 (default), 8 (max). Avoid pills.
- Borders: 1px hairline on dark; 2px for emphasis/focus
- Elevation: favor borders and subtle overlays over heavy shadows; if used, soft ambient with low spread

## Components

### App Bar / Navigation
- Solid Surface background
- 1px bottom divider (Stroke/Primary)
- Title left-aligned; avoid large, floating headers
- Gold underline indicator for active tab if used

### Buttons
- Primary: Gold 600 fill, Navy 1000 text, radius 6, no pill
- Secondary: Outline (Gold 600 border, transparent fill), text Gold 600
- Tertiary: Text-only in Gold 500
- States: hover/pressed on dark via Surface/Active; disabled reduces alpha to ~0.4

### Text Fields
- Fill: Surface/Alt
- Border: 1px Stroke/Strong focused; 1px Stroke/Primary unfocused
- Caret and focus ring: Gold 500
- Radius 6, content insets 12/14

### List Row
- Full-width rows, minimal vertical spacing
- 1px dividers; use insets to align with text grid
- Selected state: Surface/Active background

### Card
- Surface/Alt background, 1px Stroke/Primary border, radius 6, minimal or no shadow

### Chip/Tag
- Radius 4
- Outline by default; filled for selected
- Use Gold 600 for active filters sparingly

### Tabs/Segmented
- Rectilinear segments; avoid pill segmented control
- Gold 600 2px bottom indicator line

### Toast/Banner
- Surface/Alt with 1px border; left stripe indicates status color

## Patterns

### Login
- Minimal, centered layout
- Title with serif Display, body in SF Pro
- Primary CTA: “Sign in with Google” in Gold 600
- Secondary “Continue as guest” as Tertiary

### Transcript Feed
- Header: “Transcripts” left, filters as outline chips
- Cells: title and date on top line; snippet below; right-aligned status tag
- Subtle divider between cells; no grouped/bubbly lists

### Transcript Detail
- Title (Title or Display), metadata line (date, author), content blocks with generous line height

## Interaction, Motion, Haptics

- Motion: subtle; ease-out for entrance, ease-in for exit; durations 120–200ms
- Haptics: light on critical actions (success, failure); none on passive taps
- Focus ring: 2pt Gold 500; do not rely on only color changes

## Accessibility

- Color contrast ≥ 4.5:1 for text, 3:1 for larger text
- Dynamic Type supported across components
- Min tap area: 44x44pt
- Reduce Motion respected
- VoiceOver: clear labels, traits, and value changes

## Asset Naming (XCAssets)

Color sets (dark appearance):
- Brand/Navy/1000
- Brand/Navy/950
- Brand/Navy/900
- Brand/Navy/800
- Brand/Gold/600
- Brand/Gold/500
- Text/Primary
- Text/Secondary
- Text/Muted
- Stroke/Primary
- Stroke/Strong
- State/Success
- State/Warning
- State/Danger
- State/Info
- Surface/Background
- Surface/Default
- Surface/Alt
- Surface/Active

## iOS Implementation Notes (SwiftUI)

Create a theme layer and use it consistently. Avoid per-view ad-hoc styling.

```swift
// ScribesteinAPP/Theme.swift
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
}

enum SSpace: CGFloat {
    case xxs = 4, xs = 8, s = 12, m = 16, l = 24, xl = 32, xxl = 48, xxxl = 64
}

enum SRadius: CGFloat {
    case tight = 4, standard = 6, loose = 8
}

struct SButtonPrimary: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .default, weight: .semibold))
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
            .font(.system(.headline, design: .default, weight: .semibold))
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
```

Navigation bar appearance:

```swift
// Apply once in App init
UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color("Text/Primary"))]
UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color("Text/Primary"))]
```

Example usage in views:

```swift
// Button usage
Button("Primary") {}
    .buttonStyle(SButtonPrimary())

Button("Secondary") {}
    .buttonStyle(SButtonSecondary())

// List row container
RoundedRectangle(cornerRadius: SRadius.standard.rawValue, style: .continuous)
    .fill(SColor.surface)
    .overlay(
        RoundedRectangle(cornerRadius: SRadius.standard.rawValue, style: .continuous)
            .stroke(SColor.stroke, lineWidth: 1)
    )
```

## Screen-specific Guidance

### Login
- Logo/title top-left or center; serif Display for “Scribestein”
- Primary CTA in gold; secondary actions as text links

### Transcript Feed
- Filter chips as outline; active filter gold-filled
- Date uses monospaced digits
- Avoid default grouped list chrome; use custom row containers with borders

### Transcript Detail
- Serif Title, body with comfortable line height
- Metadata row with secondary text and thin dividers

## Do / Don’t

- Do: use 4–8pt radii; 1px borders; left-aligned headers; restrained shadows
- Don’t: pill buttons, heavy frosted backgrounds, oversized corner radii, bubbly grouped lists

## Rollout Plan

1) Assets: add color sets to `Assets.xcassets` as named above
2) Theme: add `Theme.swift` and button styles; wire up environment
3) Apply: update `LoginView`, `TranscriptFeedView`, and `ContentView` to use theme tokens
4) QA: contrast checks, dynamic type, VoiceOver, RTL sanity pass
5) Polish: motion and haptics; focus rings; tab indicator

## Open Questions
- Do we want a serif Display across all headers or only landing screens?
- Custom logomark for Scribestein title?
- Light theme variant later?


