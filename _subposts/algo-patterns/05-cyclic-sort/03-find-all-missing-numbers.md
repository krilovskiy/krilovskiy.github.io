---
title: Найти все пропущенные числа
description: Поиск всех пропущенных чисел в диапазоне от 1 до n без дополнительной памяти.
pattern: cyclic-sort
permalink: /posts/algo-patterns-cyclic-sort/find-all-missing-numbers/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан несортированный массив из `n` чисел в диапазоне от `1` до `n`. Массив может содержать дубликаты, поэтому некоторые числа из диапазона отсутствуют. Найдите все пропущенные числа без дополнительной памяти.

**Пример 1:**

- Вход: `[2, 3, 1, 8, 2, 3, 5, 1]`
- Выход: `[4, 6, 7]`

**Пример 2:**

- Вход: `[2, 4, 1, 2]`
- Выход: `[3]`

**Пример 3:**

- Вход: `[2, 3, 2, 1]`
- Выход: `[4]`

## Решение

Сначала с помощью циклической сортировки пытаемся разместить каждое число `x` по индексу `x-1`. Если на целевом индексе уже находится такое же число, переходим к следующей позиции.

После сортировки ещё раз проходим по массиву. Для каждого индекса `i`, на котором находится не `i+1`, добавляем `i+1` в результат.

## Код

```go
package main

import "fmt"

func findAllMissingNumbers(nums []int) []int {
	i := 0
	for i < len(nums) {
		correctIndex := nums[i] - 1
		if nums[i] != nums[correctIndex] {
			nums[i], nums[correctIndex] = nums[correctIndex], nums[i]
		} else {
			i++
		}
	}

	missingNumbers := make([]int, 0)
	for i, number := range nums {
		if number != i+1 {
			missingNumbers = append(missingNumbers, i+1)
		}
	}

	return missingNumbers
}

func main() {
	fmt.Println("Пропущенные числа:", findAllMissingNumbers([]int{2, 3, 1, 8, 2, 3, 5, 1}))
	fmt.Println("Пропущенные числа:", findAllMissingNumbers([]int{2, 4, 1, 2}))
	fmt.Println("Пропущенные числа:", findAllMissingNumbers([]int{2, 3, 2, 1}))
}
```

**Вывод:**

```text
Пропущенные числа: [4 6 7]
Пропущенные числа: [3]
Пропущенные числа: [4]
```

## Временная сложность

Временная сложность алгоритма равна $$O(n)$$.

## Пространственная сложность

Если не учитывать память для выходного массива, алгоритм использует $$O(1)$$ дополнительной памяти.

{% include algo-task-nav.html position="bottom" %}
