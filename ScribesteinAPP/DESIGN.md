Scribestein — Design System

Last updated: 2026-02-06
Owner: Design + iOS

## Vision
A liquid glass interface for fraternity operations. Translucent, layered panels float over deep navy-blue gradients with precise gold accents. The aesthetic is inspired by iOS 26's native glass effects: frosted materials, subtle borders, and depth through translucency. Blue and gold remain the brand pillars.

## Brand Principles
- Depth through translucency, not shadow
- Gold is precious: use sparingly to guide action
- Glass panels create hierarchy through layering
- Clean typography over frosted surfaces
- Native feel - use platform materials

## Color System

### Brand Palette
- Navy 1000: #060D1A — deepest background layer
- Navy 950: #0A162B — gradient midpoint
- Navy 900: #0F1F3D — gradient accent
- Navy 800: #14284D — interactive pressed state
- Gold 600: #C49A2A — primary accent (CTAs, focus)
- Gold 500: #D4AF37 — accent hover/focus ring
- Blue 500: #388BE0 — secondary accent, tints
- Blue 600: #2670C7 — active blue accent
- Slate 500: #8FA1C1 — secondary text
- Slate 300: #C1CBE0 — muted text/placeholder

### Semantic Tokens
- Background: Navy gradient (1000 → 950 → 900/Blue hint → 1000)
- Surface: .ultraThinMaterial (iOS 17) / .glassEffect (iOS 26)
- Surface/Alt: Navy 900 (for non-glass contexts)
- Surface/Active: Navy 800
- Stroke/Glass: white @ 15% opacity
- Stroke/GlassGold: Gold 600 @ 20% opacity
- Text/Primary: #E8EEF9
- Text/Secondary: Slate 500
- Text/Muted: Slate 300
- Accent/Fill: Gold 600
- Accent/On: Navy 1000 (text on gold)
- Focus Ring: Gold 500 at 2pt

### Glass Effects
- iOS 26+: `.glassEffect(.regular.tint(background.opacity(0.3)))` on cards and panels
- iOS 17-25: `.ultraThinMaterial` background with 0.5px white stroke
- Both: Subtle border at `Color.white.opacity(0.15)` for panel edges

Rules:
- Maintain ≥ 4.5:1 contrast for all body text over glass.
- Use gold primarily for CTAs, selection indicators, and focus — not general text.
- Glass panels should feel lightweight: avoid heavy borders or opaque fills.

## Typography

- Primary: SF Pro Text
- Alternate for headings: New York (serif) where available
- Weights: Regular, Medium, Semibold
- Sizes (dynamic type aware):
  - Display: 34/40
  - Title: 28/34
  - Headline: 20/26
  - Body: 17/24
  - Callout: 16/22
  - Footnote: 13/18
  - Caption: 12/16
- Numerics: Monospaced digits for data-heavy content
- Section headers: Uppercase, semibold, 0.5pt tracking, secondary color

## Layout, Spacing, Radii, Elevation

- Grid: 8pt base (use 4pt for micro)
- Spacing scale: 4, 8, 12, 16, 24, 32, 48, 64
- Corner radii: 8 (tight/inputs), 16 (standard/cards), 24 (loose/panels)
- Borders: 0.5px glass border on panels; 1px for emphasis/focus
- Elevation: achieved through translucency and layering, not shadows

## Components

### GlassCard
- Primary container for all content sections
- `.ultraThinMaterial` / `.glassEffect` background
- 0.5px white border at 15% opacity
- Corner radius 16 (standard)
- 16pt content padding
- Usage: transcript rows, poll cards, event cards, settings sections

### GlassBackgroundView
- Full-screen gradient behind all glass panels
- Linear gradient: Navy 1000 → Navy 950 → Blue 600 @ 15% → Navy 1000
- Applied as the root background layer

### App Bar / Navigation
- Translucent material background (not opaque)
- Gold tint accent for bar items
- Inline title display

### Tab Bar
- Glass material background
- Gold accent for selected tab
- SF Symbols for tab icons

### Buttons
- Primary: Gold 600 fill, Navy 1000 text, radius 8, subtle press scale (0.97)
- Secondary: Glass background with Gold 600 border at 20%, gold text
- Tertiary: Text-only in Gold 600
- All: 150ms ease-out press animation

### Text Fields
- `.ultraThinMaterial` background
- 0.5px glass border
- Corner radius 8 (tight)
- Caret and focus ring: Gold 500
- Content insets: 12pt

### List Row / Transcript Row
- Glass card container per row, or glass card for the full list
- Comfortable vertical spacing
- Thin dividers within cards

### Chip/Tag
- Radius 8
- Outline by default; filled for selected
- Gold 600 for active filters

## Patterns

### Login
- Full-screen glass background gradient
- Centered glass card with form fields
- Primary CTA in gold
- Secondary actions as tertiary text buttons

### Transcript Feed
- Glass background
- Each transcript in a glass-styled row
- Date uses monospaced digits

### GroupMe Feed
- Glass cards for announcements
- Poll cards with options displayed, gold accent on active polls

### Events
- Glass cards with date badge, title, location
- Chronological list with section headers

### Settings / Admin
- Glass card sections
- Toggle and picker controls with gold accent

## Interaction, Motion, Haptics

- Motion: ease-out 150ms for entrance; subtle scale on press (0.97)
- Haptics: light impact on critical actions (success, failure)
- Focus ring: 2pt Gold 500
- Tab transitions: smooth cross-fade

## Accessibility

- Color contrast ≥ 4.5:1 for body text, 3:1 for larger text
- Dynamic Type supported across components
- Min tap area: 44x44pt
- Reduce Motion respected
- VoiceOver: clear labels, traits, value changes

## Asset Naming (XCAssets)

Color sets:
- Brand/Navy/1000, 950, 900, 800
- Brand/Gold/600, 500
- Brand/Blue/500, 600
- Text/Primary, Secondary, Muted
- Stroke/Primary, Strong
- State/Success, Warning, Danger, Info
- Surface/Background, Default, Alt, Active

## iOS Implementation Notes (SwiftUI)

### Glass Background (root layer)
```swift
GlassBackgroundView() // LinearGradient overlay behind all content
```

### Glass Card (container)
```swift
GlassCard {
    Text("Content here")
}
// or use the modifier directly:
VStack { ... }
    .glassBackground(cornerRadius: 16)
```

### iOS 26 Glass Effect with Fallback
```swift
// Handled automatically by GlassBackgroundModifier
// iOS 26+: .glassEffect(.regular.tint(...))
// iOS 17-25: .ultraThinMaterial with stroke
```

### Navigation Bar (translucent)
```swift
let navAppearance = UINavigationBarAppearance()
navAppearance.configureWithTransparentBackground()
navAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
```

## Do / Don't

- Do: use glass materials; subtle 0.5px borders; layered translucency; gold for CTAs
- Do: use the GlassCard component for all content containers
- Don't: opaque solid backgrounds on panels; heavy shadows; oversized borders
- Don't: use gold for body text or large surface fills
- Don't: nest glass cards inside glass cards (single layer of glass per section)
