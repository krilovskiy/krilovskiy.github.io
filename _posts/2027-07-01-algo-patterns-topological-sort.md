---
title: Алгосы от Влада, часть 16. Топологическая сортировка
date: 2027-07-01 00:00:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
math: true
pattern: topological-sort
short_title: Топологическая сортировка
primary_task_title: Топологическая сортировка графа
primary_task_anchor: topological-sort
---

* [Введение](/posts/algo-patterns/)
* [Скользящее окно](/posts/algo-patterns-sliding-window/)
* [Два указателя или итератор](/posts/algo-patterns-two-pointers/)
* [Быстрый и медленный указатель](/posts/algo-patterns-fast-slow-pointer/)
* [Мерж интервалов](/posts/algo-patterns-merge-intervals/)
* [Циклическая сортировка](/posts/algo-patterns-cyclic-sort/)
* [Инвертирование связанного списка на месте](/posts/algo-patterns-in-place-reversal-linked-list/)
* [Дерево BFS](/posts/algo-patterns-tree-breadth-first-search/)
* [Дерево DFS](/posts/algo-patterns-tree-depth-first-search/)
* [Две кучи](/posts/algo-patterns-two-heaps/)
* [Подмножества](/posts/algo-patterns-subsets/)
* [Модифицированный бинарный поиск](/posts/algo-patterns-modified-binary-search/)
* [Побитовый XOR](/posts/algo-patterns-bitwise-xor/)
* [Лучшие K элементов](/posts/algo-patterns-top-k-elements/)
* [K-way merge](/posts/algo-patterns-k-way-merge/)
* [Рюкзак 0/1](/posts/algo-patterns-0-1-knapsack/)
* <b>Топологическая сортировка</b>

## Введение

Топологическая сортировка находит линейный порядок элементов с зависимостями. Если событие `B` зависит от `A`, то `A` должно стоять раньше `B`. Разберём обход графа через вершины без входящих рёбер, затем применим его к расписаниям, словарю и восстановлению последовательности.

## Топологическая сортировка графа {#topological-sort}

### Условие задачи

Для ориентированного графа найдите линейный порядок вершин, в котором для каждого ребра `U → V` вершина `U` находится раньше `V`. Порядков может быть несколько.

```text
V = 4, рёбра = [[3,2], [3,0], [2,0], [2,1]]
Порядки: [3,2,0,1] или [3,2,1,0]

V = 5, рёбра = [[4,2], [4,3], [2,0], [2,1], [3,1]]
Порядки: [4,2,3,0,1], [4,3,2,0,1], [4,3,2,1,0],
         [4,2,3,1,0], [4,2,0,3,1]

V = 7, рёбра = [[6,4], [6,2], [5,3], [5,4], [3,0], [3,1], [3,2], [4,1]]
Примеры порядков: [5,6,3,4,0,1,2], [6,5,3,4,0,1,2],
[5,6,4,3,0,2,1], [6,5,4,3,0,1,2], [5,6,3,4,0,2,1], [5,6,3,4,1,2,0]
```


### Решение

**Источник** — вершина без входящих рёбер. **Сток** — вершина без исходящих рёбер. Изолированная вершина удовлетворяет обоим определениям. Топологический порядок существует только для ориентированного ациклического графа — DAG: цикл создаёт неразрешимую цепочку зависимостей.

Обходим граф в духе BFS, последовательно удаляя источники:

1. Строим списки смежности `graph` и считаем входящую степень `inDegree` каждой вершины.
2. Все вершины с нулевой входящей степенью помещаем в очередь `sources`.
3. Берём источник, добавляем его в `sortedOrder`, уменьшаем входящие степени его детей. Новые источники добавляем в очередь.
4. Если после опустошения очереди в результате меньше `V` вершин, в графе есть цикл: возвращаем пустой результат.

Для третьего примера сначала доступны `5` и `6`, затем `3` и `4`, после них — `0`, `1`, `2`. В коде вершины пронумерованы от `0` до `V-1`, поэтому таблицы удобно представить срезами.

![Граф зависимостей и последовательное удаление источников, шаг 1](/assets/img/posts/2027-07-01-algo-patterns-topological-sort/topological-01.svg)

![Граф зависимостей и последовательное удаление источников, шаг 2](/assets/img/posts/2027-07-01-algo-patterns-topological-sort/topological-02.svg)

![Граф зависимостей и последовательное удаление источников, шаг 3](/assets/img/posts/2027-07-01-algo-patterns-topological-sort/topological-03.svg)

![Граф зависимостей и последовательное удаление источников, шаг 4](/assets/img/posts/2027-07-01-algo-patterns-topological-sort/topological-04.svg)

### Код

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

func main() {
	fmt.Println(topologicalSort(4, [][2]int{{3, 2}, {3, 0}, {2, 0}, {2, 1}}))
	fmt.Println(topologicalSort(5, [][2]int{{4, 2}, {4, 3}, {2, 0}, {2, 1}, {3, 1}}))
	fmt.Println(topologicalSort(7, [][2]int{{6, 4}, {6, 2}, {5, 3}, {5, 4}, {3, 0}, {3, 1}, {3, 2}, {4, 1}}))
}
```
{% endraw %}

**Вывод:**

```text
[3 2 0 1]
[4 2 3 0 1]
[5 6 3 4 0 2 1]
```

### Временная сложность

$$O(V+E)$$: каждая вершина попадает в очередь один раз, каждое ребро обрабатывается один раз.

### Пространственная сложность

$$O(V+E)$$ для графа, входящих степеней и очереди.

### Вариации задачи

**Проверка ориентированного графа на цикл.** Если число извлечённых источников не равно числу вершин, топологический порядок не существует и в графе есть цикл.

## Задачи главы

1. [Топологическая сортировка графа](#topological-sort)
2. [Возможность выполнения всех задач](/posts/algo-patterns-topological-sort/tasks-scheduling/)
3. [Порядок выполнения задач](/posts/algo-patterns-topological-sort/tasks-scheduling-order/)
4. [Все порядки выполнения задач](/posts/algo-patterns-topological-sort/all-tasks-scheduling-orders/)
5. [Инопланетный словарь](/posts/algo-patterns-topological-sort/alien-dictionary/)
6. [Однозначное восстановление последовательности](/posts/algo-patterns-topological-sort/reconstructing-a-sequence/)
7. [Деревья минимальной высоты](/posts/algo-patterns-topological-sort/minimum-height-trees/)

## Похожие задания

1. Course Schedule [Leetcode](https://leetcode.com/problems/course-schedule/)
2. Course Schedule II [Leetcode](https://leetcode.com/problems/course-schedule-ii/)
3. Minimum Height Trees [Leetcode](https://leetcode.com/problems/minimum-height-trees/)
