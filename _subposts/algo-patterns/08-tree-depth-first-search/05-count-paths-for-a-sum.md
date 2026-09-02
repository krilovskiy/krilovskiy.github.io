---
title: Количество путей с заданной суммой
description: Подсчёт нисходящих путей с заданной суммой в любой части бинарного дерева.
pattern: tree-depth-first-search
permalink: /posts/algo-patterns-tree-depth-first-search/count-paths-for-a-sum/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны бинарное дерево и число `sum`. Найдите количество путей, сумма значений узлов каждого из которых равна `sum`. Путь может начинаться и заканчиваться в любом узле, но должен идти сверху вниз — от родителя к потомку.

![Два нисходящих пути с суммой 11](/assets/img/posts/2026-11-01-algo-patterns-tree-depth-first-search/count-paths-for-a-sum.svg){: width="700" }

## Решение

Задача следует паттерну поиска пути с заданной суммой. Используем тот же DFS, но с несколькими отличиями:

1. Храним текущий путь в `currentPath` и передаём его в каждый рекурсивный вызов.
2. При посещении узла добавляем его значение в текущий путь.
3. Просматриваем текущий путь от конца к началу и считаем все подпути, которые заканчиваются в текущем узле и дают сумму `sum`.
4. Продолжаем обход после каждого найденного совпадения.
5. Перед возвратом удаляем текущий узел из пути — выполняем возврат с перебором, или backtracking.

## Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import "fmt"

type TreeNode struct {
	Value int
	Left  *TreeNode
	Right *TreeNode
}

func countPaths(root *TreeNode, sum int) int {
	currentPath := []int{}
	return countPathsRecursive(root, sum, &currentPath)
}

func countPathsRecursive(currentNode *TreeNode, sum int, currentPath *[]int) int {
	if currentNode == nil {
		return 0
	}

	*currentPath = append(*currentPath, currentNode.Value)
	pathCount := 0
	pathSum := 0

	for i := len(*currentPath) - 1; i >= 0; i-- {
		pathSum += (*currentPath)[i]
		if pathSum == sum {
			pathCount++
		}
	}

	pathCount += countPathsRecursive(currentNode.Left, sum, currentPath)
	pathCount += countPathsRecursive(currentNode.Right, sum, currentPath)
	*currentPath = (*currentPath)[:len(*currentPath)-1]
	return pathCount
}

func main() {
	root := &TreeNode{Value: 12}
	root.Left = &TreeNode{Value: 7}
	root.Right = &TreeNode{Value: 1}
	root.Left.Left = &TreeNode{Value: 4}
	root.Right.Left = &TreeNode{Value: 10}
	root.Right.Right = &TreeNode{Value: 5}

	fmt.Printf("Количество путей с суммой 11: %d\n", countPaths(root, 11))
}
```

**Вывод:**

```text
Количество путей с суммой 11: 2
```

## Временная сложность

В худшем случае временная сложность равна $$O(N^2)$$: каждый узел посещается один раз, но для каждого узла просматривается текущий путь длиной до $$O(N)$$. В сбалансированном дереве длина пути равна высоте $$O(\log N)$$, поэтому сложность составит $$O(N \log N)$$.

## Пространственная сложность

Стек рекурсии и `currentPath` требуют $$O(H)$$ памяти, где $$H$$ — высота дерева. В худшем случае это $$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
