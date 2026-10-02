---
title: Все порядки выполнения задач
description: Все порядки выполнения задач — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: topological-sort
permalink: /posts/algo-patterns-topological-sort/all-tasks-scheduling-orders/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Выведите **все** допустимые порядки выполнения `N` задач с заданными зависимостями.

```text
N = 3, зависимости = [[0,1], [1,2]]
→ [0,1,2]

N = 4, зависимости = [[3,2], [3,0], [2,0], [2,1]]
→ [3,2,0,1], [3,2,1,0]

N = 6, зависимости = [[2,5], [0,5], [0,4], [1,4], [3,2], [1,3]]
→ 13 порядков, перечисленных в выводе программы ниже
```

## Решение

При нескольких источниках каждый из них может быть следующим. Перебираем этот выбор рекурсивно с возвратом.

Для выбранного источника копируем очередь остальных источников, добавляем вершину к текущему порядку и временно уменьшаем входящие степени её детей. После рекурсивного вызова восстанавливаем степени. Текущий порядок передаётся как срез с собственной длиной; после возврата родитель продолжает со своим префиксом. Выводим только последовательности длины `N`, поэтому циклические ветви ничего не печатают.

## Код

{% raw %}
```go
package main

import (
	"fmt"
)

func printOrders(tasks int, prerequisites [][2]int) {
	if tasks <= 0 {
		return
	}
	graph := make([][]int, tasks)
	inDegree := make([]int, tasks)
	for _, edge := range prerequisites {
		graph[edge[0]] = append(graph[edge[0]], edge[1])
		inDegree[edge[1]]++
	}
	sources := []int{}
	for v, d := range inDegree {
		if d == 0 {
			sources = append(sources, v)
		}
	}
	printAllTopologicalSorts(graph, inDegree, sources, nil)
}
func printAllTopologicalSorts(graph [][]int, inDegree, sources, sortedOrder []int) {
	if len(sortedOrder) == len(inDegree) {
		fmt.Println(sortedOrder)
		return
	}
	for i, vertex := range sources {
		nextOrder := append(sortedOrder, vertex)
		sourcesForNextCall := append([]int(nil), sources[:i]...)
		sourcesForNextCall = append(sourcesForNextCall, sources[i+1:]...)
		for _, child := range graph[vertex] {
			inDegree[child]--
			if inDegree[child] == 0 {
				sourcesForNextCall = append(sourcesForNextCall, child)
			}
		}
		printAllTopologicalSorts(graph, inDegree, sourcesForNextCall, nextOrder)
		for _, child := range graph[vertex] {
			inDegree[child]++
		}
	}
}

func main() {
	printOrders(3, [][2]int{{0, 1}, {1, 2}})
	fmt.Println()
	printOrders(4, [][2]int{{3, 2}, {3, 0}, {2, 0}, {2, 1}})
	fmt.Println()
	printOrders(6, [][2]int{{2, 5}, {0, 5}, {0, 4}, {1, 4}, {3, 2}, {1, 3}})
}
```
{% endraw %}

**Вывод:**

```text
[0 1 2]

[3 2 0 1]
[3 2 1 0]

[0 1 4 3 2 5]
[0 1 3 4 2 5]
[0 1 3 2 4 5]
[0 1 3 2 5 4]
[1 0 3 4 2 5]
[1 0 3 2 4 5]
[1 0 3 2 5 4]
[1 0 4 3 2 5]
[1 3 0 2 4 5]
[1 3 0 2 5 4]
[1 3 0 4 2 5]
[1 3 2 0 5 4]
[1 3 2 0 4 5]
```

## Временная сложность

Без зависимостей существует $$V!$$ порядков. В исходнике приведено $$O(V!E)$$, но при `E = 0` работа не исчезает: нужно учесть копирование очередей и вывод `V` чисел. Безопасная общая верхняя оценка — $$O(V!(V+E))$$.

## Пространственная сложность

Исходник также указывает $$O(V!E)$$ для пространства. При последовательной печати все ответы не хранятся: граф требует $$O(V+E)$$, стек и копии очередей на активном пути — до $$O(V^2)$$. Итого $$O(V^2+E)$$ для показанного кода.

{% include algo-task-nav.html position="bottom" %}
