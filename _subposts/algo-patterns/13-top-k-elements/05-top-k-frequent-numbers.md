---
title: K наиболее частых чисел
description: K наиболее частых чисел — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: top-k-elements
permalink: /posts/algo-patterns-top-k-elements/top-k-frequent-numbers/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Найдите `K` наиболее часто встречающихся чисел в неотсортированном массиве. При одинаковой частоте допустим любой выбор.

```text
[1, 3, 5, 12, 11, 12, 11], K = 2 → [12, 11]
[5, 12, 11, 3, 11], K = 2 → [11, 5], [11, 12] или [11, 3]
```

## Решение

Сначала считаем частоту каждого числа в хеш-таблице. Затем храним `K` наиболее частых чисел в min-heap, сравнивая частоты. После добавления кандидата удаляем корень, если размер превысил `K`. Для воспроизводимого вывода при равенстве частот код сравнивает сами числа.

## Код

{% raw %}
```go
package main

import (
	"container/heap"
	"fmt"
)

type Entry struct{ number, frequency int }
type FrequencyHeap []Entry

func (h FrequencyHeap) Len() int { return len(h) }
func (h FrequencyHeap) Less(i, j int) bool {
	return h[i].frequency < h[j].frequency || h[i].frequency == h[j].frequency && h[i].number < h[j].number
}
func (h FrequencyHeap) Swap(i, j int) { h[i], h[j] = h[j], h[i] }
func (h *FrequencyHeap) Push(x any)   { *h = append(*h, x.(Entry)) }
func (h *FrequencyHeap) Pop() any     { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }
func findTopKFrequentNumbers(nums []int, k int) []int {
	freq := map[int]int{}
	for _, n := range nums {
		freq[n]++
	}
	h := &FrequencyHeap{}
	for n, f := range freq {
		heap.Push(h, Entry{n, f})
		if h.Len() > k {
			heap.Pop(h)
		}
	}
	result := []int{}
	for h.Len() > 0 {
		result = append(result, heap.Pop(h).(Entry).number)
	}
	return result
}
func main() {
	fmt.Println(findTopKFrequentNumbers([]int{1, 3, 5, 12, 11, 12, 11}, 2))
	fmt.Println(findTopKFrequentNumbers([]int{5, 12, 11, 3, 11}, 2))
}
```
{% endraw %}

**Вывод:**

```text
[11 12]
[12 11]
```

## Временная сложность

$$O(N+N\log K)$$.

## Пространственная сложность

$$O(N)$$ для таблицы частот и кучи.

{% include algo-task-nav.html position="bottom" %}
