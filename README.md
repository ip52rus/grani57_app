# 57 ГРАНЕЙ

Flutter demo-приложение стоматологических клиник для iOS и Android.

## Контекст для разработки

- [Правила Codex](AGENTS.md)
- [Контекст проекта](docs/codex/PROJECT_CONTEXT.md)
- [Рабочий процесс](docs/codex/WORKFLOW.md)
- [Текущее состояние](docs/codex/CURRENT_STATE.md)
- [Индекс экранов](docs/codex/SCREEN_INDEX.md)
- [Правила локальных Figma specs](docs/figma_specs/README.md)

## Основные команды

```bash
flutter pub get
flutter run -d <device-id>
flutter run --release --dart-define-from-file=.mapkit.env -d <device-id>
```

`.mapkit.env` содержит локальный ключ карты, не входит в Git и не должен
публиковаться.

Проверки выбираются по изменяемому flow. Полные проверки после завершения flow:

```bash
dart format .
flutter analyze
flutter test
```
