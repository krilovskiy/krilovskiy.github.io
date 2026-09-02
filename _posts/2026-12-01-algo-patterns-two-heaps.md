---
title: Алгосы от Влада, часть 9. Две кучи
date: 2026-12-01 00:00:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
math: true
pattern: two-heaps
short_title: Две кучи
primary_task_title: Медиана потока чисел
primary_task_anchor: median-of-a-number-stream
---


* [Введение](/posts/algo-patterns/)
* [Скользящее окно](/posts/algo-patterns-sliding-window/)
* [Два указателя или итератор](/posts/algo-patterns-two-pointers/)
* [Быстрый и медленный указатель](/posts/algo-patterns-fast-slow-pointer/)
* [Мерж интервалов](/posts/algo-patterns-merge-intervals/)
* [Циклическая сортировка](/posts/algo-patterns-cyclic-sort/)
* [Инвертирование связанного списка на месте](/posts/algo-patterns-in-place-reversal-linked-list/)
* [Дерево BFS](/posts/algo-patterns-tree-breadth-first-search/)
* [Дерево DFS](/posts/algo-patterns-tree-depth-first-search/)
* <b>Две кучи</b>
* Подмножества
* Модифицированный бинарный поиск
* Побитовый XOR
* Лучшие элементы К (top K elements)
* k-образный алгоритм слияния (K-Way merge)
* 0 or 1 Knapsack (Динамическое программирование)
* Топологическая сортировка


## Введение

Во многих задачах набор элементов можно разделить на две части, а для решения достаточно знать наименьший элемент одной части и наибольший элемент другой. Паттерн двух куч позволяет эффективно поддерживать именно эти границы.

Для одной части используется минимальная куча, которая быстро возвращает наименьший элемент, а для другой — максимальная куча, которая быстро возвращает наибольший элемент.

Посмотрим, как этот паттерн работает, на задаче о медиане потока чисел.


## Медиана потока чисел (средний уровень) {#median-of-a-number-stream}

### Условие задачи

Спроектируйте структуру данных, которая вычисляет медиану потока чисел. У неё должны быть два метода:

* `insertNum(num int)` сохраняет число;
* `findMedian()` возвращает медиану всех сохранённых чисел.

Если чисел чётное количество, медиана равна среднему арифметическому двух средних чисел.

Например, последовательно добавим числа `3`, `1`, `5` и `4`. После первых двух чисел медиана равна `2.0`, после третьего — `3.0`, после четвёртого — `3.5`.

### Решение

Прямолинейное решение хранит все числа в отсортированном списке. Тогда медиану можно получить быстро, но вставка нового числа занимает $$O(N)$$ времени, как во время сортировки вставками. Полностью сортировать поток не требуется: нас интересуют только средние элементы.

Пусть `x` — медиана списка. Половина чисел меньше или равна `x`, а другая половина больше или равна `x`. Разделим числа на две части:

1. Меньшую половину храним в максимальной куче `maxHeap`. На её вершине находится наибольшее число этой половины.
2. Большую половину храним в минимальной куче `minHeap`. На её вершине находится наименьшее число этой половины.
3. После каждой вставки балансируем кучи. Их размеры должны быть равны, либо в `maxHeap` должен находиться один дополнительный элемент.
4. При чётном количестве чисел медиана равна среднему значений на вершинах обеих куч.
5. При нечётном количестве чисел медиана находится на вершине `maxHeap`.

Вставка в кучу занимает $$O(\log N)$$ времени, а обе границы доступны на вершинах куч за $$O(1)$$.

<div class="d-sm-none">
  <a href="/assets/img/posts/2026-12-01-algo-patterns-two-heaps/median-stream-steps-mobile.svg"><img src="/assets/img/posts/2026-12-01-algo-patterns-two-heaps/median-stream-steps-mobile.svg" alt="Балансировка двух куч после последовательной вставки чисел 3, 1, 5 и 4" width="360"></a>
</div>
<div class="d-none d-sm-block">
  <a href="/assets/img/posts/2026-12-01-algo-patterns-two-heaps/median-stream-steps.svg"><img src="/assets/img/posts/2026-12-01-algo-patterns-two-heaps/median-stream-steps.svg" alt="Балансировка двух куч после последовательной вставки чисел 3, 1, 5 и 4" width="920"></a>
</div>

### Код

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

type MedianOfAStream struct {
	maxHeap *IntHeap
	minHeap *IntHeap
}

func newMedianOfAStream() *MedianOfAStream {
	maxHeap := &IntHeap{isMax: true}
	minHeap := &IntHeap{}
	heap.Init(maxHeap)
	heap.Init(minHeap)
	return &MedianOfAStream{maxHeap: maxHeap, minHeap: minHeap}
}

func (stream *MedianOfAStream) insertNum(num int) {
	if stream.maxHeap.Len() == 0 || stream.maxHeap.Peek() >= num {
		heap.Push(stream.maxHeap, num)
	} else {
		heap.Push(stream.minHeap, num)
	}

	if stream.maxHeap.Len() > stream.minHeap.Len()+1 {
		heap.Push(stream.minHeap, heap.Pop(stream.maxHeap))
	} else if stream.maxHeap.Len() < stream.minHeap.Len() {
		heap.Push(stream.maxHeap, heap.Pop(stream.minHeap))
	}
}

func (stream *MedianOfAStream) findMedian() float64 {
	if stream.maxHeap.Len() == stream.minHeap.Len() {
		return float64(stream.maxHeap.Peek())/2.0 +
			float64(stream.minHeap.Peek())/2.0
	}
	return float64(stream.maxHeap.Peek())
}

func main() {
	stream := newMedianOfAStream()
	stream.insertNum(3)
	stream.insertNum(1)
	fmt.Printf("Медиана: %.1f\n", stream.findMedian())

	stream.insertNum(5)
	fmt.Printf("Медиана: %.1f\n", stream.findMedian())

	stream.insertNum(4)
	fmt.Printf("Медиана: %.1f\n", stream.findMedian())
}
```

**Вывод:**

```text
Медиана: 2.0
Медиана: 3.0
Медиана: 3.5
```

### Временная сложность

Метод `insertNum()` работает за $$O(\log N)$$ из-за вставки в кучу. Метод `findMedian()` работает за $$O(1)$$, поскольку медиана вычисляется по вершинам куч.

### Пространственная сложность

Пространственная сложность равна $$O(N)$$, потому что в кучах хранятся все добавленные числа.


## Задачи главы

1. [Медиана потока чисел (средний уровень)](#median-of-a-number-stream)
2. [Медиана скользящего окна (сложный уровень)](/posts/algo-patterns-two-heaps/sliding-window-median/)
3. [Максимизация капитала (сложный уровень)](/posts/algo-patterns-two-heaps/maximize-capital/)
4. [Следующий интервал (сложный уровень)](/posts/algo-patterns-two-heaps/next-interval/)


## Похожие задания

### Pattern: Two Heaps

1. Find Median from Data Stream [Leetcode](https://leetcode.com/problems/find-median-from-data-stream/)
2. Sliding Window Median [Leetcode](https://leetcode.com/problems/sliding-window-median/)
3. IPO [Leetcode](https://leetcode.com/problems/ipo/)
4. Find Right Interval [Leetcode](https://leetcode.com/problems/find-right-interval/)
