---
title: Максимальная нагрузка на процессор
description: Поиск максимальной суммарной нагрузки от одновременно выполняющихся задач.
pattern: merge-intervals
permalink: /posts/algo-patterns-merge-intervals/maximum-cpu-load/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан список задач. У каждой задачи есть время начала, время окончания и нагрузка на процессор во время выполнения. Найдите максимальную нагрузку на процессор в любой момент времени, если все задачи выполняются на одной машине.

### Пример 1

- Входные данные: `[[1,4,3], [2,5,4], [7,9,6]]`.
- Выходные данные: `7`.
- Объяснение: задачи `[1,4,3]` и `[2,5,4]` пересекаются. На интервале `[2,4]` их суммарная нагрузка равна `3 + 4 = 7`.

### Пример 2

- Входные данные: `[[6,7,10], [2,4,11], [8,12,15]]`.
- Выходные данные: `15`.
- Объяснение: задачи не пересекаются, поэтому максимальная нагрузка равна наибольшей нагрузке одной задачи.

### Пример 3

- Входные данные: `[[1,4,2], [2,4,1], [3,6,5]]`.
- Выходные данные: `8`.
- Объяснение: на интервале `[3,4]` выполняются все три задачи, и их суммарная нагрузка равна `2 + 1 + 5 = 8`.

## Решение

Задача сводится к поиску количества занятых переговорных комнат, но вместо количества активных интервалов нужно отслеживать сумму их нагрузок.

1. Отсортировать задачи по времени начала.
2. Хранить активные задачи в минимальной куче по времени окончания.
3. Перед добавлением очередной задачи удалить все завершившиеся задачи и вычесть их нагрузку из текущей суммы.
4. Добавить новую задачу и прибавить её нагрузку.
5. Обновить максимальную нагрузку.

## Код

{% raw %}

```go
package main

import (
	"container/heap"
	"fmt"
	"sort"
)

type Job struct {
	Start int
	End   int
	Load  int
}

type jobHeap []Job

func (h jobHeap) Len() int           { return len(h) }
func (h jobHeap) Less(i, j int) bool { return h[i].End < h[j].End }
func (h jobHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }

func (h *jobHeap) Push(value any) {
	*h = append(*h, value.(Job))
}

func (h *jobHeap) Pop() any {
	old := *h
	last := old[len(old)-1]
	*h = old[:len(old)-1]
	return last
}

func findMaximumCPULoad(jobs []Job) int {
	if len(jobs) == 0 {
		return 0
	}

	sort.Slice(jobs, func(i, j int) bool {
		return jobs[i].Start < jobs[j].Start
	})

	active := &jobHeap{}
	heap.Init(active)
	currentLoad := 0
	maximumLoad := 0

	for _, job := range jobs {
		for active.Len() > 0 && (*active)[0].End <= job.Start {
			finished := heap.Pop(active).(Job)
			currentLoad -= finished.Load
		}

		heap.Push(active, job)
		currentLoad += job.Load
		maximumLoad = max(maximumLoad, currentLoad)
	}

	return maximumLoad
}

func main() {
	fmt.Println(findMaximumCPULoad(
		[]Job{{Start: 1, End: 4, Load: 3}, {Start: 2, End: 5, Load: 4}, {Start: 7, End: 9, Load: 6}},
	))
	fmt.Println(findMaximumCPULoad(
		[]Job{{Start: 6, End: 7, Load: 10}, {Start: 2, End: 4, Load: 11}, {Start: 8, End: 12, Load: 15}},
	))
	fmt.Println(findMaximumCPULoad(
		[]Job{{Start: 1, End: 4, Load: 2}, {Start: 2, End: 4, Load: 1}, {Start: 3, End: 6, Load: 5}},
	))
}
```

{% endraw %}

**Вывод:**

```text
7
15
8
```

## Временная сложность

Сортировка занимает $$O(N \log N)$$ времени. Каждая задача один раз добавляется в кучу и один раз удаляется из неё за $$O(\log N)$$. Итоговая временная сложность равна $$O(N \log N)$$.

## Пространственная сложность

Если все задачи пересекаются, в куче одновременно находятся все $$N$$ задач, поэтому требуется $$O(N)$$ дополнительной памяти.

{% include algo-task-nav.html position="bottom" %}
