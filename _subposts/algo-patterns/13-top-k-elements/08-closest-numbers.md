---
title: K ближайших чисел
description: K ближайших чисел — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: top-k-elements
permalink: /posts/algo-patterns-top-k-elements/closest-numbers/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

В отсортированном массиве найдите `K` ближайших к `X` чисел. Верните их в порядке возрастания. Самого `X` в массиве может не быть.

```text
[5, 6, 7, 8, 9], K = 3, X = 7 → [6, 7, 8]
[2, 4, 5, 6, 9], K = 3, X = 6 → [4, 5, 6]
[2, 4, 5, 6, 9], K = 3, X = 10 → [5, 6, 9]
```

## Решение

Бинарным поиском находим `X` либо позицию рядом с местом его вставки. Ближайшие числа расположены вокруг этой позиции. Берём кандидатов в пределах `K` позиций в каждую сторону, ограничивая диапазон границами массива.

Складываем кандидатов в min-heap по абсолютной разности с `X`, извлекаем `K` элементов и сортируем результат. При равном расстоянии код предпочитает меньшее число.

## Код

{% raw %}
```go
package main

import (
	"container/heap"
	"fmt"
	"sort"
)

func binarySearch(arr []int, target int) int {
	low, high := 0, len(arr)-1
	for low <= high {
		mid := low + (high-low)/2
		if arr[mid] == target {
			return mid
		}
		if arr[mid] < target {
			low = mid + 1
		} else {
			high = mid - 1
		}
	}
	if low > 0 {
		return low - 1
	}
	return low
}
func abs(n int) int {
	if n < 0 {
		return -n
	}
	return n
}

type Entry struct{ distance, value int }
type EntryHeap []Entry

func (h EntryHeap) Len() int { return len(h) }
func (h EntryHeap) Less(i, j int) bool {
	return h[i].distance < h[j].distance || h[i].distance == h[j].distance && h[i].value < h[j].value
}
func (h EntryHeap) Swap(i, j int) { h[i], h[j] = h[j], h[i] }
func (h *EntryHeap) Push(x any)   { *h = append(*h, x.(Entry)) }
func (h *EntryHeap) Pop() any     { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }
func findClosestElements(arr []int, k, x int) []int {
	index := binarySearch(arr, x)
	low, high := index-k, index+k
	if low < 0 {
		low = 0
	}
	if high >= len(arr) {
		high = len(arr) - 1
	}
	h := &EntryHeap{}
	for i := low; i <= high; i++ {
		heap.Push(h, Entry{abs(arr[i] - x), arr[i]})
	}
	result := []int{}
	for i := 0; i < k; i++ {
		result = append(result, heap.Pop(h).(Entry).value)
	}
	sort.Ints(result)
	return result
}
func main() {
	fmt.Println(findClosestElements([]int{5, 6, 7, 8, 9}, 3, 7))
	fmt.Println(findClosestElements([]int{2, 4, 5, 6, 9}, 3, 6))
	fmt.Println(findClosestElements([]int{2, 4, 5, 6, 9}, 3, 10))
}
```
{% endraw %}

**Вывод:**

```text
[6 7 8]
[4 5 6]
[5 6 9]
```

## Временная сложность

$$O(\log N+K\log K)$$.

## Пространственная сложность

$$O(K)$$.

## Альтернативное решение: два указателя

После бинарного поиска двигаем левый указатель назад, правый — вперёд. Каждый раз выбираем меньшую разность с `X`. В исходнике выбранные слева числа добавляются в начало двусторонней очереди, справа — в конец. В массиве выбранные позиции образуют непрерывный отрезок: в Go достаточно скопировать его после `K` шагов.

{% raw %}
```go
package main

import (
	"fmt"
)

func binarySearch(arr []int, target int) int {
	low, high := 0, len(arr)-1
	for low <= high {
		mid := low + (high-low)/2
		if arr[mid] == target {
			return mid
		}
		if arr[mid] < target {
			low = mid + 1
		} else {
			high = mid - 1
		}
	}
	if low > 0 {
		return low - 1
	}
	return low
}
func abs(n int) int {
	if n < 0 {
		return -n
	}
	return n
}
func findClosestElements(arr []int, k, x int) []int {
	index := binarySearch(arr, x)
	leftPointer, rightPointer := index, index+1
	for i := 0; i < k; i++ {
		if leftPointer >= 0 && (rightPointer >= len(arr) || abs(x-arr[leftPointer]) <= abs(x-arr[rightPointer])) {
			leftPointer--
		} else {
			rightPointer++
		}
	}
	return append([]int(nil), arr[leftPointer+1:rightPointer]...)
}
func main() {
	fmt.Println(findClosestElements([]int{5, 6, 7, 8, 9}, 3, 7))
	fmt.Println(findClosestElements([]int{2, 4, 5, 6, 9}, 3, 6))
	fmt.Println(findClosestElements([]int{2, 4, 5, 6, 9}, 3, 10))
}
```
{% endraw %}

**Вывод:**

```text
[6 7 8]
[4 5 6]
[5 6 9]
```

Время — $$O(\log N+K)$$, дополнительная память без результата — $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
