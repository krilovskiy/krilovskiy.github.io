---
title: Общее свободное время сотрудников
description: Поиск конечных интервалов, в которые свободны все сотрудники.
pattern: merge-intervals
permalink: /posts/algo-patterns-merge-intervals/employee-free-time/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Для $$K$$ сотрудников даны списки интервалов их рабочего времени. Найдите конечные интервалы, в которые свободны все сотрудники. Список рабочего времени каждого сотрудника отсортирован по времени начала.

### Пример 1

- Входные данные: `[[[1,3], [5,6]], [[2,3], [6,8]]]`.
- Выходные данные: `[[3,5]]`.
- Объяснение: оба сотрудника свободны между моментами `3` и `5`.

### Пример 2

- Входные данные: `[[[1,3], [9,12]], [[2,4]], [[6,8]]]`.
- Выходные данные: `[[4,6], [8,9]]`.
- Объяснение: все сотрудники свободны на интервалах `[4,6]` и `[8,9]`.

### Пример 3

- Входные данные: `[[[1,3]], [[2,4]], [[3,5], [7,9]]]`.
- Выходные данные: `[[5,7]]`.
- Объяснение: все сотрудники свободны между моментами `5` и `7`.

## Решение

Простой подход — собрать все рабочие интервалы в один список, отсортировать его и найти промежутки. Это заняло бы $$O(N \log N)$$ времени, где $$N$$ — общее количество интервалов. Но каждый список сотрудника уже отсортирован, и это позволяет выполнить слияние с помощью минимальной кучи.

1. Добавить в кучу первый рабочий интервал каждого сотрудника. Куча упорядочена по времени начала.
2. Извлечь интервал с самым ранним началом и сравнить его с объединённым рабочим интервалом, обработанным ранее.
3. Если между интервалами есть разрыв, добавить его в результат как общее свободное время. Если интервалы пересекаются, расширить объединённый рабочий интервал до более позднего окончания.
4. После извлечения интервала добавить в кучу следующий интервал того же сотрудника.
5. Продолжать, пока куча не опустеет.

Результат содержит только конечные промежутки между рабочими интервалами. Неограниченное время до первой и после последней встречи в него не входит.

## Код

{% raw %}

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

func (interval Interval) String() string {
	return fmt.Sprintf("[%d,%d]", interval.Start, interval.End)
}

type employeeInterval struct {
	EmployeeIndex int
	IntervalIndex int
	Interval      Interval
}

type employeeIntervalHeap []employeeInterval

func (h employeeIntervalHeap) Len() int { return len(h) }
func (h employeeIntervalHeap) Less(i, j int) bool {
	return h[i].Interval.Start < h[j].Interval.Start
}
func (h employeeIntervalHeap) Swap(i, j int) { h[i], h[j] = h[j], h[i] }

func (h *employeeIntervalHeap) Push(value any) {
	*h = append(*h, value.(employeeInterval))
}

func (h *employeeIntervalHeap) Pop() any {
	old := *h
	last := old[len(old)-1]
	*h = old[:len(old)-1]
	return last
}

func findEmployeeFreeTime(schedule [][]Interval) []Interval {
	intervals := &employeeIntervalHeap{}
	heap.Init(intervals)

	for employeeIndex, employeeSchedule := range schedule {
		if len(employeeSchedule) == 0 {
			continue
		}
		heap.Push(intervals, employeeInterval{
			EmployeeIndex: employeeIndex,
			IntervalIndex: 0,
			Interval:      employeeSchedule[0],
		})
	}

	if intervals.Len() == 0 {
		return nil
	}

	previous := (*intervals)[0].Interval
	result := []Interval{}

	for intervals.Len() > 0 {
		current := heap.Pop(intervals).(employeeInterval)

		if previous.End < current.Interval.Start {
			result = append(result, Interval{
				Start: previous.End,
				End:   current.Interval.Start,
			})
			previous = current.Interval
		} else if current.Interval.End > previous.End {
			previous.End = current.Interval.End
		}

		nextIndex := current.IntervalIndex + 1
		employeeSchedule := schedule[current.EmployeeIndex]
		if nextIndex < len(employeeSchedule) {
			heap.Push(intervals, employeeInterval{
				EmployeeIndex: current.EmployeeIndex,
				IntervalIndex: nextIndex,
				Interval:      employeeSchedule[nextIndex],
			})
		}
	}

	return result
}

func main() {
	fmt.Println(findEmployeeFreeTime([][]Interval{
		{{Start: 1, End: 3}, {Start: 5, End: 6}},
		{{Start: 2, End: 3}, {Start: 6, End: 8}},
	}))
	fmt.Println(findEmployeeFreeTime([][]Interval{
		{{Start: 1, End: 3}, {Start: 9, End: 12}},
		{{Start: 2, End: 4}},
		{{Start: 6, End: 8}},
	}))
	fmt.Println(findEmployeeFreeTime([][]Interval{
		{{Start: 1, End: 3}},
		{{Start: 2, End: 4}},
		{{Start: 3, End: 5}, {Start: 7, End: 9}},
	}))
}
```

{% endraw %}

**Вывод:**

```text
[[3,5]]
[[4,6] [8,9]]
[[5,7]]
```

## Временная сложность

Каждый из $$N$$ интервалов один раз добавляется в кучу и один раз удаляется из неё. В куче одновременно находится не больше $$K$$ элементов, поэтому временная сложность равна $$O(N \log K)$$.

## Пространственная сложность

Куча содержит не больше одного интервала каждого сотрудника, поэтому без учёта результата требуется $$O(K)$$ дополнительной памяти.

{% include algo-task-nav.html position="bottom" %}
