# Контекст проекта

## Назначение и приоритеты

`57 ГРАНЕЙ` — Flutter demo-приложение стоматологических клиник для пациентов,
врачей и администраторов. Текущий полноценно проработанный контур — patient demo.

При конфликте источников применять такой порядок:

1. Последняя явная инструкция владельца проекта.
2. `docs/product_decisions.md` для продуктовой логики.
3. `docs/codex/CURRENT_STATE.md` для фактического состояния реализации.
4. Figma для визуала конкретного экрана.
5. Apple HIG / Google Material для поведения и физики взаимодействий.

Старые `docs/architecture.md` и `docs/implementation_plan.md` описывают ранний
foundation-этап и могут отставать от текущего кода.

## Технологии

- Flutter, Dart `^3.12.2`, MaterialApp с общим design system.
- Платформы: iOS и Android; portrait orientation.
- Application id / bundle id: `ru.g57.app`.
- Навигация: Flutter Navigator и локальный `appPageRoute`; стороннего router нет.
- Шрифт: Manrope 400/500/600 из `assets/fonts/`.
- Основные пакеты: `flutter_svg`, `shared_preferences`, `permission_handler`,
  `url_launcher`, `yandex_maps_mapkit_lite`, `pdf`, `printing`.

## Структура

- `lib/app/` — bootstrap, Splash, startup routing и role destinations.
- `lib/core/design_system/` — tokens, theme, typography и общие компоненты.
- `lib/core/navigation/` — единый platform-aware route/back-swipe foundation.
- `lib/core/maps/` — MapKit initialization и внешние маршруты.
- `lib/core/mock_runtime/` — demo authentication/session persistence.
- `lib/mock_data/` — локальные demo fixtures и состояния пациентов.
- `lib/features/` — экраны по patient flow; doctor/admin пока заглушки.
- `docs/figma_reference/` — локальные Figma reference PNG.
- `docs/visual_tests/` — Flutter renders, overlays, diffs и отдельные metrics.
- `test/` — behavior/input/widget и golden fixtures.
- `tool/visual_diff.dart` — локальное сравнение reference и render.

## Design system и поведение

- Визуал сохраняет утверждённую Figma-композицию и Manrope.
- Поведение строится на стандартных Flutter/Cupertino/Material primitives.
- Общие кнопки, поля, checkbox, numeric keypad, navigation shell и back swipe
  переиспользуются; их не копируют по экранам.
- Back swipe доступен на экранах с предыдущим route и начинается в левых 40%.
- Numeric input использует проектную keypad без selection/scanning/context menu.
- Canonical viewport visual fixtures: `393 × 852`.

## Demo runtime

- Splash параллельно показывает утверждённую анимацию и восстанавливает session.
- Patient auth: телефон, локальный SMS, consent и регистрация нового пациента.
- Три зарегистрированных пациента и локальные коды находятся в
  `lib/mock_data/demo_patients.dart`.
- Session хранит минимальные `userId`, role, phone и name в
  `shared_preferences`; это не production authentication.
- Patient flows: home/news, booking, appointments, clinics, documents,
  notifications и profile/sign-out.
- Doctor и administrator routes существуют как временные placeholders.
- Payments/receipts отсутствуют по продуктовому решению.
- Реального backend, MIS/Dental For Windows, APNs/FCM и production patient data
  пока нет.

## Figma и локальные источники

- Figma file key: `9cE8OJQvicM0aQa0TOdDtc`.
- Patient page: `01 · Пациент`, node `4:2`.
- Точные известные nodes и локальные файлы перечислены в
  `docs/codex/SCREEN_INDEX.md`.
- Экспортированные assets описаны в `docs/assets_manifest.md`.
- Не запрашивать Figma node повторно, если нужная геометрия уже записана в
  локальном spec или проверяется reference PNG.

## Локальная конфигурация

Live Yandex Map получает `MAPKIT_API_KEY` через Dart define. Локальный файл
`.mapkit.env` исключён из Git:

```bash
flutter run --release --dart-define-from-file=.mapkit.env -d <device-id>
```

Никогда не помещать ключ в Dart, Markdown, логи или final report.
