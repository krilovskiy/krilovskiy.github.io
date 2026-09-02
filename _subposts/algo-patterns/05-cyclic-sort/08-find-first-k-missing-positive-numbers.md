---
title: Найти первые k пропущенных положительных чисел
description: Поиск первых k отсутствующих положительных чисел в несортированном массиве.
pattern: cyclic-sort
permalink: /posts/algo-patterns-cyclic-sort/find-first-k-missing-positive-numbers/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан несортированный массив целых чисел и число `k`. Найдите первые `k` пропущенных положительных чисел.

**Пример 1:**

- Вход: `[3, -1, 4, 5, 5]`, `k=3`
- Выход: `[1, 2, 6]`
- Объяснение: первые пропущенные положительные числа — `1`, `2` и `6`.

**Пример 2:**

- Вход: `[2, 3, 4]`, `k=3`
- Выход: `[1, 5, 6]`
- Объяснение: первые пропущенные положительные числа — `1`, `5` и `6`.

**Пример 3:**

- Вход: `[-2, -3, 4]`, `k=2`
- Выход: `[1, 2]`
- Объяснение: первые пропущенные положительные числа — `1` и `2`.

## Решение

Задача следует паттерну циклической сортировки и похожа на поиск одного наименьшего пропущенного положительного числа. Сначала размещаем допустимые числа `x` по индексам `x-1`, игнорируя значения вне диапазона от `1` до `n`.

Затем проходим по массиву и добавляем `i+1` в результат, если по индексу `i` находится другое число. Значения с таких неправильных позиций сохраняем во множестве: среди них могут оказаться кандидаты, которые больше длины массива.

Если внутри массива найдено меньше `k` пропусков, последовательно проверяем числа `n+1`, `n+2` и так далее. Кандидат добавляется в результат, только если его нет в сохранённом множестве. Например, после сортировки массива `[2, 1, 3, 6, 5]` первым пропуском будет `4`, но следующим станет `7`, потому что число `6` уже есть в массиве.

## Код

```go
package main

import "fmt"

func findFirstKMissingPositive(nums []int, k int) []int {
	i := 0
	for i < len(nums) {
		correctIndex := nums[i] - 1
		if nums[i] > 0 && nums[i] <= len(nums) && nums[i] != nums[correctIndex] {
			nums[i], nums[correctIndex] = nums[correctIndex], nums[i]
		} else {
			i++
		}
	}

	missingNumbers := make([]int, 0, k)
	extraNumbers := make(map[int]struct{}, k)

	for i, number := range nums {
		if len(missingNumbers) == k {
			break
		}
		if number != i+1 {
			missingNumbers = append(missingNumbers, i+1)
			extraNumbers[number] = struct{}{}
		}
	}

	for candidate := len(nums) + 1; len(missingNumbers) < k; candidate++ {
		if _, exists := extraNumbers[candidate]; !exists {
			missingNumbers = append(missingNumbers, candidate)
		}
	}

	return missingNumbers
}

func main() {
	fmt.Println(findFirstKMissingPositive([]int{3, -1, 4, 5, 5}, 3))
	fmt.Println(findFirstKMissingPositive([]int{2, 3, 4}, 3))
	fmt.Println(findFirstKMissingPositive([]int{-2, -3, 4}, 2))
}
```

**Вывод:**

```text
[1 2 6]
[1 5 6]
[1 2]
```

## Временная сложность

Временная сложность алгоритма равна $$O(n+k)$$.

## Пространственная сложность

Для множества дополнительных чисел требуется $$O(k)$$ памяти. Выходной массив также содержит `k` элементов.

{% include algo-task-nav.html position="bottom" %}
