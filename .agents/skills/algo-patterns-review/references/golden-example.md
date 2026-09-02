# Golden example: доказательное targeted review

## Как интерпретировать пример

- `SKILL.md` задаёт границы ревью; этот файл показывает один правильный формат исследования и возврата.
- Пример не задаёт ожидаемый verdict, приоритет или число findings текущей главы.
- Handoff-пакет определяет объект и измерения. Сабагент не расширяет targeted review до полного аудита.
- Наблюдение, finding и доказательство различаются: правдоподобная история без воспроизводимого расхождения остаётся вопросом, а не finding.

## Handoff-пакет для сабагента

```yaml
task_kind: review_chapter
repo_root: <ACTIVE_GIT_ROOT>
source_chapter: <EXACT_READ_ONLY_SOURCE_FOLDER_OR_NOT_APPLICABLE>
parent_post: <EXACT_MAIN_POST>
pattern: <EXACT_PATTERN_ID>
dimensions: [<COVERAGE_TRANSLATION_GO_JEKYLL_LINKS_VISUALS>]
mutation_scope: []
required_evidence: <CHECKS_MATCHING_DIMENSIONS>
```

Для Go-only ревью `source_chapter` нужен лишь когда утверждение зависит от оригинального алгоритма; Jekyll, внешние ссылки и изображения не проверяются автоматически. Для full review `dimensions` перечисляет все линии явно.

## Демонстрация finding

```text
[P1] Опубликованный пример расходится с фактическим выводом
Файл: <ABSOLUTE_PATH>:<LINE>
Наблюдение: статья обещает <EXPECTED>, свежий запуск печатает <ACTUAL>.
Влияние: читатель получает невоспроизводимый пример допустимого входа.
Минимальное исправление: синхронизировать код или опубликованный вывод с условием.
Доказательство: <EXACT_COMMAND> завершилась с кодом 0 и вывела <ACTUAL>.
```

Это пример формы, а не сигнал искать именно расхождение вывода. Если воспроизведения нет, finding не создаётся.

## Возврат сабагента

Сначала идут findings по серьёзности. Затем — только выполненные линии проверки:

```yaml
reviewed_dimensions: [<DIMENSIONS>]
findings_count: <NUMBER>
evidence:
  - check: <NAME>
    command_or_comparison: <EXACT_BASIS>
    result: passed | failed | inconclusive
limitations: [<NOT_CHECKED_OR_UNAVAILABLE>]
```

Фраза «проблем не найдено» ограничивается `reviewed_dimensions`; она не является общим одобрением главы. Старые отчёты и этот golden example не считаются свежими доказательствами.
