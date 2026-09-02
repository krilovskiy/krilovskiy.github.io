---
title: Найти наименьшее пропущенное положительное число
description: Поиск наименьшего отсутствующего положительного числа в несортированном массиве.
pattern: cyclic-sort
permalink: /posts/algo-patterns-cyclic-sort/find-smallest-missing-positive-number/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан несортированный массив целых чисел. Найдите в нём наименьшее пропущенное положительное число.

**Пример 1:**

- Вход: `[-3, 1, 5, 4, 2]`
- Выход: `3`
- Объяснение: наименьшее пропущенное положительное число — `3`.

**Пример 2:**

- Вход: `[3, -2, 0, 1, 2]`
- Выход: `4`

**Пример 3:**

- Вход: `[3, 2, 5, 1]`
- Выход: `4`

## Решение

Задача следует паттерну циклической сортировки и похожа на поиск пропущенного числа. Отличие в том, что значения во входном массиве не ограничены заданным диапазоном.

Будем размещать число `x` по индексу `x-1`, но проигнорируем неположительные числа и числа, которые больше длины массива. После циклической сортировки первый индекс `i`, на котором находится не `i+1`, укажет на наименьшее пропущенное положительное число. Если все числа стоят правильно, ответ равен `n+1`.

## Код

```go
package main

import "fmt"

func findSmallestMissingPositive(nums []int) int {
	i := 0
	for i < len(nums) {
		correctIndex := nums[i] - 1
		if nums[i] > 0 && nums[i] <= len(nums) && nums[i] != nums[correctIndex] {
			nums[i], nums[correctIndex] = nums[correctIndex], nums[i]
		} else {
			i++
		}
	}

	for i, number := range nums {
		if number != i+1 {
			return i + 1
		}
	}

	return len(nums) + 1
}

func main() {
	fmt.Println(findSmallestMissingPositive([]int{-3, 1, 5, 4, 2}))
	fmt.Println(findSmallestMissingPositive([]int{3, -2, 0, 1, 2}))
	fmt.Println(findSmallestMissingPositive([]int{3, 2, 5, 1}))
}
```

**Вывод:**

```text
3
4
4
```

## Временная сложность

Временная сложность алгоритма равна $$O(n)$$.

## Пространственная сложность

Алгоритм использует $$O(1)$$ дополнительной памяти.

{% include algo-task-nav.html position="bottom" %}
