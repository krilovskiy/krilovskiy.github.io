---
title: Самый длинный подмассив из единиц после замен
description: Поиск самого длинного непрерывного подмассива из единиц после замены не более k нулей.
pattern: sliding-window
permalink: /posts/algo-patterns-sliding-window/longest-subarray-ones-replacement/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан массив, содержащий нули и единицы. Разрешается заменить не более `k` нулей на единицы. Найдите длину самого длинного непрерывного подмассива, состоящего из единиц после таких замен.

**Пример 1:**

```text
Вход: [0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1], k=2
Выход: 6
Пояснение: заменим нули с индексами 5 и 8.
```

**Пример 2:**

```text
Вход: [0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1], k=3
Выход: 9
Пояснение: заменим нули с индексами 6, 9 и 10.
```

## Решение

Эта задача аналогична поиску самой длинной подстроки из одинаковых букв после замен, но массив содержит только нули и единицы.

Расширяя окно, считаем единицы в нём. Количество нулей равно разности между длиной окна и числом единиц. Если нулей стало больше `k`, сдвигаем левую границу вправо и, когда из окна выходит единица, уменьшаем их счётчик. После этого обновляем максимальную длину.

## Код

```go
package main

import "fmt"

func longestSubarrayWithOnesAfterReplacement(arr []int, k int) int {
	windowStart := 0
	maxOnesCount := 0
	maxLength := 0

	for windowEnd, value := range arr {
		if value == 1 {
			maxOnesCount++
		}

		if windowEnd-windowStart+1-maxOnesCount > k {
			if arr[windowStart] == 1 {
				maxOnesCount--
			}
			windowStart++
		}

		windowLength := windowEnd - windowStart + 1
		if windowLength > maxLength {
			maxLength = windowLength
		}
	}

	return maxLength
}

func main() {
	fmt.Println(longestSubarrayWithOnesAfterReplacement([]int{0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1}, 2))
	fmt.Println(longestSubarrayWithOnesAfterReplacement([]int{0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1}, 3))
}
```

**Вывод:**

```text
6
9
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — количество элементов массива.

## Пространственная сложность

Алгоритм использует постоянный объём дополнительной памяти, поэтому пространственная сложность равна $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
