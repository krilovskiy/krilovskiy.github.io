---
title: Пересечение интервалов
description: Поиск общих частей двух отсортированных списков непересекающихся интервалов.
pattern: merge-intervals
permalink: /posts/algo-patterns-merge-intervals/intervals-intersection/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны два списка интервалов. Найдите пересечение этих списков. Каждый список состоит из непересекающихся интервалов, отсортированных по времени начала.

### Пример 1

- Входные данные: `first = [[1,3], [5,6], [7,9]]`, `second = [[2,3], [5,7]]`.
- Выходные данные: `[[2,3], [5,6], [7,7]]`.
- Объяснение: результат содержит все общие части интервалов из двух списков.

### Пример 2

- Входные данные: `first = [[1,3], [5,7], [9,12]]`, `second = [[5,10]]`.
- Выходные данные: `[[5,7], [9,10]]`.
- Объяснение: результат содержит все общие части интервалов из двух списков.

## Решение

Два интервала пересекаются, если начало одного находится внутри другого. Общая часть двух пересекающихся интервалов начинается в более поздней начальной точке и заканчивается в более ранней конечной точке:

```text
start = max(a.start, b.start)
end   = min(a.end, b.end)
```

Будем одновременно просматривать оба списка двумя указателями. Для каждой пары текущих интервалов проверим пересечение и при необходимости добавим общую часть в результат. Затем сдвинем указатель того интервала, который заканчивается раньше: он уже не может пересечься со следующими интервалами другого списка. Если оба заканчиваются одновременно, сдвинем оба указателя.

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

func intersect(first, second []Interval) []Interval {
	result := []Interval{}
	i, j := 0, 0

	for i < len(first) && j < len(second) {
		a := first[i]
		b := second[j]

		if a.Start <= b.End && b.Start <= a.End {
			result = append(result, Interval{
				Start: max(a.Start, b.Start),
				End:   min(a.End, b.End),
			})
		}

		switch {
		case a.End < b.End:
			i++
		case b.End < a.End:
			j++
		default:
			i++
			j++
		}
	}

	return result
}

func main() {
	fmt.Println(intersect(
		[]Interval{{Start: 1, End: 3}, {Start: 5, End: 6}, {Start: 7, End: 9}},
		[]Interval{{Start: 2, End: 3}, {Start: 5, End: 7}},
	))
	fmt.Println(intersect(
		[]Interval{{Start: 1, End: 3}, {Start: 5, End: 7}, {Start: 9, End: 12}},
		[]Interval{{Start: 5, End: 10}},
	))
}
```

{% endraw %}

**Вывод:**

```text
[[2,3] [5,6] [7,7]]
[[5,7] [9,10]]
```

## Временная сложность

Каждый список просматривается один раз, поэтому временная сложность равна $$O(N + M)$$, где $$N$$ и $$M$$ — количества интервалов в списках.

## Пространственная сложность

Если не учитывать память для результата, алгоритм использует $$O(1)$$ дополнительной памяти.

{% include algo-task-nav.html position="bottom" %}
