---
title: Вычисление выражения
description: Поиск всех результатов выражения при разных расстановках скобок.
pattern: subsets
permalink: /posts/algo-patterns-subsets/evaluate-expression/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дано выражение, содержащее числа и операции `+`, `-`, `*`. Найдите все возможные значения выражения, группируя числа и операции скобками всеми способами.

**Пример 1:**

```text
Вход: "1+2*3"
Выход: 7, 9
```

`1+(2*3)` даёт `7`, а `(1+2)*3` — `9`.

**Пример 2:**

```text
Вход: "2*3-4-5"
Выход: 8, -12, 7, -7, -3
```

Все пять группировок:

* `2*(3-(4-5))` → `8`;
* `2*((3-4)-5)` → `-12`;
* `(2*3)-(4-5)` → `7`;
* `(2*(3-4))-5` → `-7`;
* `((2*3)-4)-5` → `-3`.

## Решение

Задача следует паттерну «Подмножества» и похожа на генерацию сбалансированных скобок. В приведённом в оригинале алгоритме варианты перебираются рекурсивно:

1. Просматриваем выражение посимвольно.
2. На каждой операции `+`, `-` или `*` разбиваем выражение на левую и правую части.
3. Рекурсивно вычисляем все значения обеих частей.
4. Применяем выбранную операцию к каждой паре левого и правого значений, добавляя результаты в общий список.

Если в строке нет операции, это число: преобразуем его в `int` и возвращаем список из одного значения. Разные группировки могут давать одинаковые значения; каждое из них сохраняется в результате.

## Код

{% raw %}
```go
package main

import (
	"fmt"
	"strconv"
)

func diffWaysToEvaluateExpression(input string) []int {
	result := []int{}
	for i := 0; i < len(input); i++ {
		char := input[i]
		if char != '+' && char != '-' && char != '*' {
			continue
		}
		leftParts := diffWaysToEvaluateExpression(input[:i])
		rightParts := diffWaysToEvaluateExpression(input[i+1:])
		for _, part1 := range leftParts {
			for _, part2 := range rightParts {
				switch char {
				case '+':
					result = append(result, part1+part2)
				case '-':
					result = append(result, part1-part2)
				case '*':
					result = append(result, part1*part2)
				}
			}
		}
	}
	if len(result) == 0 {
		value, err := strconv.Atoi(input)
		if err != nil {
			panic(err)
		}
		result = append(result, value)
	}
	return result
}
func main() {
	fmt.Println("Значения выражения:", diffWaysToEvaluateExpression("1+2*3"))
	fmt.Println("Значения выражения:", diffWaysToEvaluateExpression("2*3-4-5"))
}
```
{% endraw %}

**Вывод:**

```text
Значения выражения: [7 9]
Значения выражения: [8 -12 7 -7 -3]
```

## Временная сложность

В оригинале сложность описана как экспоненциальная, с приблизительной оценкой $$O(N \cdot 2^N)$$ и более точной оценкой $$O(4^n / \sqrt{n})$$, связанной с числами Каталана. При использовании второй оценки $$n$$ соответствует числу операций, то есть количеству мест для разбиения выражения.

Оценка $$O(N \cdot 2^N)$$ из оригинала не учитывает это различие и не используется здесь как точная граница.

## Пространственная сложность

Оригинал также приводит экспоненциальные оценки памяти: приблизительную $$O(2^N)$$ и уточнённую $$O(4^n / \sqrt{n})$$. Дополнительная память используется для списков результатов подвыражений и рекурсивных вызовов.

## Версия с мемоизацией

В задаче есть пересекающиеся подзадачи: одно и то же подвыражение может вычисляться несколько раз. Оригинал предлагает хранить промежуточные результаты в хеш-таблице.

Перед вычислением проверяем, есть ли строка `input` в `cache`. Если есть, возвращаем готовый список. Иначе вычисляем его, сохраняем в таблице и возвращаем. Полный список всех вариантов по-прежнему остаётся экспоненциальным.

{% raw %}
```go
package main

import (
	"fmt"
	"strconv"
)

func diffWaysToEvaluateExpression(input string) []int {
	return diffWaysToEvaluateExpressionRec(make(map[string][]int), input)
}
func diffWaysToEvaluateExpressionRec(cache map[string][]int, input string) []int {
	if result, ok := cache[input]; ok {
		return result
	}
	result := []int{}
	for i := 0; i < len(input); i++ {
		char := input[i]
		if char != '+' && char != '-' && char != '*' {
			continue
		}
		leftParts := diffWaysToEvaluateExpressionRec(cache, input[:i])
		rightParts := diffWaysToEvaluateExpressionRec(cache, input[i+1:])
		for _, part1 := range leftParts {
			for _, part2 := range rightParts {
				switch char {
				case '+':
					result = append(result, part1+part2)
				case '-':
					result = append(result, part1-part2)
				case '*':
					result = append(result, part1*part2)
				}
			}
		}
	}
	if len(result) == 0 {
		value, err := strconv.Atoi(input)
		if err != nil {
			panic(err)
		}
		result = append(result, value)
	}
	cache[input] = result
	return result
}
func main() {
	fmt.Println("Значения выражения:", diffWaysToEvaluateExpression("1+2*3"))
	fmt.Println("Значения выражения:", diffWaysToEvaluateExpression("2*3-4-5"))
}
```
{% endraw %}

**Вывод:**

```text
Значения выражения: [7 9]
Значения выражения: [8 -12 7 -7 -3]
```

{% include algo-task-nav.html position="bottom" %}
