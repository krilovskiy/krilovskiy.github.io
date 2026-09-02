---
title: Найти все повторяющиеся числа
description: Поиск всех повторяющихся чисел в массиве без дополнительной памяти.
pattern: cyclic-sort
permalink: /posts/algo-patterns-cyclic-sort/find-all-duplicate-numbers/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан несортированный массив из `n` чисел в диапазоне от `1` до `n`. В массиве есть несколько повторяющихся чисел. Найдите все повторения без дополнительной памяти.

**Пример 1:**

- Вход: `[3, 4, 4, 5, 5]`
- Выход: `[5, 4]`

**Пример 2:**

- Вход: `[5, 4, 7, 2, 3, 5, 3]`
- Выход: `[3, 5]`

## Решение

Задача следует паттерну циклической сортировки и похожа на поиск одного повторяющегося числа. Сначала размещаем каждое число `x` по индексу `x-1`. Если на целевом индексе уже находится такое же число, обмен не выполняем и переходим к следующей позиции.

После сортировки ещё раз проходим по массиву. Если число по индексу `i` не равно `i+1`, оно является повторяющимся.

## Код

```go
package main

import "fmt"

func findAllDuplicates(nums []int) []int {
	i := 0
	for i < len(nums) {
		correctIndex := nums[i] - 1
		if nums[i] != nums[correctIndex] {
			nums[i], nums[correctIndex] = nums[correctIndex], nums[i]
		} else {
			i++
		}
	}

	duplicates := make([]int, 0)
	for i, number := range nums {
		if number != i+1 {
			duplicates = append(duplicates, number)
		}
	}

	return duplicates
}

func main() {
	fmt.Println(findAllDuplicates([]int{3, 4, 4, 5, 5}))
	fmt.Println(findAllDuplicates([]int{5, 4, 7, 2, 3, 5, 3}))
}
```

**Вывод:**

```text
[5 4]
[3 5]
```

## Временная сложность

Временная сложность алгоритма равна $$O(n)$$.

## Пространственная сложность

Если не учитывать память для выходного массива, алгоритм использует $$O(1)$$ дополнительной памяти.

{% include algo-task-nav.html position="bottom" %}
