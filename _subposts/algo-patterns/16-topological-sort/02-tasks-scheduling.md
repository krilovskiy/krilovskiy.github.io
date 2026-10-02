---
title: Возможность выполнения всех задач
description: Возможность выполнения всех задач — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: topological-sort
permalink: /posts/algo-patterns-topological-sort/tasks-scheduling/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны `N` задач с номерами от `0` до `N-1` и пары зависимостей. Пара `[a,b]` означает, что `a` должна завершиться перед `b`. Можно ли выполнить все задачи?

```text
N = 3, зависимости = [[0,1], [1,2]]
N = 3, зависимости = [[0,1], [1,2], [2,0]]
N = 6, зависимости = [[2,5], [0,5], [0,4], [1,4], [3,2], [1,3]]
```

Ответы: `true`, `false`, `true`. В первом случае подходит `[0,1,2]`, во втором есть цикл, в третьем подходит `[0,1,4,3,2,5]`.

## Решение

Задачи — вершины, зависимости — рёбра. Строим топологический порядок: сначала выполняем задачи без зависимостей, после каждой освобождаем её детей. Если удалось обработать все `N` задач, расписание существует; иначе часть зависимостей образует цикл.

## Код

{% raw %}
```go
package main

import (
	"fmt"
)

func topologicalSort(vertices int, edges [][2]int) []int {
	graph := make([][]int, vertices)
	inDegree := make([]int, vertices)
	for _, edge := range edges {
		parent, child := edge[0], edge[1]
		graph[parent] = append(graph[parent], child)
		inDegree[child]++
	}
	sources := []int{}
	for vertex, d := range inDegree {
		if d == 0 {
			sources = append(sources, vertex)
		}
	}
	sortedOrder := []int{}
	for head := 0; head < len(sources); head++ {
		vertex := sources[head]
		sortedOrder = append(sortedOrder, vertex)
		for _, child := range graph[vertex] {
			inDegree[child]--
			if inDegree[child] == 0 {
				sources = append(sources, child)
			}
		}
	}
	if len(sortedOrder) != vertices {
		return nil
	}
	return sortedOrder
}
func isSchedulingPossible(tasks int, prerequisites [][2]int) bool {
	return len(topologicalSort(tasks, prerequisites)) == tasks
}

func main() {
	fmt.Println(isSchedulingPossible(3, [][2]int{{0, 1}, {1, 2}}))
	fmt.Println(isSchedulingPossible(3, [][2]int{{0, 1}, {1, 2}, {2, 0}}))
	fmt.Println(isSchedulingPossible(6, [][2]int{{2, 5}, {0, 5}, {0, 4}, {1, 4}, {3, 2}, {1, 3}}))
}
```
{% endraw %}

**Вывод:**

```text
true
false
true
```

## Временная сложность

$$O(V+E)$$, где `V` — число задач, `E` — число зависимостей.

## Пространственная сложность

$$O(V+E)$$.

## Вариации задачи

**Course Schedule.** Вместо задач даны учебные курсы и обязательные предшествующие курсы. Проверка возможности пройти их все выполняется тем же алгоритмом; направление каждой пары нужно читать по условию конкретной площадки.

{% include algo-task-nav.html position="bottom" %}
