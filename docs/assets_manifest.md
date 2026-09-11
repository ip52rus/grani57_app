# 57 ГРАНЕЙ — Figma Asset Handoff for Flutter

**Figma file:** `9cE8OJQvicM0aQa0TOdDtc`  
**Prepared:** 2026-09-11  
**Scope:** source visual assets only. No Dart, UI, navigation or `pubspec.yaml` changes.

## Summary

- Unique raster assets: **8 PNG**.
- Unique vector assets: **33 SVG**.
- Total delivered assets: **41**.
- Duplicate uses on other frames and pages were mapped to the same Flutter asset.
- Raster files were taken from Figma raw image sources. Screen screenshots and node renders were not used as substitutes.
- SVG files were exported from the semantic vector container, so multicolor blue/red artwork remains intact.

## Raster assets

| Flutter asset | Figma source node | Source size | Purpose | Screens / usage | Reuse |
|---|---|---:|---|---|---|
| `assets/images/brand/glass_tooth.png` | `6:41` — Brand / Стеклянный зуб | 300×373 PNG | Transparent glass tooth artwork | Patient home carousel, news detail, overview, component library, filled admin publication preview | Reused |
| `assets/images/brand/glass_smile.png` | `65:609` — Brand / Стеклянная улыбка | 2354×1222 PNG | Transparent glass aligner/smile artwork | Patient home carousel and «Новый филиал» promotion | Reused |
| `assets/images/doctors/doctor_anna_smirnova.png` | `118:816` — Фото / Анна Смирнова | 1254×1254 PNG | Doctor portrait | Doctor selection, date/time, appointment details, conclusion, admin list/edit/delete, overview and Doctor card component | Reused |
| `assets/images/doctors/doctor_alexey_volkov.png` | `118:823` — Фото / Алексей Волков | 1254×1254 PNG | Doctor portrait | Doctor selection and admin doctor list | Reused |
| `assets/images/doctors/doctor_elena_kuznetsova.png` | `118:829` — Фото / Елена Кузнецова | 1254×1254 PNG | Doctor portrait | Doctor selection and admin doctor list | Reused |
| `assets/images/doctors/doctor_any_specialist.png` | `124:706` — Фото / Любой специалист | 1254×1254 PNG | Group portrait for «Любой специалист» | Patient doctor selection | Unique |
| `assets/images/maps/clinic_prosveshcheniya_map.png` | `87:2120` — карта / схема филиалов | 928×710 PNG | Static demonstration map for the Просвещения clinic | Patient «Клиники» | Unique |
| `assets/images/publications/gift_certificates.png` | `61:766` — source image in `go:Новость` | 1126×634 PNG | Existing publication artwork «Подарочные сертификаты» | `Главная · карта не подключена` carousel | Unique |

### Raster notes

- Figma also returned a 464×355 copy of the map and a 282×159 copy of the publication artwork. They are reduced duplicates and were deliberately omitted.
- The publication source already contains the words «Подарочные сертификаты». No Figma text layer was rasterized; this text is baked into the original image source.
- Doctor portraits and «Любой специалист» are demo imagery from the current Figma file. They are not verified clinic staff photographs.
- The static map is suitable for visual parity in Demo v0.1. Production should later use the chosen map SDK, as stated in the design specification.

## Brand vector assets

| Flutter asset | Figma source node | Format | Purpose | Screens / usage | Reuse |
|---|---|---|---|---|---|
| `assets/icons/brand/logo_primary.svg` | `6:40` — 57 / Logo | SVG, 140×41 | Standard app logo | Patient, doctor and admin headers/login screens; overview | Reused |
| `assets/icons/brand/logo_welcome.svg` | `105:88` — Логотип 57 граней — печатная продукция | SVG, 260×75 | Large logo artwork used on welcome | Patient «Приветствие» | Unique |

The subtitle «клиники стоматологии» beneath the welcome logo remains live Flutter text. It was not exported into the SVG.

## Patient bottom-navigation icons

The icons are multicolor: active and inactive variants differ in blue/gray treatment while retaining red accents. Both exported variants are therefore preserved instead of applying a single `currentColor` tint.

