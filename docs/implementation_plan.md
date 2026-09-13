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
- Added the first visible UI slice: Splash with real Figma logo, parallel demo
  session restore, startup role routing, and four development-only destination
  placeholders.
- Added tests for Splash logo rendering, fade animation, startup routing
  branches, invalid-session fallback, and Splash removal from the navigation
  stack.

## Demo v0.1 Scope Decisions

- `cardLinked` and manual medical-card linking are removed from the Demo.
- Payments and receipts are out of scope for Demo v0.1.
- Employee login is a single page; credentials determine doctor or administrator
  role.
- Splash behavior is implemented for the startup-routing slice.
- Future admin doctor credential management is approved as a requirement but no
  UI is implemented yet.

## Deferred Backend And Platform Topics

- Dental For Windows integration.
- MIS/database integration and patient matching.
- Production authentication and secure credential storage.
- Map SDK or external route strategy.

These are not blockers for the current pixel-accurate Demo UI.

## Suggested Next Stage

Replace the temporary patient auth placeholder with the first real auth UI:

1. Patient registration/login entry.
2. Phone input using local mock patient lookup.
3. Demo SMS entry with local mock validation.
4. Route verified registered patients into the future patient shell.

Do not start the 53 product screens until their target stage is explicitly
approved.
