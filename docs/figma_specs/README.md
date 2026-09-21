# Локальные Figma specs

Цель этой папки — сохранить небольшой объём данных, достаточный для повторной
реализации или коррекции flow без повторных запросов одних и тех же Figma nodes.

## Перед Figma MCP

1. Проверить `docs/codex/SCREEN_INDEX.md`.
2. Проверить существующий spec, `docs/figma_reference/` и overlay.
3. Запрашивать Figma только если точного значения действительно нет.

## Формат `<flow>.md`

```markdown
# Flow name

- File key / page / frame node
- Canonical viewport
- Production Flutter entry point
- Reference and overlay paths

## Geometry
Только значения, нужные реализации: x/y/w/h, gaps, padding, safe areas.

## Typography and fills
Font family/weight/size/line height, exact colors, gradients, effects.

## Assets
Figma source node → semantic Flutter asset path.

## States and behavior
Визуальные states и подтверждённая product/platform logic.

## Validation
Render, overlay, diff metric и device QA status.
```

Не сохранять raw JSON/MCP dumps, полные node trees, повторяющиеся screenshots или
историю обсуждения. Не копировать данные из другого flow. Не считать approximate
percentage визуальным approval.

## Существующие источники

- Patient auth: `docs/patient_auth_figma_handoff.md` — подробный исторический
  handoff для nodes `7:169` и `7:170`; не дублировать его здесь.
- Patient notifications: `docs/figma_specs/patient_notifications.md`.
- Asset source mapping: `docs/assets_manifest.md`.
