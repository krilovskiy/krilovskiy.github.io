---
title: Медиана скользящего окна
description: Поиск медианы каждого окна фиксированного размера с помощью двух куч.
pattern: two-heaps
permalink: /posts/algo-patterns-two-heaps/sliding-window-median/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны массив чисел `nums` и число `k`. Найдите медиану каждого подмассива, или окна, размера `k`.

**Пример 1:**

```text
Вход: nums = [1, 2, -1, 3, 5], k = 2
Выход: [1.5, 0.5, 1.0, 4.0]
```

Окна размера `2` и их медианы:

* `[1, 2]` → `1.5`;
* `[2, -1]` → `0.5`;
* `[-1, 3]` → `1.0`;
* `[3, 5]` → `4.0`.

**Пример 2:**

```text
Вход: nums = [1, 2, -1, 3, 5], k = 3
Выход: [1.0, 2.0, 3.0]
```

Окна размера `3` и их медианы:

* `[1, 2, -1]` → `1.0`;
* `[2, -1, 3]` → `2.0`;
* `[-1, 3, 5]` → `3.0`.

## Решение

Задача следует паттерну двух куч и похожа на поиск медианы потока чисел. Поддерживаем максимальную кучу для меньшей половины чисел и минимальную кучу для большей половины.

Отличие в том, что теперь в кучах должны оставаться только `k` чисел текущего окна. На каждом шаге:

1. Добавляем очередное число в подходящую кучу.
2. Балансируем кучи: их размеры равны, либо в максимальной куче находится один дополнительный элемент.
3. Когда окно достигло размера `k`, вычисляем его медиану по вершинам куч.
4. Находим и удаляем число, которое выходит из окна.
5. Ещё раз балансируем кучи перед переходом к следующему окну.

## Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import (
	"container/heap"
	"fmt"
)

type IntHeap struct {
	values []int
	isMax  bool
}

func (h IntHeap) Len() int { return len(h.values) }

func (h IntHeap) Less(i, j int) bool {
	if h.isMax {
		return h.values[i] > h.values[j]
	}
	return h.values[i] < h.values[j]
}

func (h IntHeap) Swap(i, j int) {
	h.values[i], h.values[j] = h.values[j], h.values[i]
}

func (h *IntHeap) Push(value any) {
	h.values = append(h.values, value.(int))
}

func (h *IntHeap) Pop() any {
	lastIndex := len(h.values) - 1
	value := h.values[lastIndex]
	h.values = h.values[:lastIndex]
	return value
}

func (h IntHeap) Peek() int {
	return h.values[0]
}

type SlidingWindowMedian struct {
	maxHeap *IntHeap
	minHeap *IntHeap
}

func newSlidingWindowMedian() *SlidingWindowMedian {
	maxHeap := &IntHeap{isMax: true}
	minHeap := &IntHeap{}
	heap.Init(maxHeap)
	heap.Init(minHeap)
	return &SlidingWindowMedian{maxHeap: maxHeap, minHeap: minHeap}
}

func (finder *SlidingWindowMedian) insertNum(num int) {
	if finder.maxHeap.Len() == 0 || num <= finder.maxHeap.Peek() {
		heap.Push(finder.maxHeap, num)
	} else {
		heap.Push(finder.minHeap, num)
	}
	finder.rebalanceHeaps()
}

func (finder *SlidingWindowMedian) removeNum(num int) {
	target := finder.minHeap
	if finder.maxHeap.Len() > 0 && num <= finder.maxHeap.Peek() {
		target = finder.maxHeap
	}

	for index, value := range target.values {
		if value == num {
			heap.Remove(target, index)
			break
		}
	}

	finder.rebalanceHeaps()
}

func (finder *SlidingWindowMedian) rebalanceHeaps() {
	if finder.maxHeap.Len() > finder.minHeap.Len()+1 {
		heap.Push(finder.minHeap, heap.Pop(finder.maxHeap))
	} else if finder.maxHeap.Len() < finder.minHeap.Len() {
		heap.Push(finder.maxHeap, heap.Pop(finder.minHeap))
	}
}

func (finder *SlidingWindowMedian) findMedian() float64 {
	if finder.maxHeap.Len() == finder.minHeap.Len() {
		return float64(finder.maxHeap.Peek())/2.0 +
			float64(finder.minHeap.Peek())/2.0
	}
	return float64(finder.maxHeap.Peek())
}

func findSlidingWindowMedian(nums []int, k int) []float64 {
	if k <= 0 || k > len(nums) {
		return nil
	}

	finder := newSlidingWindowMedian()
	result := make([]float64, 0, len(nums)-k+1)

	for index, num := range nums {
		finder.insertNum(num)

		if index >= k-1 {
			result = append(result, finder.findMedian())
			finder.removeNum(nums[index-k+1])
		}
	}

	return result
}

func main() {
	fmt.Println("Медианы окон:", findSlidingWindowMedian([]int{1, 2, -1, 3, 5}, 2))
	fmt.Println("Медианы окон:", findSlidingWindowMedian([]int{1, 2, -1, 3, 5}, 3))
}
```

**Вывод:**

```text
Медианы окон: [1.5 0.5 1 4]
Медианы окон: [1 2 3]
```

## Временная сложность

Алгоритм проходит по всем $$N$$ числам. Вставка в кучу и восстановление её свойства после удаления занимают $$O(\log K)$$, но поиск выходящего числа в массиве кучи занимает $$O(K)$$. Поэтому общая временная сложность равна $$O(N \cdot K)$$.

## Пространственная сложность

Если не учитывать результирующий массив, пространственная сложность равна $$O(K)$$: в кучах одновременно хранятся только числа текущего окна.

{% include algo-task-nav.html position="bottom" %}
