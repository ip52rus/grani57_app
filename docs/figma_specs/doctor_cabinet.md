# Doctor Cabinet

- Figma file `9cE8OJQvicM0aQa0TOdDtc`, page `01 · Пациент`.
- Canonical viewport: `393 × 852` for all four frames/states.
- References: `docs/figma_reference/doctor_cabinet/`.
- Visual outputs: `docs/visual_tests/doctor_cabinet/`.

| State | Node | Production screen |
|---|---:|---|
| Вход врача | `209:2471` | `lib/features/doctor_auth/doctor_login_screen.dart` |
| Расписание врача | `209:2493` | `lib/features/doctor_schedule/doctor_schedule_screen.dart` |
| Запись пациента | `209:2635` | `lib/features/doctor_schedule/doctor_appointment_detail_screen.dart` |
| Расписание врача · нет записей | `422:93` | `lib/features/doctor_schedule/doctor_schedule_screen.dart` |

## Geometry and type

- Device status region `44`, header `56`, page padding `24`, content top/bottom
  padding `16/24`, Auto Layout gap `20`.
- Background `#F5F8FD`; surface `#FFFFFF`; soft `#E1EBFC`; border
  `#CFD9E8`; brand `#00318F`; text `#172B4D`; secondary `#576A86`.
- Manrope: Title `500 32/36`, Heading `600 20/28`, Label `600 16/24`,
  Body `400 16/24`, Small `400 14/20`, Caption `500 12/16`.
- Buttons `345 × 52`, radius `12`; cards radius `20`; frame radius `28`.
- Login logo `140 × 40.13`. Login fields `345 × 112`; input surface height
  `56`.
- Calendar card width `345`, padding `16`; month controls `40 × 40`; day
  cells `36 × 36`, vertical row gap `6`; date grid height `246`.
- Schedule cards show the status as a separate pill: `Подтверждён` uses
  success green on `#E9F5EE`; `Завершён` uses error red on `#FFE8EA`.
- The patient appointment detail header contains only the patient, date, and
  time. Status is intentionally limited to schedule cards.
- Schedule and detail bottom action is fixed: top padding `12`, horizontal
  padding `24`, bottom padding `24`.
- The schedule header exposes `Выйти`; the selected-date heading has no
  trailing date-navigation button.

## Gradients and assets

- Gradient colors: `#00318F`, `#4AAAFF`, `#A46BD5`, `#FF4A4D`,
  `#FF2B3A`, returning to `#00318F`. Each text line uses its own Figma stop
  geometry; the exact stops are kept beside the corresponding production text.
- Exact frame SVGs are stored under `assets/icons/doctor/`; the production
  login reuses `assets/icons/brand/logo_primary_clean.svg`.

## Demo behavior

- Existing employee entry opens doctor login. The central employee fixture
  authenticates by username or doctor phone; only `role=doctor` enters this
  flow. Session persistence uses `DemoSessionStore`.
- September 2026 is deterministic. Marked dates come from `DemoSchedule`;
  14 September contains the three Figma appointments, 15 September is empty.
- Appointment taps pass `DemoAppointment` by ID/model. Back and the bottom
  action preserve the selected schedule date.
- An empty date stays on the schedule screen. The appointment list is replaced
  by the `На этот день записей нет` card; there is no separate Free Day route
  and no `К 14 сентября` action. Month controls and local refresh are
  functional.
- `Выйти` clears `DemoSessionStore` and returns to the common login screen.

## Validation

- Production-screen fixtures render at `393 × 852`; overlays and raw diff
  metrics are generated with `tool/visual_diff.dart`.
- Geometry was visually aligned against the local references. Raw changed-pixel
  percentages remain sensitive to font/SVG antialiasing and are not approval.
- Real-device QA is pending.
