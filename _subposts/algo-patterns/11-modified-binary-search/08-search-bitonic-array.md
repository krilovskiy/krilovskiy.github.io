---
title: Поиск в битоническом массиве
description: Поиск key в возрастающей и убывающей частях битонического массива.
pattern: modified-binary-search
permalink: /posts/algo-patterns-modified-binary-search/search-bitonic-array/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан битонический массив, который сначала монотонно возрастает, затем монотонно убывает. Соседние элементы каждой части различны: `arr[i] != arr[i+1]`.

Найдите индекс числа `key`. Если число отсутствует, верните `-1`.

**Пример 1:**

```text
Вход: [1, 3, 8, 4, 3], key = 4
Выход: 3
```

**Пример 2:**

```text
Вход: [3, 8, 3, 1], key = 8
Выход: 1
```

**Пример 3:**

```text
Вход: [1, 3, 8, 12], key = 12
Выход: 3
```

**Пример 4:**

```text
Вход: [10, 9, 8], key = 10
Выход: 0
```

## Решение

Задача следует паттерну бинарного поиска.

1. Находим индекс максимального элемента `maxIndex`, как в задаче «Максимум битонического массива».
2. Выделяем два диапазона: от `0` до `maxIndex` по возрастанию и от `maxIndex+1` до `len(arr)-1` по убыванию.
3. Выполняем бинарный поиск с определением порядка сначала в первом диапазоне. Если `key` не найден, ищем во втором.

Сами подмассивы копировать не нужно: передаём границы в `binarySearch`.

## Код

{% raw %}
```go
package main

import "fmt"

func search(arr []int, key int) int {
	if len(arr) == 0 {
		return -1
	}
	maxIndex := findMax(arr)
	keyIndex := binarySearch(arr, key, 0, maxIndex)
	if keyIndex != -1 {
		return keyIndex
	}
	return binarySearch(arr, key, maxIndex+1, len(arr)-1)
}
func findMax(arr []int) int {
	start, end := 0, len(arr)-1
	for start < end {
		mid := start + (end-start)/2
		if arr[mid] > arr[mid+1] {
			end = mid
		} else {
			start = mid + 1
		}
	}
	return start
}
func binarySearch(arr []int, key, start, end int) int {
	if start > end {
		return -1
	}
	isAscending := arr[start] < arr[end]
	for start <= end {
		mid := start + (end-start)/2
		if key == arr[mid] {
			return mid
		}
		if isAscending {
			if key < arr[mid] {
				end = mid - 1
			} else {
				start = mid + 1
			}
		} else {
			if key > arr[mid] {
				end = mid - 1
			} else {
				start = mid + 1
			}
		}
	}
	return -1
}
func main() {
	fmt.Println("Индекс:", search([]int{1, 3, 8, 4, 3}, 4))
	fmt.Println("Индекс:", search([]int{3, 8, 3, 1}, 8))
	fmt.Println("Индекс:", search([]int{1, 3, 8, 12}, 12))
	fmt.Println("Индекс:", search([]int{10, 9, 8}, 10))
}
```
{% endraw %}

**Вывод:**

```text
Индекс: 3
Индекс: 1
Индекс: 3
Индекс: 0
```

## Временная сложность

Поиск максимума и поиск в каждой из двух частей требуют $$O(\log N)$$. Сумма трёх таких поисков остаётся $$O(\log N)$$. Временная сложность — $$O(\log N)$$, где $$N$$ — число элементов массива.

## Пространственная сложность

Алгоритм использует постоянную дополнительную память — $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
