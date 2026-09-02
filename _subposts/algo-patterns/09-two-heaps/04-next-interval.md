---
title: Следующий интервал
description: Поиск ближайшего подходящего интервала для каждого интервала с помощью двух куч.
pattern: two-heaps
permalink: /posts/algo-patterns-two-heaps/next-interval/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан массив интервалов. Для каждого интервала `i` найдите следующий интервал `j`: его начало должно быть не меньше конца интервала `i` и быть наименьшим среди всех подходящих начал.

Верните массив индексов следующих интервалов. Если подходящего интервала нет, запишите `-1`. Начальные точки всех интервалов различны.

**Пример 1:**

```text
Вход: [[2, 3], [3, 4], [5, 6]]
Выход: [1, 2, -1]
```

Следующим для `[2, 3]` будет `[3, 4]` с индексом `1`, а для `[3, 4]` — `[5, 6]` с индексом `2`. Для `[5, 6]` следующего интервала нет.

**Пример 2:**

```text
Вход: [[3, 4], [1, 5], [4, 6]]
Выход: [2, -1, -1]
```

Следующим для `[3, 4]` будет `[4, 6]` с индексом `2`. Для двух остальных интервалов подходящих следующих интервалов нет.

## Решение

Перебор для каждого интервала всех остальных требует $$O(N^2)$$ времени. Паттерн двух куч позволяет найти следующие интервалы быстрее.

Добавим все интервалы в две максимальные кучи: `maxStartHeap` упорядочим по началам, а `maxEndHeap` — по концам. Затем выполним следующие шаги:

1. Извлекаем из `maxEndHeap` интервал с наибольшим концом — `topEnd`.
2. Извлекаем из `maxStartHeap` все интервалы, начало которых не меньше конца `topEnd`. Последний извлечённый интервал имеет наименьшее подходящее начало.
3. Записываем его индекс в результат для `topEnd`. Если подходящего интервала нет, оставляем `-1`.
4. Возвращаем последний подходящий интервал в `maxStartHeap`: он может оказаться следующим и для других интервалов.
5. Повторяем шаги, пока `maxEndHeap` не опустеет.

Интервалы с большими началами, извлечённые раньше последнего кандидата, возвращать не нужно. Концы обрабатываются по убыванию, поэтому для последующих интервалов последний кандидат всегда будет не хуже них.

## Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import (
	"container/heap"
	"fmt"
)

type Interval struct {
	Start int
	End   int
}

type IndexedValue struct {
	Value int
	Index int
}

type MaxHeap []IndexedValue

func (h MaxHeap) Len() int           { return len(h) }
func (h MaxHeap) Less(i, j int) bool { return h[i].Value > h[j].Value }
func (h MaxHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }

func (h *MaxHeap) Push(value any) {
	*h = append(*h, value.(IndexedValue))
}

func (h *MaxHeap) Pop() any {
	old := *h
	lastIndex := len(old) - 1
	value := old[lastIndex]
	*h = old[:lastIndex]
	return value
}

func (h MaxHeap) Peek() IndexedValue {
	return h[0]
}

func findNextInterval(intervals []Interval) []int {
	maxStartHeap := &MaxHeap{}
	maxEndHeap := &MaxHeap{}
	heap.Init(maxStartHeap)
	heap.Init(maxEndHeap)

	result := make([]int, len(intervals))
	for index, interval := range intervals {
		result[index] = -1
		heap.Push(maxStartHeap, IndexedValue{Value: interval.Start, Index: index})
		heap.Push(maxEndHeap, IndexedValue{Value: interval.End, Index: index})
	}

	for maxEndHeap.Len() > 0 {
		topEnd := heap.Pop(maxEndHeap).(IndexedValue)

		if maxStartHeap.Len() == 0 || maxStartHeap.Peek().Value < topEnd.Value {
			continue
		}

		topStart := heap.Pop(maxStartHeap).(IndexedValue)
		for maxStartHeap.Len() > 0 && maxStartHeap.Peek().Value >= topEnd.Value {
			topStart = heap.Pop(maxStartHeap).(IndexedValue)
		}

		result[topEnd.Index] = topStart.Index
		heap.Push(maxStartHeap, topStart)
	}

	return result
}

func main() {
	fmt.Println("Индексы следующих интервалов:", findNextInterval([]Interval{
		{Start: 2, End: 3},
		{Start: 3, End: 4},
		{Start: 5, End: 6},
	}))
	fmt.Println("Индексы следующих интервалов:", findNextInterval([]Interval{
		{Start: 3, End: 4},
		{Start: 1, End: 5},
		{Start: 4, End: 6},
	}))
}
```

**Вывод:**

```text
Индексы следующих интервалов: [1 2 -1]
Индексы следующих интервалов: [2 -1 -1]
```

## Временная сложность

Каждый интервал добавляется в обе кучи, а операции с кучами занимают $$O(\log N)$$. Общая временная сложность равна $$O(N \log N)$$.

## Пространственная сложность

Пространственная сложность равна $$O(N)$$, потому что все интервалы хранятся в кучах.

{% include algo-task-nav.html position="bottom" %}
