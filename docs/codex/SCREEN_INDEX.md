# Индекс экранов

`UNKNOWN` означает, что точный frame node не сохранён локально. Не угадывать:
получить его из Figma только когда flow действительно изменяется.

| Flow / состояние | Figma node | Flutter production file | Локальный spec | Reference / overlay | Статус |
|---|---:|---|---|---|---|
| Splash / Приветствие | UNKNOWN | `lib/app/startup/splash_screen.dart` | — | `docs/figma_reference/splash.png` / `docs/visual_tests/splash/splash_overlay.png` | implemented; visual fixture; startup logic |
| Login | `7:169` | `lib/features/patient_auth/patient_phone_login_screen.dart` | `docs/patient_auth_figma_handoff.md` | `docs/figma_reference/patient_auth/login.png` / `docs/visual_tests/patient_auth/login_overlay.png` | implemented; owner-approved Visual Gate A; demo logic |
| Код подтверждения | `7:170` | `lib/features/patient_auth/patient_sms_code_screen.dart` | `docs/patient_auth_figma_handoff.md` | `docs/figma_reference/patient_auth/sms_code.png` / `docs/visual_tests/patient_auth/sms_overlay.png` | implemented; reference + overlay; demo logic |
| Согласие | UNKNOWN | `lib/features/patient_auth/patient_consent_screen.dart` | — | `docs/figma_reference/patient_auth/consent.png` / `docs/visual_tests/patient_auth/consent_overlay.png` | implemented; reference + overlay |
| Данные нового пациента | UNKNOWN | `lib/features/patient_auth/patient_new_data_screen.dart` | — | `docs/figma_reference/patient_auth/new_patient_data.png` / `docs/visual_tests/patient_auth/new_patient_data_overlay.png` | implemented; reference + overlay; validation |
| Главная: три patient states | UNKNOWN | `lib/features/patient_home/patient_home_screen.dart` | — | `docs/figma_reference/patient_home_*.png` / `docs/visual_tests/patient_home*_overlay.png` | implemented; reference + overlays; demo fixtures |
| Новости: два detail states | UNKNOWN | `lib/features/patient_home/patient_news_screen.dart` | — | `docs/figma_reference/news.png`, `new_branch.png` / matching overlays | implemented; reference + overlays; booking CTA |
| Запись: клиника | UNKNOWN | `lib/features/patient_booking/patient_booking_screens.dart` | — | `docs/figma_reference/booking_clinic.png` / matching overlay | implemented; demo navigation |
| Запись: услуга / врачи | UNKNOWN | `lib/features/patient_booking/patient_booking_screens.dart` | — | `booking_service.png`, `booking_doctors.png` / matching overlays | implemented; tap + swipe; selected doctor state |
| Запись: дата / время | UNKNOWN | `lib/features/patient_booking/patient_booking_screens.dart` | — | `docs/figma_reference/booking_datetime.png` / matching overlay | implemented; calendar + time list |
| Запись: подтверждение | UNKNOWN | `lib/features/patient_booking/patient_booking_screens.dart` | — | `docs/figma_reference/booking_confirmation.png` / matching overlay | implemented; demo branching |
| Запись: success/offline/time unavailable | UNKNOWN | `lib/features/patient_booking/patient_booking_screens.dart` | — | `docs/figma_reference/booking_*.png` / matching overlays | implemented; three demo outcomes |
| Приёмы: upcoming/empty/history | UNKNOWN | `lib/features/patient_appointments/patient_appointments_screen.dart` | — | `docs/figma_reference/patient_appointments_*.png` / matching overlays | implemented; tap + swipe; demo data |
| Детали/отмена/перенос/success | UNKNOWN | `lib/features/patient_appointments/patient_appointment_*_screen.dart` | — | `docs/figma_reference/patient_appointments/` / matching overlays | implemented; local state transitions |
| Клиники | UNKNOWN | `lib/features/patient_clinics/patient_clinics_screen.dart` | — | `docs/figma_reference/patient_clinics/clinics.png` / matching overlay | implemented; live MapKit + external routing |
| Документы/заключение/PDF | UNKNOWN | `lib/features/patient_documents/` | — | `docs/figma_reference/patient_documents/` / matching overlays | implemented; demo documents + generated PDF |
| Профиль | UNKNOWN | `lib/features/patient_profile/patient_profile_screen.dart` | — | `docs/figma_reference/patient_profile.png` / matching overlay | implemented; current session + sign-out |
| Уведомления: inbox | `7:166` | `lib/features/patient_notifications/patient_notification_screens.dart` | `docs/figma_specs/patient_notifications.md` | `docs/figma_reference/patient_notifications/notifications.png` / matching overlay | implemented; demo deep links/read state |
| Уведомления: empty | `53:773` | `lib/features/patient_notifications/patient_notification_screens.dart` | `docs/figma_specs/patient_notifications.md` | `notifications_empty.png` / matching overlay | implemented; settings CTA |
| Разрешение уведомлений | `20:515` | `lib/features/patient_notifications/patient_notification_screens.dart` | `docs/figma_specs/patient_notifications.md` | `notification_permission.png` / matching overlay | implemented; contextual OS request |
| Настройки уведомлений | `7:172` | `lib/features/patient_notifications/patient_notification_screens.dart` | `docs/figma_specs/patient_notifications.md` | `notification_settings.png` / matching overlay | implemented; persisted categories |
| Настройки: denied | `397:87` | `lib/features/patient_notifications/patient_notification_screens.dart` | `docs/figma_specs/patient_notifications.md` | `notification_settings_denied.png` / matching overlay | implemented; open system settings |
| Вход врача | `209:2471` | `lib/features/doctor_auth/doctor_login_screen.dart` | `docs/figma_specs/doctor_cabinet.md` | `docs/figma_reference/doctor_cabinet/doctor_login.png` / matching overlay | implemented; validation + doctor session |
| Расписание врача | `209:2493` | `lib/features/doctor_schedule/doctor_schedule_screen.dart` | `docs/figma_specs/doctor_cabinet.md` | `doctor_schedule.png` / matching overlay | implemented; calendar + mock refresh |
| Запись пациента | `209:2635` | `lib/features/doctor_schedule/doctor_appointment_detail_screen.dart` | `docs/figma_specs/doctor_cabinet.md` | `doctor_appointment_detail.png` / matching overlay | implemented; model-driven detail |
| Расписание врача: нет записей | `422:93` | `lib/features/doctor_schedule/doctor_schedule_screen.dart` | `docs/figma_specs/doctor_cabinet.md` | `doctor_schedule_empty.png` / matching overlay | implemented; inline empty-date state |
| Админка: вход | `120:2344` | `lib/features/doctor_auth/doctor_login_screen.dart` | `docs/figma_specs/admin.md` | `docs/figma_reference/admin/admin_login.png` | shared employee login; role-based destination |
| Админка: главная | `161:214` | `lib/features/admin/admin_shell_screen.dart` | `docs/figma_specs/admin.md` | `docs/figma_reference/admin/admin_home.png` | implementation in progress |
| Админка: публикации CRUD | `161:215`, `161:216`, `161:217`, `161:218` | `lib/features/admin/admin_publications_screen.dart` | `docs/figma_specs/admin.md` | `docs/figma_reference/admin/admin_publication_*.png` | implementation in progress |
| Админка: врачи CRUD | `161:219`, `161:220`, `161:221`, `161:222` | `lib/features/admin/admin_doctors_screen.dart` | `docs/figma_specs/admin.md` | `docs/figma_reference/admin/admin_doctor_*.png` | implementation in progress |
| Админка: доступ врача | `454:129`, `454:187` | `lib/features/admin/admin_doctor_access_screen.dart` | `docs/figma_specs/admin.md` | `docs/figma_reference/admin/admin_doctor_access_*.png` | implementation in progress |
