# Рабочий процесс

## 1. Начало задачи

1. Выполнить `git status --short`.
2. Найти flow в `SCREEN_INDEX.md` и открыть только связанные source/spec/test.
3. Отделить существующие dirty changes от требуемых изменений.
4. Не запускать destructive Git commands и не делать commit.

## 2. Figma → локальный spec

Использовать такую последовательность:

1. Проверить локальный spec, reference PNG и overlay.
2. Если данных хватает, не обращаться к Figma MCP.
3. Если данных не хватает, получить direct design context ровно для нужного
   frame/node один раз.
4. Записать устойчивые значения в короткий файл `docs/figma_specs/<flow>.md`:
   node id, viewport, geometry, typography, fills/effects, assets и состояния.
5. Сохранить reference в существующей flow-папке и добавить строку в index.
6. Не сохранять raw MCP dumps и не дублировать полное дерево Figma.

## 3. Реализация flow

1. Сначала собрать статический production screen из общих tokens/components.
2. Рендерить реальный production widget при canonical `393 × 852`.
3. Выполнить цикл `render → overlay → inspect → correct → render`.
4. Для локального diff использовать существующий инструмент:

   ```bash
   dart run tool/visual_diff.dart docs/visual_tests/<flow> <screen_name>
   ```

5. Percentage diff — вспомогательная метрика; оценивать заметную геометрию.
6. После статики добавить interaction/navigation на стандартных primitives.
7. Не создавать отдельную визуальную копию production screen для golden.

## 4. Проверки без лишней работы

Во время итерации запускать только затронутый набор:

```bash
# Phone, SMS, birth date
flutter test test/patient_auth_input_test.dart

# Notifications and permission behavior
flutter test test/patient_notifications_test.dart

# External navigation providers
flutter test test/external_route_launcher_test.dart

# Один widget scenario из общего файла
flutter test test/widget_test.dart --plain-name '<точное имя теста>'

# Конкретный golden flow
flutter test test/goldens/patient_notifications/notification_render_test.dart
```

`--update-goldens` применять только при намеренном обновлении утверждённого
fixture. После завершения flow:

```bash
dart format .
flutter analyze
flutter test
```

Если изменены только Markdown/tooling, проверить ссылки, формат и
`git diff --check`; долгие Flutter checks не запускать.

## 5. Device QA и завершение

1. Установить актуальную сборку на реальное устройство.
2. Проверить safe areas, клавиатуру, свайпы, native permission и карту.
3. Исправить найденное в том же flow и повторить targeted checks.
4. Обновить `CURRENT_STATE.md` и `SCREEN_INDEX.md`, если статус изменился.
5. Отчёт: что изменено, что проверено, оставшиеся различия/ограничения,
   `git status --short`.
6. Commit допускается только после прямого запроса владельца.
