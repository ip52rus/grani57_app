# Implementation Plan

## Completed In This Foundation

- Created iOS/Android-only Flutter project.
- Removed the standard Flutter counter app.
- Configured application identifiers and display names.
- Added light theme and semantic design-system tokens.
- Added minimal reusable component primitives from the Figma component set.
- Added real Figma raster/vector assets and registered asset directories.
- Added real static Manrope font files and registered weights 400/500/600.
- Added `flutter_svg` for source SVG rendering.
- Added minimal mock runtime types: `UserRole`, `DemoSession`, demo auth, and
  demo session persistence.
- Added demo fixtures for three patients, one doctor, one administrator, and a
  doctor schedule with one empty day state.
- Added focused tests for bootstrap, theme tokens, and button states.
- Added tests for demo patient lookup, SMS validation, employee auth, session
  persistence, phone normalization, schedule references, Manrope configuration,
  and representative raster/SVG assets.

## Demo v0.1 Scope Decisions

- `cardLinked` and manual medical-card linking are removed from the Demo.
- Payments and receipts are out of scope for Demo v0.1.
- Employee login is a single page; credentials determine doctor or administrator
  role.
- Splash behavior is approved but not implemented in this stage.
- Future admin doctor credential management is approved as a requirement but no
  UI is implemented yet.

## Deferred Backend And Platform Topics

- Dental For Windows integration.
- MIS/database integration and patient matching.
- Production authentication and secure credential storage.
- Map SDK or external route strategy.

These are not blockers for the current pixel-accurate Demo UI.

## Suggested Next Stage

Implement the first real UI slice:

1. Splash UI with white background and logo opacity animation.
2. Restore local demo session on startup.
3. Route active sessions to the role-specific shell placeholder.
4. Route missing sessions to patient registration/login entry.

Do not start the 53 product screens until their target stage is explicitly
approved.
