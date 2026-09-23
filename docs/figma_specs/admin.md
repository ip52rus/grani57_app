# Admin module

- Figma file `9cE8OJQvicM0aQa0TOdDtc`, page `03 · Админка` (`4:4`).
- Canonical viewport: `393 × 852` for every state.
- Local references: `docs/figma_reference/admin/`.
- Production feature root: `lib/features/admin/`.

| State | Node | Reference |
|---|---:|---|
| Вход администратора | `120:2344` | `admin_login.png` |
| Главная админки | `161:214` | `admin_home.png` |
| Новости и акции | `161:215` | `admin_publications.png` |
| Новая публикация | `161:216` | `admin_publication_new.png` |
| Редактирование публикации | `161:217` | `admin_publication_edit.png` |
| Удаление публикации | `161:218` | `admin_publication_delete.png` |
| Врачи | `161:219` | `admin_doctors.png` |
| Новый врач | `161:220` | `admin_doctor_new.png` |
| Редактирование врача | `161:221` | `admin_doctor_edit.png` |
| Удаление врача | `161:222` | `admin_doctor_delete.png` |
| Доступ врача: создание | `454:129` | `admin_doctor_access_create.png` |
| Доступ врача: создан | `454:187` | `admin_doctor_access_existing.png` |

## Geometry and tokens

- Device status region `44`, page header `56`, horizontal page padding `24`.
- Background `#F5F8FD`, surface `#FFFFFF`, soft `#E1EBFC`, border
  `#CFD9E8`, brand `#00318F`, text `#172B4D`, secondary `#576A86`,
  accent `#FF2B3A`, success `#216445` on `#E9F5EE`.
- Manrope: title `500 32/36`, heading `600 20/28`, label `600 16/24`,
  body `400 16/24`, small `400 14/20`, caption `500 12/16`.
- Main content width `345`; buttons `345 × 52`, radius `12`; cards radius
  `20`; page frame radius `28`; bottom navigation `80`; fixed form action
  panel `100` including padding.
- Title gradients use `#00318F → #4AAAFF → #A46BD5 → #FF4A4D →
  #FF2B3A → #00318F`. Each rendered line owns its shader bounds.

## Content and behavior

- The common employee login resolves the destination from the authenticated
  role. `admin57 / Grani57Demo!` opens Admin; doctor credentials open the
  linked doctor's schedule. No role selector is shown.
- Admin home links to Publications and Doctors and shows counts from the local
  store. Bottom navigation provides the same three destinations.
- Publications support all/published/draft filtering, create, edit and delete.
  The form supports news/promotion type, image demo state, title, description,
  information, clinic, period and draft/published status.
- Doctors support search, create, edit and delete. A doctor has one stable ID,
  name, description, photo asset and selected services.
- Doctor access is a separate credential record keyed by the same stable
  doctor ID. It supports create, login/password change, disable, enable and
  remove. Disabled or removed credentials cannot authenticate.
- `doctor_001` / Анна Смирнова keeps the existing `anna.smirnova /
  Doctor57!` demo access. Admin-created access immediately participates in the
  shared employee login.
- Demo publications, doctors and doctor access are persisted with
  `SharedPreferences`; the backend boundary remains replaceable.

