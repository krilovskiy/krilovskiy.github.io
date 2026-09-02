---
title: Конфликтующие встречи
description: Проверка возможности посетить все встречи без пересечений по времени.
pattern: merge-intervals
permalink: /posts/algo-patterns-merge-intervals/conflicting-appointments/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан массив из $$N$$ интервалов, представляющих время встреч. Определите, может ли человек посетить все встречи.

### Пример 1

- Входные данные: `[[1,4], [2,5], [7,9]]`.
- Выходные данные: `false`.
- Объяснение: встречи `[1,4]` и `[2,5]` пересекаются, поэтому посетить обе невозможно.

### Пример 2

- Входные данные: `[[6,7], [2,4], [8,12]]`.
- Выходные данные: `true`.
- Объяснение: встречи не пересекаются.

### Пример 3

- Входные данные: `[[4,5], [2,3], [3,6]]`.
- Выходные данные: `false`.
- Объяснение: встречи `[4,5]` и `[3,6]` пересекаются.

## Решение

Отсортируем встречи по времени начала. После сортировки достаточно сравнивать каждую встречу с предыдущей. Если текущая встреча начинается раньше, чем закончилась предыдущая, они пересекаются и посетить все встречи нельзя.

Встречи, одна из которых начинается точно в момент окончания другой, не конфликтуют.

## Код

{% raw %}

```go
package main

import (
	"fmt"
	"sort"
)

type Interval struct {
	Start int
	End   int
}

func canAttendAllAppointments(appointments []Interval) bool {
	sort.Slice(appointments, func(i, j int) bool {
		return appointments[i].Start < appointments[j].Start
	})

	for i := 1; i < len(appointments); i++ {
		if appointments[i].Start < appointments[i-1].End {
			return false
		}
	}
	return true
}

func main() {
	fmt.Println(canAttendAllAppointments(
		[]Interval{{Start: 1, End: 4}, {Start: 2, End: 5}, {Start: 7, End: 9}},
	))
	fmt.Println(canAttendAllAppointments(
		[]Interval{{Start: 6, End: 7}, {Start: 2, End: 4}, {Start: 8, End: 12}},
	))
	fmt.Println(canAttendAllAppointments(
		[]Interval{{Start: 4, End: 5}, {Start: 2, End: 3}, {Start: 3, End: 6}},
	))
}
```

{% endraw %}

**Вывод:**

```text
false
true
false
```

## Временная сложность

Сортировка занимает $$O(N \log N)$$ времени, а последующий проход — $$O(N)$$. Итоговая временная сложность равна $$O(N \log N)$$.

## Пространственная сложность

Сортировка выполняется на месте. Стек вызовов алгоритма сортировки требует $$O(\log N)$$ дополнительной памяти.

{% include algo-task-nav.html position="bottom" %}
