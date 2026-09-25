# Контекст проекта

## Назначение и приоритеты

`57 ГРАНЕЙ` — Flutter demo-приложение стоматологических клиник для iOS и
Android с тремя пользовательскими контурами:

- Patient;
- Doctor;
- Administrator.

Patient и Doctor flows в основном реализованы. Administrator flow находится
в активной разработке и требует завершения и финальной проверки.

При конфликте источников применять такой порядок:

1. Последняя явная инструкция владельца проекта.
2. `docs/product_decisions.md` для продуктовой логики.
3. `docs/codex/CURRENT_STATE.md` для фактического состояния реализации.
4. `docs/codex/SCREEN_INDEX.md` для связи Figma ↔ Flutter ↔ visual fixtures.
5. Figma для визуала конкретного экрана.
6. Apple HIG / Google Material для поведения и физики взаимодействий.

Старые `docs/architecture.md` и `docs/implementation_plan.md` относятся к
раннему foundation-этапу и могут отставать от текущего кода.

## Технологии

- Flutter / Dart.
- iOS и Android.
- Portrait orientation.
- Application id / bundle id: `ru.g57.app`.
- Flutter Navigator и локальный `appPageRoute`; сторонний router не используется.
- Manrope 400/500/600 из `assets/fonts/`.
- Figma как основной источник UI/UX.
- Yandex MapKit.
- Local mock/demo runtime.
- Widget / behavioral / golden tests.
- Visual comparison tooling.

Основные Flutter packages включают:

- `flutter_svg`;
- `shared_preferences`;
- `permission_handler`;
- `url_launcher`;
- `yandex_maps_mapkit_lite`;
- `pdf`;
- `printing`.

## Структура проекта

- `lib/app/` — bootstrap, Splash и startup routing.
- `lib/core/design_system/` — tokens, theme, typography и общие компоненты.
- `lib/core/navigation/` — platform-aware navigation foundation.
- `lib/core/maps/` — MapKit initialization и external navigation.
- `lib/core/mock_runtime/` — demo authentication, sessions и runtime state.
- `lib/mock_data/` — локальные demo fixtures.
- `lib/features/patient_*` — Patient flows.
- `lib/features/doctor_auth/` — employee / doctor authentication.
- `lib/features/doctor_schedule/` — Doctor Cabinet.
- `lib/features/admin/` — Administrator flow.
- `docs/figma_reference/` — локальные Figma reference images.
- `docs/figma_specs/` — компактные specs для реализуемых flows.
- `docs/visual_tests/` — renders, overlays, diffs и metrics.
- `test/` — behavioral, widget и golden tests.
- `tool/visual_diff.dart` — локальное визуальное сравнение.

## Design system и поведение

- Figma является визуальным source of truth.
- Canonical viewport visual fixtures: `393 × 852`.
- Используется общий дизайн-системный слой вместо копирования UI по экранам.
- Общие кнопки, поля, navigation shell и другие primitives переиспользуются.
- Поведение строится на Flutter / Cupertino / Material primitives.
- Visual diff используется как вспомогательная проверка.
- Финальный visual approval выполняется после проверки на реальном устройстве.

## Patient demo

Реализованы основные Patient flows:

- Splash и startup routing;
- вход по номеру телефона;
- согласие на обработку данных;
- SMS confirmation;
- регистрация нового пациента;
- Home;
- news;
- booking;
- appointments;
- clinics;
- Yandex MapKit;
- external navigation;
- documents;
- PDF preview;
- notifications;
- profile;
- sign-out.

Данные работают через локальный demo runtime.

## Doctor demo

Реализован Doctor Cabinet:

- вход через общую точку «Вход для сотрудников»;
- role-based authentication;
- doctor session;
- персональное расписание;
- календарь;
- список записей;
- карточка приёма пациента;
- empty-day state;
- сохранение выбранного контекста при навигации.

Врач связан с demo runtime через стабильный `doctorId`.

## Administrator demo

Administrator flow находится в активной разработке.

Текущая реализация включает:

- role-based переход из employee login;
- admin shell;
- управление врачами;
- управление доступом врачей в приложение;
- создание и изменение demo credentials;
- enable / disable doctor access;
- publications management.

Doctor access хранится отдельно от отображаемых данных врача и связан с
врачом через стабильный `doctorId`.

Admin flow ещё требует завершения, visual QA и device QA.

## Demo runtime и authentication

Production backend пока отсутствует намеренно.

Используются локальные demo:

- patients;
- doctor;
- administrator;
- appointments;
- schedule;
- employee credentials;
- sessions;
- doctor access state.

Session содержит только данные, необходимые для demo-routing и отображения.

Demo credentials не являются production authentication и не должны
использоваться как модель безопасного хранения паролей.

В production предполагается backend authentication и связь employee account
со стабильным doctor/user identifier.

## Backend

Backend является отдельным следующим крупным этапом после стабилизации UI/UX.

Предполагаемое направление:

- API;
- production database;
- authentication;
- sessions;
- roles and permissions;
- patients;
- doctors;
- appointments;
- schedule;
- notifications;
- integration с внешней медицинской системой при необходимости.

Конкретный backend stack пока не зафиксирован окончательно.

## Figma и локальные источники

Figma file:

`9cE8OJQvicM0aQa0TOdDtc`

Основные страницы проекта содержат Patient, Doctor и Administrator flows,
компоненты и состояния интерфейса.

Точные известные node IDs и соответствия Flutter-файлам находятся в:

`docs/codex/SCREEN_INDEX.md`

Если данные конкретного экрана уже сохранены в локальном spec/reference,
повторный запрос Figma MCP не требуется.

## Карты

Live Yandex Map использует `MAPKIT_API_KEY`, передаваемый через Dart define.

Локальный файл:

```text
.mapkit.env
```

исключён из Git.

Пример запуска:

```bash
flutter run --release \
  --dart-define-from-file=.mapkit.env \
  -d <device-id>
```

Настоящий API key нельзя помещать в Dart, Markdown, логи, commits или
публичный GitHub.

## Тестирование

Во время разработки предпочтительны targeted tests для изменяемого flow.

После завершения логического блока:

```bash
dart format .
flutter analyze
flutter test
```

Проект также использует:

- Figma reference PNG;
- golden fixtures;
- overlays;
- visual diff;
- проверки на реальных iOS и Android устройствах.

## Рабочий принцип

Разработка ведётся небольшими связанными flow:

**Figma context → Flutter UI → visual QA → interaction/navigation → targeted tests → device QA → commit**

Не расширять scope на несвязанные части приложения без необходимости.