| Flutter asset | Figma source node | Format | Usage | Reuse |
|---|---|---|---|---|
| `assets/icons/navigation/nav_home_active.svg` | `7:5` | SVG, 22×22 | Active «Главная» | Reused |
| `assets/icons/navigation/nav_home_inactive.svg` | `7:35` | SVG, 22×22 | Inactive «Главная» | Reused |
| `assets/icons/navigation/nav_appointments_active.svg` | `7:41` | SVG, 22×22 | Active «Приёмы» | Reused |
| `assets/icons/navigation/nav_appointments_inactive.svg` | `7:11` | SVG, 22×22 | Inactive «Приёмы» | Reused |
| `assets/icons/navigation/nav_documents_active.svg` | `7:77` | SVG, 22×22 | Active «Документы» | Reused |
| `assets/icons/navigation/nav_documents_inactive.svg` | `7:17` | SVG, 22×22 | Inactive «Документы» | Reused |
| `assets/icons/navigation/nav_clinics_active.svg` | `7:112` | SVG, 22×22 | Active «Клиники» | Reused |
| `assets/icons/navigation/nav_clinics_inactive.svg` | `7:22` | SVG, 22×22 | Inactive «Клиники» | Reused |
| `assets/icons/navigation/nav_profile_active.svg` | `7:148` | SVG, 22×22 | Active «Профиль» | Reused |
| `assets/icons/navigation/nav_profile_inactive.svg` | `7:28` | SVG, 22×22 | Inactive «Профиль» | Reused |

## Action icons

| Flutter asset | Figma source node | Format | Purpose / screens | Reuse |
|---|---|---|---|---|
| `assets/icons/actions/back.svg` | `13:315` — Иконка / back | SVG, 24×24 | Back navigation across patient screens | Reused |
| `assets/icons/actions/arrow_forward.svg` | `7:245` — Иконка / arrow | SVG, 24×24 | Appointment-card forward action | Reused |
| `assets/icons/actions/notifications.svg` | `48:728` — Иконка / bell | SVG, 24×24 | Home notification entry and notification rows | Reused |
| `assets/icons/actions/location.svg` | `8:93` — Иконка / pin | SVG, 24×24 | Clinic/address actions | Reused |
| `assets/icons/actions/payments.svg` | `10:142` — Иконка / card | SVG, 24×24 | «Оплаты и чеки» row | Unique until payment screens are designed |
| `assets/icons/actions/settings.svg` | `12:237` — Иконка / settings | SVG, 24×24 | Notification settings | Reused |
| `assets/icons/actions/email.svg` | `13:232` — Иконка / mail | SVG, 24×24 | Clinic email action | Unique |
| `assets/icons/actions/phone.svg` | `13:226` — Иконка / phone | SVG, 24×24 | Phone/contact actions | Reused |
| `assets/icons/actions/lock.svg` | `11:219` — Иконка / lock | SVG, 24×24 | Privacy and restricted-data messages | Reused |
| `assets/icons/actions/chevron_left.svg` | `178:118` — Иконка / chevron-left | SVG, 20×20 | Doctor month pagination | Reused |
| `assets/icons/actions/chevron_right.svg` | `178:122` — Иконка / chevron-right | SVG, 20×20 | Doctor month pagination | Reused |
| `assets/icons/actions/chevron_forward.svg` | `16:70` — Иконка / chevron | SVG, 24×24 | Doctor selected-day row | Reused |

## Content, status, profile and form icons

