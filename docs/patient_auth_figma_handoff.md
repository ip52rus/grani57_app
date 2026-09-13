# 57 ГРАНЕЙ — Patient Auth Figma Handoff

**Source file:** `9cE8OJQvicM0aQa0TOdDtc` · **Source page:** `01 · Пациент` (`4:2`)  
**Scope:** exact source handoff for the existing `Вход` and `Код подтверждения` frames only. No Figma, Dart, navigation, mock-auth or asset changes were made.

## 1. Figma nodes

| Screen | Figma node | Size | Root styling | Reference PNG |
|---|---|---:|---|---|
| Вход | `7:169` | 393 × 852 | fill `#F5F8FD`, radius 28, clip content; vertical fixed frame | `docs/figma_reference/patient_auth/login.png` |
| Код подтверждения | `7:170` | 393 × 852 | fill `#F5F8FD`, radius 28, clip content; vertical fixed frame | `docs/figma_reference/patient_auth/sms_code.png` |

Coordinates below are relative to the 393 × 852 frame. Both screens use a 44 px device-status region and a 56 px app header. The scroll region starts at `y=100`, is 752 px tall and clips its content.

## 2. Login exact layout

### Structure and geometry

| Element / node | x, y · w × h | Exact Figma layout and visual values |
|---|---:|---|
| Status area `13:310` | 0, 0 · 393 × 44 | Horizontal; L/R padding 24, gap 4, vertically centered. Placeholder texts: `9:41` at 24,12 and `●  ▰` at 300,12. Treat as system UI, not application content. |
| Header `13:313` | 0, 44 · 393 × 56 | Horizontal; L/R padding 24, gap 8, vertically centered. |
| Back tap target `13:314` | 24, 50 · 44 × 44 | Contains 24 × 24 icon at 34,60. No fill. |
| Header title `13:317` | 76, 60 · 285 × 24 | `Вход и регистрация`. |
| Scroll content `13:319` | 0, 100 · 393 × 616.13 | Vertical auto-height; padding T/R/B/L `16/24/24/24`; gap 16; fixed width. |
| Logo instance `13:321` | 24, 116 · 140 × 40.13 | Existing standard logo asset; see mapping below. |
| Gradient headline `13:340` | 24, 172.13 · 345 × 72 | `Сохраняя здоровье\nВаших зубов.` |
| Intro `13:341` | 24, 260.13 · 345 × 40 | `Войдите или создайте аккаунт\nпо номеру телефона.` |
| Phone field instance `13:342` | 24, 316.13 · 345 × 112 | Vertical, gap 8; exact child field and text values below. |
| Phone input surface | 24, 344.13 · 345 × 56 | White `#FFFFFF`, 1 px inside stroke `#CFD9E8`, radius 12; horizontal padding 16, gap 8. |
| Consent row `49:588` | 24, 444.13 · 345 × 44 | Horizontal, gap 12, vertically centered. Checkbox hit area is 44 × 44. |
| Consent box `I49:589;48:86` | 34, 454.13 · 24 × 24 | White `#FFFFFF`, 1 px inside `#576A86`, radius 4; unchecked in this frame. |
| Get-code CTA `13:347` | 24, 504.13 · 345 × 52 | Disabled appearance: `#E1EBFC`, radius 12, horizontal padding 12, gap 8, centered. |
| Clinics CTA `13:350` | 24, 572.13 · 345 × 52 | `#E1EBFC`, radius 12, horizontal padding 12, gap 8, centered. |
| Staff-login CTA `13:352` | 24, 640.13 · 345 × 52 | White `#FFFFFF`, radius 12, horizontal padding 12, gap 8, centered. |

### Login text layers

