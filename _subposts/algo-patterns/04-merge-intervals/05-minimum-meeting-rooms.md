---
title: Минимальное количество переговорных комнат
description: Поиск минимального количества комнат, необходимого для всех встреч.
pattern: merge-intervals
permalink: /posts/algo-patterns-merge-intervals/minimum-meeting-rooms/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан список интервалов с временем начала и окончания $$N$$ встреч. Найдите минимальное количество комнат, необходимое для проведения всех встреч.

### Пример 1

- Входные данные: `[[1,4], [2,5], [7,9]]`.
- Выходные данные: `2`.
- Объяснение: встречи `[1,4]` и `[2,5]` пересекаются, поэтому для них нужны две комнаты. Более позднюю встречу `[7,9]` можно провести в любой из них.

### Пример 2

- Входные данные: `[[6,7], [2,4], [8,12]]`.
- Выходные данные: `1`.
- Объяснение: встречи не пересекаются, поэтому достаточно одной комнаты.

### Пример 3

- Входные данные: `[[1,4], [2,3], [3,6]]`.
- Выходные данные: `2`.
- Объяснение: встреча `[1,4]` пересекается с двумя другими, но встречи `[2,3]` и `[3,6]` можно провести в одной комнате последовательно.

### Пример 4

- Входные данные: `[[4,5], [2,3], [2,4], [3,5]]`.
- Выходные данные: `2`.
- Объяснение: одну комнату займут встречи `[2,3]` и `[3,5]`, а другую — `[2,4]` и `[4,5]`.

## Решение

Обычное объединение интервалов здесь не подходит: объединённый интервал не сохраняет информацию о том, какие встречи можно провести последовательно в одной комнате. Нужно отслеживать времена окончания всех активных встреч.

1. Отсортировать встречи по времени начала.
2. Создать минимальную кучу активных встреч, упорядоченную по времени окончания.
3. Перед добавлением очередной встречи удалить из кучи все встречи, которые закончились не позже её начала: их комнаты уже свободны.
4. Добавить текущую встречу в кучу.
5. Запомнить максимальный размер кучи. Это и есть минимальное количество комнат.

## Код

{% raw %}

```go
package main

import (
	"container/heap"
	"fmt"
	"sort"
)

type Interval struct {
	Start int
	End   int
}

type meetingHeap []Interval

func (h meetingHeap) Len() int           { return len(h) }
func (h meetingHeap) Less(i, j int) bool { return h[i].End < h[j].End }
func (h meetingHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }

func (h *meetingHeap) Push(value any) {
	*h = append(*h, value.(Interval))
}

func (h *meetingHeap) Pop() any {
	old := *h
	last := old[len(old)-1]
	*h = old[:len(old)-1]
	return last
}

func minMeetingRooms(meetings []Interval) int {
	if len(meetings) == 0 {
		return 0
	}

	sort.Slice(meetings, func(i, j int) bool {
		return meetings[i].Start < meetings[j].Start
	})

	active := &meetingHeap{}
	heap.Init(active)
	maximumRooms := 0

	for _, meeting := range meetings {
		for active.Len() > 0 && (*active)[0].End <= meeting.Start {
			heap.Pop(active)
		}

		heap.Push(active, meeting)
		maximumRooms = max(maximumRooms, active.Len())
	}

	return maximumRooms
}

func main() {
	fmt.Println(minMeetingRooms(
		[]Interval{{Start: 1, End: 4}, {Start: 2, End: 5}, {Start: 7, End: 9}},
	))
	fmt.Println(minMeetingRooms(
		[]Interval{{Start: 6, End: 7}, {Start: 2, End: 4}, {Start: 8, End: 12}},
	))
	fmt.Println(minMeetingRooms(
		[]Interval{{Start: 1, End: 4}, {Start: 2, End: 3}, {Start: 3, End: 6}},
	))
	fmt.Println(minMeetingRooms(
		[]Interval{{Start: 4, End: 5}, {Start: 2, End: 3}, {Start: 2, End: 4}, {Start: 3, End: 5}},
	))
}
```

{% endraw %}

**Вывод:**

```text
2
1
2
2
```

## Временная сложность

Сортировка занимает $$O(N \log N)$$ времени. Каждая встреча один раз добавляется в кучу и один раз удаляется из неё, а каждая такая операция занимает $$O(\log N)$$. Итоговая временная сложность равна $$O(N \log N)$$.

## Пространственная сложность

В худшем случае все встречи пересекаются и одновременно находятся в куче, поэтому требуется $$O(N)$$ дополнительной памяти.

{% include algo-task-nav.html position="bottom" %}
