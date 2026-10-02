---
title: Деревья минимальной высоты
description: Деревья минимальной высоты — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: topological-sort
permalink: /posts/algo-patterns-topological-sort/minimum-height-trees/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан неориентированный граф, являющийся деревом: он связен и не содержит циклов. Любую вершину можно назначить корнем. Верните все корни, при которых высота дерева минимальна.

```text
V = 5, рёбра = [[0,1], [1,2], [1,3], [2,4]] → [1,2]
V = 4, рёбра = [[0,1], [0,2], [2,3]] → [0,2]
V = 4, рёбра = [[0,1], [1,2], [1,3]] → [1]
```

В первых двух примерах минимальная высота — три уровня, как считается в исходнике.

## Решение

Если в дереве больше двух вершин, лист не является лучшим корнем: перемещение корня к его внутреннему соседу уменьшает наибольшее расстояние. Поэтому удаляем листья слоями, пока не останутся одна или две центральные вершины. Они и дают минимальную высоту.

Идея похожа на удаление источников при топологическом обходе, но здесь граф **неориентированный**, а источниками служат вершины степени `1`. Для каждого удалённого листа уменьшаем степени соседей; новые листья обрабатываем только в следующем слое. Один узел и два узла — граничные случаи. Алгоритм рассчитан именно на дерево.

![Высота дерева при выборе разных корней, шаг 1](/assets/img/posts/2027-07-01-algo-patterns-topological-sort/minimum-height-01.svg)

![Высота дерева при выборе разных корней, шаг 2](/assets/img/posts/2027-07-01-algo-patterns-topological-sort/minimum-height-02.svg)

## Код

{% raw %}
```go
package main

import (
	"fmt"
)

func findTrees(nodes int, edges [][2]int) []int {
	if nodes <= 0 {
		return nil
	}
	if nodes == 1 {
		return []int{0}
	}
	graph := make([][]int, nodes)
	inDegree := make([]int, nodes)
	for _, edge := range edges {
		a, b := edge[0], edge[1]
		graph[a] = append(graph[a], b)
		graph[b] = append(graph[b], a)
		inDegree[a]++
		inDegree[b]++
	}
	leaves := []int{}
	for n, d := range inDegree {
		if d == 1 {
			leaves = append(leaves, n)
		}
	}
	totalNodes := nodes
	for totalNodes > 2 {
		leavesSize := len(leaves)
		totalNodes -= leavesSize
		nextLeaves := []int{}
		for _, vertex := range leaves {
			for _, child := range graph[vertex] {
				inDegree[child]--
				if inDegree[child] == 1 {
					nextLeaves = append(nextLeaves, child)
				}
			}
		}
		leaves = nextLeaves
	}
	return leaves
}

func main() {
	fmt.Println(findTrees(5, [][2]int{{0, 1}, {1, 2}, {1, 3}, {2, 4}}))
	fmt.Println(findTrees(4, [][2]int{{0, 1}, {0, 2}, {2, 3}}))
	fmt.Println(findTrees(4, [][2]int{{0, 1}, {1, 2}, {1, 3}}))
}
```
{% endraw %}

**Вывод:**

```text
[1 2]
[0 2]
[1]
```

## Временная сложность

$$O(V+E)$$: каждая вершина удаляется не более одного раза, каждое ребро просматривается с обоих концов. Для дерева `E = V-1`, поэтому это $$O(V)$$.

## Пространственная сложность

$$O(V+E)$$ для списков смежности, степеней и очереди листьев.

{% include algo-task-nav.html position="bottom" %}