| Layer | Exact text | x, y · w × h | Font / line height | Color / behavior |
|---|---|---:|---|---|
| `13:317` | Вход и регистрация | 76,60 · 285×24 | Manrope SemiBold 600, 16 / 24 | `#00318F`; left; height-hug; style `S:28b4…593fd` |
| `13:340` | Сохраняя здоровье\nВаших зубов. | 24,172.13 · 345×72 | Manrope Medium 500, 32 / 36 | Linear brand gradient; left; height-hug; style `S:86cc…5ec2c` |
| `13:341` | Войдите или создайте аккаунт\nпо номеру телефона. | 24,260.13 · 345×40 | Manrope Regular 400, 14 / 20 | `#576A86`; left; height-hug; style `S:de45…29b7` |
| `I13:342;6:8` | Номер телефона | 24,316.13 · 345×20 | Regular 400, 14 / 20 | `#576A86`; left; height-hug; style `S:de45…29b7` |
| `I13:342;6:10` | +7 (921) 000-00-00 | 40,360.13 · 313×24 | Regular 400, 16 / 24 | `#172B4D`; left; height-hug; style `S:06c9…a3e1` |
| `I13:342;6:11` | Отправим одноразовый код по SMS | 24,408.13 · 345×20 | Regular 400, 14 / 20 | `#576A86`; left; height-hug; style `S:de45…29b7` |
| `49:591` | Согласен на обработку\nперсональных данных | 80,446.13 · 289×40 | Regular 400, 14 / 20 | `#00318F`; left; height-hug; document target `55:777`, 289×44 |
| `I13:347;5:9` | Получить код | 36,518.13 · 321×24 | SemiBold 600, 16 / 24 | `#576A86`; centered; width-fill; style `S:28b4…593fd` |
| `I13:350;5:5` | Контакты клиник | 36,586.13 · 321×24 | SemiBold 600, 16 / 24 | `#00318F`; centered; width-fill; style `S:28b4…593fd` |
| `I13:352;5:7` | Вход для сотрудников | 36,654.13 · 321×24 | SemiBold 600, 16 / 24 | `#00318F`; centered; width-fill; style `S:28b4…593fd` |

## 3. SMS exact layout

### Structure and geometry

| Element / node | x, y · w × h | Exact Figma layout and visual values |
|---|---:|---|
| Status area | 0, 0 · 393 × 44 | Same geometry and placeholder treatment as Login. |
| Header | 0, 44 · 393 × 56 | Same geometry as Login; back target `13:358` is 24,50 · 44×44 and uses the same 24×24 back asset. |
| Header title `13:361` | 76,60 · 285×24 | `Подтверждение номера`. |
| Main headline `13:365` | 24,160 · 345×36 | `Введите код`. |
| Sent-number text `13:366` | 24,216 · 345×20 | `Отправили SMS на +7 (921) 000-00-00`. |
| SMS field `13:367` | 24,256 · 345×112 | Vertical, gap 8. Input surface is 24,284 · 345×56: white `#FFFFFF`, 1 px inside stroke `#00318F`, radius 12, horizontal padding 16, gap 8. |
| Verify CTA `13:372` | 24,388 · 345×52 | `#00318F`, radius 12, horizontal padding 12, gap 8, centered. |
| Change-number CTA `13:374` | 24,460 · 345×52 | White `#FFFFFF`, radius 12, horizontal padding 12, gap 8, centered. |
| Resend timer `13:376` | 24,532 · 345×20 | Lives directly on canvas; fixed width, height-hug. |
| Help panel `13:377` | 24,572 · 345×116 | `#E1EBFC`, radius 20; vertical auto-height, gap 12, padding 20 on all sides. |

### SMS text layers

| Layer | Exact text | x, y · w × h | Font / line height | Color / behavior |
|---|---|---:|---|---|
| `13:361` | Подтверждение номера | 76,60 · 285×24 | Manrope SemiBold 600, 16 / 24 | `#00318F`; left; style `S:28b4…593fd` |
| `13:365` | Введите код | 24,160 · 345×36 | Manrope Medium 500, 32 / 36 | Linear brand gradient; left; style `S:86cc…5ec2c` |
| `13:366` | Отправили SMS на +7 (921) 000-00-00 | 24,216 · 345×20 | Regular 400, 14 / 20 | `#576A86`; left; style `S:de45…29b7` |
| `I13:367;6:13` | Код из SMS | 24,256 · 345×20 | Regular 400, 14 / 20 | `#576A86`; left; style `S:de45…29b7` |
| `I13:367;6:15` | 1 2 3 4 5 6 | 40,300 · 313×24 | Regular 400, 16 / 24 | `#172B4D`; left; style `S:06c9…a3e1` |
| `I13:367;6:16` | Код действует 5 минут | 24,348 · 345×20 | Regular 400, 14 / 20 | `#576A86`; left; style `S:de45…29b7` |
| `I13:372;5:3` | Продолжить | 36,402 · 321×24 | SemiBold 600, 16 / 24 | `#FFFFFF`; centered; style `S:28b4…593fd` |
| `I13:374;5:7` | Изменить номер | 36,474 · 321×24 | SemiBold 600, 16 / 24 | `#00318F`; centered; style `S:28b4…593fd` |
| `13:376` | Отправить новый код через 00:42 | 24,532 · 345×20 | Regular 400, 14 / 20 | `#576A86`; left; style `S:de45…29b7` |
| `13:378` | Не приходит SMS? | 44,592 · 305×24 | SemiBold 600, 16 / 24 | `#00318F`; left; style `S:28b4…593fd` |
| `13:379` | Проверьте номер и дождитесь повторной отправки. Код можно вставить из SMS. | 44,628 · 305×40 | Regular 400, 14 / 20 | `#576A86`; left; wraps to two lines; style `S:de45…29b7` |

