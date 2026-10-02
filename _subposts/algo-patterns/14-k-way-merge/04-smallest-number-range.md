---
title: Минимальный диапазон чисел
description: Минимальный диапазон чисел — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: k-way-merge
permalink: /posts/algo-patterns-k-way-merge/smallest-number-range/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны `M` непустых отсортированных массивов. Найдите самый короткий диапазон, содержащий хотя бы одно число из каждого массива.

```text
[1, 5, 8], [4, 12], [7, 8, 10] → [4, 7]
[1, 9], [4, 12], [7, 10, 16] → [9, 12]
```

## Решение

Помещаем первые числа всех массивов в min-heap и сохраняем их максимум `currentMaxNumber`. Корень кучи и максимум образуют диапазон, покрывающий все массивы.

Извлекаем минимум и проверяем, стал ли диапазон короче лучшего. Добавляем следующее число из того же массива, обновляя максимум. Как только один массив закончится, прекращаем поиск: без его представителя покрыть все массивы уже нельзя.

Первый ответ содержит `5`, `4`, `7`, второй — `9`, `12`, `10`.

## Код

{% raw %}
```go
package main

import (
	"container/heap"
	"fmt"
)

type Entry struct{ value, arrayIndex, elementIndex int }
type EntryHeap []Entry

func (h EntryHeap) Len() int           { return len(h) }
func (h EntryHeap) Less(i, j int) bool { return h[i].value < h[j].value }
func (h EntryHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
func (h *EntryHeap) Push(x any)        { *h = append(*h, x.(Entry)) }
func (h *EntryHeap) Pop() any          { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }

func findSmallestRange(lists [][]int) [2]int {
	h := &EntryHeap{}
	currentMaxNumber := lists[0][0]
	for i, arr := range lists {
		heap.Push(h, Entry{arr[0], i, 0})
		if arr[0] > currentMaxNumber {
			currentMaxNumber = arr[0]
		}
	}
	result := [2]int{(*h)[0].value, currentMaxNumber}
	for h.Len() == len(lists) {
		current := heap.Pop(h).(Entry)
		if currentMaxNumber-current.value < result[1]-result[0] {
			result = [2]int{current.value, currentMaxNumber}
		}
		next := current.elementIndex + 1
		if next < len(lists[current.arrayIndex]) {
			value := lists[current.arrayIndex][next]
			heap.Push(h, Entry{value, current.arrayIndex, next})
			if value > currentMaxNumber {
				currentMaxNumber = value
			}
		}
	}
	return result
}

func main() {
	fmt.Println(findSmallestRange([][]int{{1, 5, 8}, {4, 12}, {7, 8, 10}}))
	fmt.Println(findSmallestRange([][]int{{1, 9}, {4, 12}, {7, 10, 16}}))
}
```
{% endraw %}

**Вывод:**

```text
[4 7]
[9 12]
```

## Временная сложность

$$O(N\log M)$$, где `N` — суммарное число элементов.

## Пространственная сложность

$$O(M)$$.

{% include algo-task-nav.html position="bottom" %}