| Flutter asset | Figma source node | Format | Purpose / screens | Reuse |
|---|---|---|---|---|
| `assets/icons/content/document.svg` | `11:201` — Иконка / file | SVG, 24×24 | Document list items | Reused |
| `assets/icons/content/appointment_calendar.svg` | `16:127` — Иконка / calendar | SVG, 24×24 | Doctor appointment information | Reused |
| `assets/icons/status/success_check.svg` | `10:71` — Иконка / check | SVG, 40×40 | Appointment-created success | Reused for equivalent success state only |
| `assets/icons/status/time_conflict.svg` | `21:360` — Иконка / clock | SVG, 48×48 | Busy-slot / uncertain-time state | Reused |
| `assets/icons/status/empty_appointments.svg` | `15:364` — Иконка / calendar | SVG, 48×48 | Patient empty appointments | Unique |
| `assets/icons/status/notification_permission.svg` | `21:431` — Иконка / bell | SVG, 56×56 | Notification pre-permission screen | Unique |
| `assets/icons/status/new_branch.svg` | `21:335` — Иконка / pin | SVG, 48×48 | New-branch publication detail | Unique |
| `assets/icons/profile/profile_avatar.svg` | `13:276` — Иконка / user | SVG, 40×40 | Patient profile card | Unique |
| `assets/icons/forms/checkbox_check.svg` | `48:89` — Иконка / check | SVG, 20×20 | Checked consent control | Reused |

## Intentionally not exported

- Full mobile frames and screenshots: UI must remain native Flutter widgets.
- Text and gradient headings: live text with Manrope and Flutter gradients.
- Solid fills, cards, borders, dividers, shadows, glass navigation background, blurs and radii: code-level design tokens/effects.
- Radio circles, toggles, checkboxes, calendar cells, chips and button backgrounds: ordinary UI primitives.
- iOS-style status-bar characters `●  ▰`: placeholders rather than app assets.
- Patient month arrows `‹` and `›`: text glyphs in Figma, not vector artwork.
- Admin bottom-navigation symbols `⌂`, `▤`, `○` and add symbol `＋`: text glyphs in the current Figma, so there is no real vector source to hand off.
- Three large red vectors `209:3511`, `209:3512`, `209:3513`: unplaced page-level reference graphics (heart and two strokes), not descendants of any mobile screen.
- Repeated logo/icon instances and reduced raster copies: they map to the canonical files listed above.

## Fonts

Figma uses one family:

| Family | Weight/style used | Numeric weight |
|---|---|---:|
| Manrope | Regular | 400 |
| Manrope | Medium | 500 |
| Manrope | SemiBold | 600 |

The local source folder contains `Manrope-Regular.ttf`, `Manrope-Medium.ttf`, `Manrope-SemiBold.ttf` and `Manrope-VariableFont_wght.ttf`.

Integration status:

- `Manrope-Regular.ttf`, `Manrope-Medium.ttf` and `Manrope-SemiBold.ttf` were
  verified against font metadata and copied/kept under `assets/fonts/`.
- The static files are registered in `pubspec.yaml` as family `Manrope` with
  weights 400, 500 and 600.
- `Manrope-VariableFont_wght.ttf` is not kept in app assets and is not
  registered because its metadata reports `OS/2.usWeightClass = 200`, while
  Demo v0.1 needs exact static 400/500/600 mappings.

## Validation

- All 8 PNGs were decoded successfully and their intrinsic dimensions were read.
- All 33 SVGs are well-formed XML with valid root dimensions.
- No delivered SVG contains `<text>` or embedded raster `<image>` elements.
- The two logo exports are separate Figma artworks and are intentionally retained.
- Navigation SVGs contain the original Figma glow/filter markup, including
  `foreignObject` and `<filter>`. A representative navigation SVG was loaded
  through `flutter_svg` in a widget test without renderer exceptions, but
  `flutter_svg` logged unsupported elements: `unhandled element <foreignObject/>`
  and `unhandled element <filter/>`. This affects the exported Figma
  glow/background-filter markup, not the core vector icon geometry.
- The affected originals are:
  `nav_home_active.svg`, `nav_home_inactive.svg`,
  `nav_appointments_active.svg`, `nav_appointments_inactive.svg`,
  `nav_documents_active.svg`, `nav_documents_inactive.svg`,
  `nav_clinics_active.svg`, `nav_clinics_inactive.svg`,
  `nav_profile_active.svg`, and `nav_profile_inactive.svg`.
- Original SVG exports are preserved. No Material icon replacement, normalized
  copy, or artwork rewrite was performed in this stage.

## Handoff status

The asset set is ready for Codex handoff. The remaining known source limitation is the absence of true vector artwork for the mobile admin navigation and patient month arrow glyphs. These elements must be resolved in design or reproduced as live typographic/UI primitives with explicit approval.
