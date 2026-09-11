# Architecture

This project is the Flutter foundation for the `57 ГРАНЕЙ` iOS and Android app.
It intentionally does not implement product screens, backend integration, real
SMS, payments, analytics, Firebase, or real medical data.

## Current Shape

- `lib/main.dart` delegates startup to `app/bootstrap/bootstrap.dart`.
- `Grani57App` owns the root `MaterialApp`, light theme, and role gate.
- `app/role_gate` is a neutral routing boundary for future patient, doctor, and
  admin shells. It currently points to a development-only foundation screen.
- `app/router` holds named-route constants only; no third-party router is used.
- `core/design_system` contains semantic tokens, typography, theme primitives,
  gradients, effects, and reusable foundation components.
- `core/mock_runtime` contains demo-only authentication helpers, `UserRole`, and
  minimal demo-session persistence.
- `mock_data` contains demo-only fixtures for three registered patients, one
  doctor, one administrator, and a small doctor schedule.
- `features/development_demo` is a temporary technical sandbox for verifying the
  foundation. It is not a product screen and should be removed or hidden once
  approved Figma screens are implemented.

## Constraints

- Runtime dependencies are limited to Flutter SDK APIs, `flutter_svg` for Figma
  SVG assets, and `shared_preferences` for minimal local Demo session state.
- No backend abstractions, REST repositories, DTO layers, or production data
  storage exist at this stage.
- Demo authentication is local mock logic only. It validates fixture SMS codes
  and fixture employee credentials and returns a role-specific `DemoSession`.
- `DemoSession` stores only `authenticated`, `userId`, and `role`. It does not
  store passwords, SMS codes, legal documents, or medical data.
- `DemoSessionStore` persists only the minimal session state required for the
  future Splash routing decision: `restoreSession()`, `saveSession()`, and
  `clearSession()`.
- Dental For Windows, MIS/database integration, production authentication, and
  map SDK selection are deferred backend/platform topics, not blockers for the
  current Demo UI.
- Payments and receipts are out of scope for Demo v0.1.
