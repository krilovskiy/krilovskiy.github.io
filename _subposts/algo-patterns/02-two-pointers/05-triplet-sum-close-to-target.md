---
title: Сумма триплета, ближайшая к целевой
description: Поиск суммы трёх чисел, наиболее близкой к заданной цели, методом двух указателей.
pattern: two-pointers
permalink: /posts/algo-patterns-two-pointers/triplet-sum-close-to-target/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны неотсортированный массив и целевое число. Найдите триплет, сумма которого максимально близка к целевому числу, и верните эту сумму. Если одинаково близки несколько триплетов, верните меньшую сумму.

**Пример 1:**

```text
Вход: [-2, 0, 1, 2], target=2
Выход: 1
Пояснение: сумма триплета [-2, 1, 2] ближе всего к цели.
```

**Пример 2:**

```text
Вход: [-3, -1, 1, 2], target=1
Выход: 0
Пояснение: сумма триплета [-3, 1, 2] ближе всего к цели.
```

**Пример 3:**

```text
Вход: [1, 0, 1, 1], target=100
Выход: 3
Пояснение: сумма триплета [1, 1, 1] ближе всего к цели.
```

## Решение

После сортировки фиксируем первый элемент, а два других ищем указателями `left` и `right`. На каждом шаге вычисляем разницу `target - currentSum` и сохраняем наименьшую по модулю. При равных модулях выбираем большую разницу: она соответствует меньшей сумме триплета.

Если разница положительна, нужна большая сумма, поэтому сдвигаем `left` вправо. Если разница отрицательна, сдвигаем `right` влево. Нулевая разница означает точное совпадение с целью.

## Код

```go
package main

import (
	"fmt"
	"math"
	"sort"
)

func absolute(value int) int {
	if value < 0 {
		return -value
	}
	return value
}

func searchClosestTriplet(arr []int, targetSum int) int {
	if len(arr) < 3 {
		panic("для триплета нужны как минимум три числа")
	}

	sort.Ints(arr)
	smallestDifference := math.MaxInt

	for i := 0; i < len(arr)-2; i++ {
		left, right := i+1, len(arr)-1
		for left < right {
			targetDifference := targetSum - arr[i] - arr[left] - arr[right]
			if targetDifference == 0 {
				return targetSum
			}

			if absolute(targetDifference) < absolute(smallestDifference) ||
				(absolute(targetDifference) == absolute(smallestDifference) && targetDifference > smallestDifference) {
				smallestDifference = targetDifference
			}

			if targetDifference > 0 {
				left++
			} else {
				right--
			}
		}
	}

	return targetSum - smallestDifference
}

func main() {
	fmt.Println(searchClosestTriplet([]int{-2, 0, 1, 2}, 2))
	fmt.Println(searchClosestTriplet([]int{-3, -1, 1, 2}, 1))
	fmt.Println(searchClosestTriplet([]int{1, 0, 1, 1}, 100))
}
```

**Вывод:**

```text
1
0
3
```

## Временная сложность

Сортировка занимает $$O(N \log N)$$, а перебор с двумя указателями — $$O(N^2)$$. Итоговая временная сложность равна $$O(N^2)$$.

## Пространственная сложность

Если не учитывать входной массив, сортировке может потребоваться до $$O(N)$$ дополнительной памяти.

{% include algo-task-nav.html position="bottom" %}
