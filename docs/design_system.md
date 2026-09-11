# Design System

The design system is sourced from
`Design-UX-Implementation-Specification.md`.

## Implemented Tokens

- Colors: `brand`, `sky`, `soft`, `accent`, `coral`, `surface`, `onBrand`,
  `text`, `secondary`, `border`, `background`, `success`, `successBg`, `error`.
- Spacing: `4`, `8`, `12`, `16`, `20`, `24`, `32`, with `pagePadding = 24`.
- Radius: `12`, `20`, `28`, `full = 999`.
- Typography: Manrope architecture for `Display`, `Title`, `Heading`, `Body`,
  `Label`, `Small`, and `Caption`. `Title` is implemented as `32/36`.
- Brand gradient: centralized as `AppGradients.brandHeader`.
- Light theme: single `ThemeData` using semantic design-system tokens.

## Components

- `AppButton`: primary, secondary, ghost, danger, disabled, and loading states.
- `AppTextField`: default/focus/error behavior through Flutter input state.
- `AppToggle`: adaptive switch with semantics wrapper and 60x44 layout.
- `AppCheckbox`: checkbox with semantics wrapper and 48x48 hit target.

## Assets

Real Figma handoff assets are present and registered through semantic asset
directories in `pubspec.yaml`:

- 8 raster PNG assets under `assets/images/...`.
- 33 vector SVG assets under `assets/icons/...`.

The original Figma SVG files are preserved. Patient bottom-navigation SVGs keep
their exported Figma `foreignObject` and filter/glow markup. `flutter_svg` is
the selected renderer for these assets.

## Fonts

The app registers the real static Manrope TTF files as family `Manrope`:

- `assets/fonts/Manrope-Regular.ttf` -> `FontWeight.w400`.
- `assets/fonts/Manrope-Medium.ttf` -> `FontWeight.w500`.
- `assets/fonts/Manrope-SemiBold.ttf` -> `FontWeight.w600`.

`AppTypography` and `ThemeData.fontFamily` use `Manrope` as the primary family.
The variable Manrope source is not kept in app assets or registered because its
metadata reports `OS/2.usWeightClass = 200`, while the Demo needs exact
400/500/600 mappings.
