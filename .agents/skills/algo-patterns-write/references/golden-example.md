# Golden example: новая глава

## Как интерпретировать пример

- `SKILL.md` задаёт обязательные границы и критерии.
- Этот файл — демонстрация одного корректного прохода, а не спецификация текущей главы и не порядок всей проектной работы.
- Handoff-пакет ниже содержит данные конкретного запуска. Значения в угловых скобках должны быть связаны заново.
- Только свежие чтения, сборки и запуски являются доказательствами. Статус из примера нельзя переносить в результат.

## Handoff-пакет для сабагента

Родитель передаёт пакет без скрытого контекста:

```yaml
task_kind: create_chapter
repo_root: <ACTIVE_GIT_ROOT>
source_chapter: <EXACT_READ_ONLY_SOURCE_FOLDER>
chapter_number: <NEXT_NUMBER>
mutation_scope:
  - <NEW_MAIN_POST>
  - <NEW_SUBPOST_DIRECTORY>
  - <NEW_ASSET_DIRECTORY>
  - <SERIES_NAV_FILES_ALLOWED_BY_PARENT>
required_checks: [source_map, go, jekyll, internal_links, navigation, changed_visuals]
```

Сабагент подтверждает активный root через git, сохраняет пользовательские изменения и не расширяет `mutation_scope`. Если номер, source folder или право менять навигацию не однозначны, он возвращает точный конфликт вместо выбора по примеру.

## Демонстрация результата

```text
_posts/
  <POST_DATE>-algo-patterns-<PATTERN_SLUG>.md
_subposts/algo-patterns/<NN>-<PATTERN_SLUG>/
  02-<TASK_SLUG>.md
  03-<TASK_SLUG>.md
assets/img/posts/<POST_DATE>-algo-patterns-<PATTERN_SLUG>/
  <DESCRIPTIVE_DIAGRAM>.svg
```

Основная статья связывает `pattern`, `short_title`, `primary_task_title` и `primary_task_anchor`. Субпост содержит только актуальные для проекта поля `title`, `description`, `pattern`, `permalink` и верхний/нижний `algo-task-nav.html`. Количество субпостов следует исходнику, а не примеру.

Карта покрытия в рабочем результате выглядит так:

| Исходная единица | Публикация | Решение |
|---|---|---|
| `<INTRO>` | основная статья | перевести один раз |
| `<BASE_TASK>` | основная статья | полное решение |
| `<TASK_2>` | `02-<TASK_SLUG>.md` | отдельный субпост |
| `<SOLUTION_REVIEW_FOR_TASK_2>` | тот же субпост | объединить, не считать задачей |

## Возврат сабагента

Сабагент возвращает созданные файлы, карту покрытия, команды и фактические результаты Go/Jekyll/HTML, визуально проверенные страницы и ограничения. Формулировка `passed` допустима только рядом со свежим evidence; непроверенное свойство остаётся `not_checked`.
