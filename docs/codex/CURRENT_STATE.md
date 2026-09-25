# Текущее состояние

Снимок: 2026-09-25. Branch `main`.

Актуальные контрольные commits:

- `ff2fc24 chore: optimize Codex project context`
- `1dcdd12 wip: checkpoint current demo development`
- `d1efd9e docs: improve portfolio README`

## Реализовано в patient demo

- Splash, restoreSession и role-based startup routing.
- Login, consent, SMS, регистрация нового пациента и локальная demo session.
- Общий patient shell с Home, Приёмы, Документы, Клиники и Профиль.
- Несколько состояний Home, news carousel и detail screens.
- Booking flow: клиника, услуга/врач, календарь/время, подтверждение и результаты.
- Приёмы: upcoming/empty/history, детали, отмена, перенос и success.
- Клиники: Yandex MapKit, точки клиник и external route provider fallback.
- Документы: список заключений, detail и локальная PDF preview/download.
- Профиль текущего пациента и выход.
- Уведомления: inbox/empty, permission education, settings и deep links.
- Общая адаптивная навигация, back swipe, numeric keypad и design system.

## Реализовано в doctor demo

- Вход врача из общей точки «Вход для сотрудников».
- Role-based employee authentication.
- Сохранение и восстановление doctor session.
- Персональное расписание врача.
- Календарь и выбор даты.
- Список записей.
- Model-driven карточка записи пациента.
- Empty-day state.
- Demo doctor access связан со стабильным `doctorId`.

## Administrator demo

Реализуется отдельный administrator flow.

Текущая структура включает:

- общий employee login с role-based routing;
- admin shell;
- список врачей;
- управление данными врачей;
- управление доступом врача в приложение;
- demo login/password для врача;
- включение и отключение доступа;
- публикации и связанные CRUD-состояния.

Admin flow ещё требует завершения, visual QA и проверки связанных состояний.

## Demo runtime

В текущей версии backend отсутствует.

Используются локальные mock/demo данные:

- demo patients;
- doctor;
- administrator;
- расписание;
- записи;
- локальные session state;
- doctor access configuration.

Demo credentials не являются production credentials.

## Карты

Используется Yandex MapKit.

API key передаётся через:

```text
MAPKIT_API_KEY