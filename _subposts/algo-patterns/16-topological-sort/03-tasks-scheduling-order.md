---
title: Порядок выполнения задач
description: Порядок выполнения задач — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: topological-sort
permalink: /posts/algo-patterns-topological-sort/tasks-scheduling-order/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Для `N` задач и пар `[предшественник, зависимая задача]` верните допустимый порядок выполнения всех задач. При циклических зависимостях верните пустой список.

```text
N = 3, зависимости = [[0,1], [1,2]]
N = 3, зависимости = [[0,1], [1,2], [2,0]]
N = 6, зависимости = [[2,5], [0,5], [0,4], [1,4], [3,2], [1,3]]
```

Возможные ответы соответственно: `[0,1,2]`, `[]`, `[0,1,4,3,2,5]`.

## Решение

Используем тот же обход источников, но возвращаем сам `sortedOrder`. В очередь изначально входят задачи без предшественников. После выполнения задачи уменьшаем входящие степени зависимых задач. Если появились новые нулевые степени, соответствующие задачи готовы к выполнению. При нескольких источниках допустим любой порядок их выбора.

## Код

{% raw %}
```go
package main

import (
	"fmt"
)

func findOrder(vertices int, edges [][2]int) []int {
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

func main() {
	fmt.Println(findOrder(3, [][2]int{{0, 1}, {1, 2}}))
	fmt.Println(findOrder(3, [][2]int{{0, 1}, {1, 2}, {2, 0}}))
	fmt.Println(findOrder(6, [][2]int{{2, 5}, {0, 5}, {0, 4}, {1, 4}, {3, 2}, {1, 3}}))
}
```
{% endraw %}

**Вывод:**

```text
[0 1 2]
[]
[0 1 4 3 2 5]
```

## Временная сложность

$$O(V+E)$$.

## Пространственная сложность

$$O(V+E)$$.

## Вариации задачи

**Порядок прохождения курсов.** Нужно вывести последовательность курсов с учётом требований пройти другие курсы раньше. Это тот же поиск топологического порядка.

{% include algo-task-nav.html position="bottom" %}
