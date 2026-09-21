# Architecture

> Historical foundation snapshot. For the current implemented feature map and
> runtime status, use `docs/codex/PROJECT_CONTEXT.md` and
> `docs/codex/CURRENT_STATE.md`.

This project is the Flutter foundation for the `57 ГРАНЕЙ` iOS and Android app.
It intentionally does not implement product screens, backend integration, real
SMS, payments, analytics, Firebase, or real medical data.

## Current Shape

- `lib/main.dart` delegates startup to `app/bootstrap/bootstrap.dart`.
- `Grani57App` owns the root `MaterialApp`, light theme, and startup
  coordinator.
- `app/startup` contains the real Splash screen, startup session restore, and
  the role-to-destination decision for the current Demo slice.
- `app/role_gate` remains a neutral routing boundary for future patient,
  doctor, and admin shells. It is not used by the current Splash startup flow.
- `app/router` holds named-route constants only; no third-party router is used.
- `core/design_system` contains semantic tokens, typography, theme primitives,
  gradients, effects, and reusable foundation components.
- `core/mock_runtime` contains demo-only authentication helpers, `UserRole`, and
  minimal demo-session persistence.
- `mock_data` contains demo-only fixtures for three registered patients, one
  doctor, one administrator, and a small doctor schedule.
- `features/patient_auth` contains the first real patient authentication UI
  slice: phone lookup for registered demo patients and local mock SMS
  validation.
- `features/development_demo` is a temporary technical sandbox for verifying the
  foundation. It is not a product screen and should be removed or hidden once
  approved Figma screens are implemented. It also contains the four temporary
  startup placeholders used to verify routing branches.

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
- Startup runs Splash presentation and `restoreSession()` in parallel. Routing
  occurs only after both the minimum Splash presentation and session restore are
  complete.
- Invalid or corrupted Demo session state safely falls back to the patient auth
  placeholder.
- Returning demo patients authenticate through phone lookup plus local SMS code
  validation. A successful SMS saves a patient `DemoSession` and replaces the
  auth flow with the patient shell placeholder.
- Unknown patient registration is intentionally deferred. Unknown phone numbers
  show a temporary development/demo state and do not create patients or
  sessions.
- The employee login link opens a temporary employee-auth placeholder; doctor
  and administrator credential UI remains deferred.
- Dental For Windows, MIS/database integration, production authentication, and
  map SDK selection are deferred backend/platform topics, not blockers for the
  current Demo UI.
- Payments and receipts are out of scope for Demo v0.1.
