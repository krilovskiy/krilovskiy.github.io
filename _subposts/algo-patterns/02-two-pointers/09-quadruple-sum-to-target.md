---
title: Четвёрки с заданной суммой
description: Поиск всех уникальных четвёрок чисел с заданной суммой.
pattern: two-pointers
permalink: /posts/algo-patterns-two-pointers/quadruple-sum-to-target/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны неотсортированный массив и целевое число. Найдите все уникальные четвёрки элементов, сумма которых равна целевому числу.

**Пример 1:**

```text
Вход: [4, 1, 2, -1, 1, -3], target=1
Выход: [-3, -1, 1, 4], [-3, 1, 1, 2]
Пояснение: обе четвёрки дают целевую сумму.
```

**Пример 2:**

```text
Вход: [2, 0, -1, 1, -2, 2], target=2
Выход: [-2, 0, 2, 2], [-1, 0, 1, 2]
Пояснение: обе четвёрки дают целевую сумму.
```

## Решение

Задача расширяет поиск триплетов с нулевой суммой. Сначала сортируем массив, затем двумя вложенными циклами фиксируем первые два числа. Оставшуюся пару ищем указателями `left` и `right`.

Если сумма меньше цели, сдвигаем `left` вправо; если больше — `right` влево. После совпадения добавляем четвёрку и пропускаем повторяющиеся значения. Дубликаты двух фиксированных чисел также пропускаем.

## Код

```go
package main

import (
	"fmt"
	"sort"
)

func searchQuadruplets(arr []int, target int) [][]int {
	sort.Ints(arr)
	quadruplets := [][]int{}

	for i := 0; i < len(arr)-3; i++ {
		if i > 0 && arr[i] == arr[i-1] {
			continue
		}
		for j := i + 1; j < len(arr)-2; j++ {
			if j > i+1 && arr[j] == arr[j-1] {
				continue
			}

			left, right := j+1, len(arr)-1
			for left < right {
				currentSum := arr[i] + arr[j] + arr[left] + arr[right]
				switch {
				case currentSum == target:
					quadruplets = append(quadruplets, []int{arr[i], arr[j], arr[left], arr[right]})
					left++
					right--
					for left < right && arr[left] == arr[left-1] {
						left++
					}
					for left < right && arr[right] == arr[right+1] {
						right--
					}
				case currentSum < target:
					left++
				default:
					right--
				}
			}
		}
	}

	return quadruplets
}

func main() {
	fmt.Println(searchQuadruplets([]int{4, 1, 2, -1, 1, -3}, 1))
	fmt.Println(searchQuadruplets([]int{2, 0, -1, 1, -2, 2}, 2))
}
```

**Вывод:**

```text
[[-3 -1 1 4] [-3 1 1 2]]
[[-2 0 2 2] [-1 0 1 2]]
```

## Временная сложность

Сортировка занимает $$O(N \log N)$$, а два фиксированных индекса и поиск пары — $$O(N^3)$$. Общая временная сложность равна $$O(N^3)$$.

## Пространственная сложность

Если не учитывать результат, сортировке может потребоваться до $$O(N)$$ дополнительной памяти. Размер результата зависит от количества уникальных четвёрок.

{% include algo-task-nav.html position="bottom" %}
