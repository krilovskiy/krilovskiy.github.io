---
title: K-е наибольшее число в потоке
description: K-е наибольшее число в потоке — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: top-k-elements
permalink: /posts/algo-patterns-top-k-elements/kth-largest-in-stream/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Создайте структуру, которая принимает исходный массив и `K`, а при каждом вызове `add(num)` добавляет число и возвращает `K`-е наибольшее число потока.

```text
Начальные числа: [3, 1, 5, 12, 2, 11], K = 4
add(6) → 5
add(13) → 6
add(4) → 6
```

## Решение

Храним `K` наибольших чисел в min-heap. При добавлении вставляем число и удаляем минимум, если размер стал больше `K`. Корень — нужный порядковый элемент. Предполагаем положительное `K` и хотя бы `K` чисел в потоке к моменту запроса ответа.

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

type KthLargestNumberInStream struct {
	minHeap IntHeap
	k       int
}

func newKthLargestNumberInStream(nums []int, k int) *KthLargestNumberInStream {
	s := &KthLargestNumberInStream{k: k}
	for _, n := range nums {
		s.add(n)
	}
	return s
}
func (s *KthLargestNumberInStream) add(num int) int {
	heap.Push(&s.minHeap, num)
	if s.minHeap.Len() > s.k {
		heap.Pop(&s.minHeap)
	}
	return s.minHeap[0]
}
func main() {
	s := newKthLargestNumberInStream([]int{3, 1, 5, 12, 2, 11}, 4)
	fmt.Println(s.add(6))
	fmt.Println(s.add(13))
	fmt.Println(s.add(4))
}
```
{% endraw %}

**Вывод:**

```text
5
6
6
```

## Временная сложность

Один `add` — $$O(\log K)$$, создание из `N` чисел — $$O(N\log K)$$.

## Пространственная сложность

$$O(K)$$.

{% include algo-task-nav.html position="bottom" %}
