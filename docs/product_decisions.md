# Product Decisions

Approved for Demo v0.1 on 2026-09-11.

## Medical Card

- The Demo does not include the user-facing concepts `cardLinked`,
  "medical card connected", "medical card not connected", or manual medical
  card linking.
- App users must not connect a medical card manually.
- A future production backend will match patient data from MIS/database systems.
- Dental For Windows, MIS, and database integration are deferred and are not UI
  Demo blockers.
- If an older read-only reference source mentions `cardLinked`, this document is
  the newer decision for Demo v0.1.

## Payments And Receipts

- Payments and receipts are out of scope for Demo v0.1.
- Do not create payment routes, mock payment entities, payment data, receipt
  data, or payment UI in this Demo stage.
- The old Figma "Оплаты и чеки" link is not implemented as a working function in
  Demo v0.1.

## Splash

- Splash behavior is white background, logo opacity starts at `0`, smoothly
  animates to fully visible, lasts about 2-3 seconds, and navigates
  automatically.
- After Splash:
  - active local demo session routes to the corresponding main shell;
  - no active session routes to patient registration/login.
- Splash UI is implemented in the startup-routing slice with temporary
  development-only destinations.

## Patient Authentication And Consent

- Registered demo patients authenticate through local mock SMS validation.
- Unknown phone numbers are treated as the future "new patient" flow:
  unknown number -> demo SMS verification -> new patient data -> Patient Shell.
- The UI for the new-patient flow is not implemented in this stage.
- Current Patient Auth slice implements only the three registered demo patients.
  Unknown phone numbers must not create a patient automatically.
- New patients must accept the current consent version.
- Returning patients are not asked again when
  `acceptedConsentVersion == currentConsentVersion`.
- If the consent version changes later, returning patients must accept the new
  version.
- The session model stores only the accepted consent version identifier when
  needed; it must not store the full legal document.

## Employee Authentication

- "Вход для сотрудников" is one employee login page.
- Do not create a separate "choose Doctor / Administrator" screen.
- Demo authentication determines the role from credentials.
- Demo credentials live only in mock fixtures and are not production secrets.

## Demo Staff Credentials

- Doctor:
  - id: `doctor_001`
  - name: `Анна Смирнова`
  - role: `doctor`
  - phone/login: `+7 999 000-10-01`
  - password: `Doctor57!`
- Administrator:
  - id: `admin_001`
  - login: `admin57`
  - role: `administrator`
  - password: `Grani57Demo!`

These credentials are strictly local Demo fixtures. Production authentication
must not use open-text passwords or this validation model.

## Future Admin Requirement

Future administrator UI for creating or editing doctors must support managing
doctor app access:

- login/phone;
- credential setup or password reset;
- access enabled/disabled.

Production passwords must not be stored in open text. The current doctor
password remains a mock fixture only.
