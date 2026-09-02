---
title: Вставка интервала
description: Вставка интервала в отсортированный список непересекающихся интервалов с объединением пересечений.
pattern: merge-intervals
permalink: /posts/algo-patterns-merge-intervals/insert-interval/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан отсортированный по времени начала список непересекающихся интервалов. Вставьте новый интервал в правильную позицию и объедините все необходимые интервалы так, чтобы результат также состоял только из непересекающихся интервалов.

### Пример 1

- Входные данные: интервалы `[[1,3], [5,7], [8,12]]`, новый интервал `[4,6]`.
- Выходные данные: `[[1,3], [4,7], [8,12]]`.
- Объяснение: новый интервал `[4,6]` пересекается с `[5,7]`, поэтому они объединяются в `[4,7]`.

### Пример 2

- Входные данные: интервалы `[[1,3], [5,7], [8,12]]`, новый интервал `[4,10]`.
- Выходные данные: `[[1,3], [4,12]]`.
- Объяснение: новый интервал пересекается с `[5,7]` и `[8,12]`, поэтому все три интервала объединяются в `[4,12]`.

### Пример 3

- Входные данные: интервалы `[[2,3], [5,7]]`, новый интервал `[1,4]`.
- Выходные данные: `[[1,4], [5,7]]`.
- Объяснение: новый интервал `[1,4]` пересекается с `[2,3]`, поэтому они объединяются в `[1,4]`.

## Решение

Если бы список не был отсортирован, можно было бы добавить новый интервал и применить алгоритм объединения интервалов за $$O(N \log N)$$. Но исходный список уже отсортирован, поэтому достаточно одного прохода:

1. Добавить в результат все интервалы, которые заканчиваются раньше начала нового интервала.
2. Пока очередной интервал начинается не позже конца нового, объединять их: началом станет меньшее из двух начал, а концом — большее из двух окончаний.
3. Добавить получившийся новый интервал в результат.
4. Добавить все оставшиеся интервалы.

## Код

{% raw %}

```go
package main

import "fmt"

type Interval struct {
	Start int
	End   int
}

func (interval Interval) String() string {
	return fmt.Sprintf("[%d,%d]", interval.Start, interval.End)
}

func insert(intervals []Interval, newInterval Interval) []Interval {
	result := make([]Interval, 0, len(intervals)+1)
	i := 0

	for i < len(intervals) && intervals[i].End < newInterval.Start {
		result = append(result, intervals[i])
		i++
	}

	for i < len(intervals) && intervals[i].Start <= newInterval.End {
		newInterval.Start = min(newInterval.Start, intervals[i].Start)
		newInterval.End = max(newInterval.End, intervals[i].End)
		i++
	}

	result = append(result, newInterval)
	result = append(result, intervals[i:]...)
	return result
}

func main() {
	fmt.Println(insert(
		[]Interval{{Start: 1, End: 3}, {Start: 5, End: 7}, {Start: 8, End: 12}},
		Interval{Start: 4, End: 6},
	))
	fmt.Println(insert(
		[]Interval{{Start: 1, End: 3}, {Start: 5, End: 7}, {Start: 8, End: 12}},
		Interval{Start: 4, End: 10},
	))
	fmt.Println(insert(
		[]Interval{{Start: 2, End: 3}, {Start: 5, End: 7}},
		Interval{Start: 1, End: 4},
	))
}
```

{% endraw %}

**Вывод:**

```text
[[1,3] [4,7] [8,12]]
[[1,3] [4,12]]
[[1,4] [5,7]]
```

## Временная сложность

Алгоритм просматривает каждый из $$N$$ исходных интервалов не более одного раза, поэтому его временная сложность равна $$O(N)$$.

## Пространственная сложность

Для результата требуется $$O(N)$$ памяти.

{% include algo-task-nav.html position="bottom" %}
