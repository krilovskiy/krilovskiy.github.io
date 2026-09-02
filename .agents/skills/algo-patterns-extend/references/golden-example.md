# Golden example: добавление пропущенной задачи

## Как интерпретировать пример

- `SKILL.md` задаёт обязательные границы; этот файл показывает один корректный проход.
- Пример не доказывает, что задача отсутствует в текущей главе, и не разрешает менять файлы вне handoff-пакета.
- Значения `<...>` связываются из текущего checkout и источника. Свежая карта покрытия важнее названия файла или сходства заголовков.

## Handoff-пакет для сабагента

```yaml
task_kind: extend_chapter
repo_root: <ACTIVE_GIT_ROOT>
source_chapter: <EXACT_READ_ONLY_SOURCE_FOLDER>
parent_post: <EXACT_MAIN_POST>
pattern: <EXACT_PATTERN_ID>
candidate_gap: <SOURCE_TASK_OR_CHALLENGE>
mutation_scope:
  - <NEW_OR_CHANGED_SUBPOSTS>
  - <PARENT_TASK_INDEX>
  - <TASK_ASSETS_IF_NEEDED>
required_checks: [source_map, changed_go, jekyll, internal_links, navigation]
```

Родитель не формулирует `candidate_gap` как уже доказанный finding: сабагент обязан сопоставить условие, примеры и алгоритм с основной статьёй и всеми субпостами. При совпадении он возвращает `already_covered` и не создаёт файл.

## Демонстрация изменения

После подтверждения пробела создаётся один упорядоченный субпост:

```text
_subposts/algo-patterns/<NN>-<PATTERN_SLUG>/
  <KK>-<TASK_SLUG>.md
```

```yaml
---
title: <RUSSIAN_TASK_TITLE>
description: <PRECISE_DESCRIPTION>
pattern: <EXACT_PATTERN_ID>
permalink: /posts/<PARENT_SLUG>/<TASK_SLUG>/
---
```

Тело содержит верхнюю навигацию, точный перевод, решение, самостоятельную Go-программу, подтверждённые сложности и нижнюю навигацию. Основная статья получает только новую строку в `## Задачи главы`. Существующие permalink не меняются.

## Возврат сабагента

```yaml
coverage_result: missing_confirmed | already_covered | inconclusive
changed_files: [<PATHS>]
evidence:
  source_mapping: <OBSERVATION>
  go: <COMMAND_AND_RESULT_OR_NOT_APPLICABLE>
  jekyll: <COMMAND_AND_RESULT>
  navigation: <CHECKED_URLS_AND_LINKS>
limitations: [<UNVERIFIED_PROPERTIES>]
```

`missing_confirmed` не следует из handoff-пакета; это вывод сабагента после проверки. `passed` не наследуется из примера.
