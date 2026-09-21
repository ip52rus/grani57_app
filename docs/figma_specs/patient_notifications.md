# Patient notifications

- Figma file: `9cE8OJQvicM0aQa0TOdDtc`.
- Page: `01 · Пациент` (`4:2`).
- Canonical viewport: `393 × 852`.
- Production entry: `lib/features/patient_notifications/patient_notification_screens.dart`.
- References/overlays: `docs/figma_reference/patient_notifications/` and
  `docs/visual_tests/patient_notifications/`.

## Frames

| State | Node |
|---|---:|
| Уведомления | `7:166` |
| Уведомления · нет событий | `53:773` |
| Разрешение уведомлений | `20:515` |
| Настройки уведомлений | `7:172` |
| Настройки · системное разрешение отклонено | `397:87` |

## Shared visual rules

- Background `#F5F8FD`, 24 px page padding, Manrope.
- Header and back behavior use the shared adaptive navigation foundation.
- Gradient headings use the project brand gradient implementation; screen
  geometry is validated against the local 393 × 852 references.
- Cards use existing white/soft surfaces and project radii/tokens.
- Exact current render differences are in `metrics.json`; they are evidence,
  not device approval.

## Product and platform logic

- Inbox works without OS push permission and reads local demo data.
- Notification tap marks the item read and opens appointment, document or news.
- Permission education appears only after a contextual explicit action, such as
  enabling reminders after successful booking; never at app launch.
- The OS prompt is requested by the CTA on the education screen.
- Appointment/document categories default on; news/promotions default off.
- Preferences, permission-request marker and read ids persist per patient in
  `shared_preferences`.
- If permission is denied, the app shows state `397:87` and opens system app
  settings instead of repeatedly requesting permission.
- Push copy must not contain diagnoses or treatment results.
- Remote APNs/FCM delivery is not implemented; current notifications are demo
  fixtures in `demo_patient_notifications.dart`.

## Validation snapshot

- Behavior: `test/patient_notifications_test.dart`.
- Renders: `test/goldens/patient_notifications/notification_render_test.dart`.
- Latest local metrics: `docs/visual_tests/patient_notifications/metrics.json`.
- Device QA: pending owner verification after the implementation pass.
