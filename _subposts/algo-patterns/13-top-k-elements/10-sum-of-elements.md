---
title: Сумма между порядковыми элементами
description: Сумма между порядковыми элементами — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: top-k-elements
permalink: /posts/algo-patterns-top-k-elements/sum-of-elements/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Найдите сумму чисел строго между `K1`-м и `K2`-м наименьшими элементами массива. Позиции считаются с единицы; `1 ≤ K1 < K2 ≤ N`.

```text
[1, 3, 12, 5, 15, 11], K1 = 3, K2 = 6 → 23
[3, 5, 8, 7], K1 = 1, K2 = 4 → 12
```

## Решение

Вставляем все числа в min-heap. Удаляем первые `K1` элементов. Следующие `K2-K1-1` элементов извлекаем и суммируем. В первом примере между `5` и `15` стоят `11` и `12`, во втором между `3` и `8` — `5` и `7`.

## Код

{% raw %}
```go
package main

import (
	"container/heap"
	"fmt"
)

type IntHeap []int

func (h IntHeap) Len() int           { return len(h) }
func (h IntHeap) Less(i, j int) bool { return h[i] < h[j] }
func (h IntHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
func (h *IntHeap) Push(x any)        { *h = append(*h, x.(int)) }
func (h *IntHeap) Pop() any          { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }
func findSumOfElements(nums []int, k1, k2 int) int {
	h := &IntHeap{}
	for _, n := range nums {
		heap.Push(h, n)
	}
	for i := 0; i < k1; i++ {
		heap.Pop(h)
	}
	sum := 0
	for i := 0; i < k2-k1-1; i++ {
		sum += heap.Pop(h).(int)
	}
	return sum
}
func main() {
	fmt.Println(findSumOfElements([]int{1, 3, 12, 5, 15, 11}, 3, 6))
	fmt.Println(findSumOfElements([]int{3, 5, 8, 7}, 1, 4))
}
```
{% endraw %}

**Вывод:**

```text
23
12
```

## Временная сложность

$$O(N\log N)$$.

## Пространственная сложность

$$O(N)$$.

## Альтернативное решение

Храним в max-heap `K2-1` наименьших чисел. Извлекаем и складываем `K2-K1-1` наибольших из них. Сам `K2`-й элемент не включаем в кучу.

{% raw %}
```go
package main

import (
	"container/heap"
	"fmt"
)

type IntHeap []int

func (h IntHeap) Len() int           { return len(h) }
func (h IntHeap) Less(i, j int) bool { return h[i] > h[j] }
func (h IntHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
func (h *IntHeap) Push(x any)        { *h = append(*h, x.(int)) }
func (h *IntHeap) Pop() any          { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }
func findSumOfElements(nums []int, k1, k2 int) int {
	h := &IntHeap{}
	for _, n := range nums {
		if h.Len() < k2-1 {
			heap.Push(h, n)
		} else if n < (*h)[0] {
			heap.Pop(h)
			heap.Push(h, n)
		}
	}
	sum := 0
	for i := 0; i < k2-k1-1; i++ {
		sum += heap.Pop(h).(int)
	}
	return sum
}
func main() {
	fmt.Println(findSumOfElements([]int{1, 3, 12, 5, 15, 11}, 3, 6))
	fmt.Println(findSumOfElements([]int{3, 5, 8, 7}, 1, 4))
}
```
{% endraw %}

**Вывод:**

```text
23
12
```

Время — $$O(N\log K2)$$, память — $$O(K2)$$.

{% include algo-task-nav.html position="bottom" %}
