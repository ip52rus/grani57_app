# Текущее состояние

Снимок: 2026-09-21. Branch `main`, последний commit
`1baf575 style: match patient auth screens to figma` (2026-09-13).

## Реализовано в patient demo

- Splash, restoreSession и role-based replacement routing.
- Login, consent, SMS, новый пациент и локальная demo session.
- Общий patient shell с Home, Приёмы, Документы, Клиники и Профиль.
- Три состояния Home, news carousel и два news detail screen.
- Booking: клиника, услуга/врач, календарь/время, подтверждение и три результата.
- Приёмы: upcoming/empty/history, детали, отмена, перенос и success.
- Клиники: live Yandex Map, две точки и external route provider fallback.
- Документы: список заключений, detail, локальная PDF preview/download.
- Профиль: данные текущей session и выход.
- Уведомления: inbox/empty, contextual permission education, settings,
  denied-state переход в system settings и deep links к demo content.
- Общая адаптивная навигация, back swipe, numeric keypad и design system.

## Последняя завершённая работа

Flow уведомлений реализован и локально проверен. Последняя зафиксированная
проверка перед этой документационной задачей:

- `flutter analyze` — без замечаний;
- `flutter test` — 118 tests passed;
- iOS release build без codesign — успешно;
- Android debug APK — успешно.

Телефонная проверка notification flow и возможные визуальные коррекции остаются
следующим шагом владельца.

## Не завершено

- Doctor cabinet и administrator app: только routing placeholders.
- Production backend/MIS, реальные SMS/auth, remote appointment data.
- APNs/FCM remote delivery и server-side notification events.
- Production storage/security/privacy hardening.
- Полная device QA всех patient screens после объединения текущего dirty tree.

## Текущие ограничения

- Большой working tree содержит незакоммиченные изменения многих завершённых
  patient flows. Нельзя clean/reset/revert/stash или менять unrelated файлы.
- Часть старых foundation docs устарела; этот файл и фактический код новее.
- Visual diff metrics нельзя считать approval: финальное решение принимает
  владелец после проверки на реальном устройстве.
- Live map требует приватный `MAPKIT_API_KEY` из `.mapkit.env`.
- Demo fixtures не являются медицинскими или production данными.

## Следующее действие

После device QA корректировать только найденный flow. Если patient demo принят,
следующий отдельный этап — doctor/admin scope после явного задания.