## 4. Typography

All application text in the two frames is Manrope: Regular 400, Medium 500 and SemiBold 600. Letter spacing is 0% on every text layer. All values are in the preceding tables; the status-bar placeholders are design-only and should be supplied by the operating system.

## 5. Colors/effects

| Use in these frames | Exact value |
|---|---|
| Screen canvas | `#F5F8FD` |
| Primary brand / header / link | `#00318F` |
| Main text | `#172B4D` |
| Secondary text / disabled CTA text / checkbox stroke | `#576A86` |
| Surface | `#FFFFFF` |
| Soft CTA / help panel | `#E1EBFC` |
| Field inactive stroke | `#CFD9E8` |
| Field active stroke | `#00318F` |
| Field and CTA radius | 12 px |
| Checkbox radius | 4 px |
| Help-panel radius | 20 px |
| Shadows, blur, opacity effects | None defined on visible application elements; opacity 100%. |

**Headline gradient:** linear with stops: `0% #00318F`, `24% #00318F`, `38% #4AAAFF`, `48% #A46BD5`, `58% #FF4A4D`, `66% #FF2B3A`, `84% #00318F`, `100% #00318F`. It is applied to the complete text layer, not selected words.

## 6. Asset mapping

| Figma element | Existing Flutter asset | Status |
|---|---|---|
| Login logo instance `13:321`, source component `6:40` | `assets/icons/brand/logo_primary.svg` | Exact canonical source export, 140×41. |
| Login back icon `13:315`; SMS header back icon inside `13:358` | `assets/icons/actions/back.svg` | Exact canonical source export, 24×24. |
| Consent check (checked state only) | `assets/icons/forms/checkbox_check.svg` | Existing source asset; the source Login frame itself displays the unchecked native-control surface, so do not draw a check there. |

No further image/vector asset is used by these two frames. The gradient heading, cards, field surfaces, buttons, borders and system-status placeholders are native UI/text, not image assets.

## 7. Product/Figma conflicts

### FIGMA / PRODUCT LOGIC CONFLICT — 1

The requested source Login frame `7:169` visibly contains an **unchecked** consent control (`49:588`/`49:589`) and the button `Получить код` is visually disabled. The approved Flutter demo rule says returning patients do not accept consent again when the current version is already accepted. This handoff only records the source Figma state; it does not decide or alter runtime logic.

## 8. Flutter implementation notes

| Item | Implementation source |
|---|---|
| Manrope 400/500/600, body/label/button text styles, base colors, 12/20 radii, 16/24 horizontal content rhythm | Existing Design System. Keep the exact screen values from this document where specified. |
| Header row, content scroll area, fixed 393-wide design geometry, 44×44 back touch target | Screen-specific exact Figma layout. Use safe-area/system APIs for the device status region. |
| Logo and back arrow | Existing assets at the mapping paths above; do not replace with Material icons. |
| Gradient title | Screen-specific exact Figma gradient stops and full-text application. |
| Login consent state and disabled/enabled get-code state | Runtime state may follow product rules later; this document records only `7:169` unchanged. |
| SMS code, timer and phone | Mock data/runtime values; preserve the exact source field geometry and all text styles while values change. |

