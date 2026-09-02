---
title: Все пути с заданной суммой
description: Поиск всех путей от корня до листа с заданной суммой значений узлов.
pattern: tree-depth-first-search
permalink: /posts/algo-patterns-tree-depth-first-search/all-paths-for-a-sum/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны бинарное дерево и число `sum`. Найдите все пути от корня до листа, сумма значений узлов каждого из которых равна `sum`.

![Два пути от корня до листьев с суммой 23](/assets/img/posts/2026-11-01-algo-patterns-tree-depth-first-search/all-paths-for-a-sum.svg){: width="700" }

## Решение

Задача следует паттерну поиска пути с заданной суммой. Используем тот же DFS, но с двумя отличиями:

1. Каждый найденный путь от корня до листа сохраняем в результате.
2. После первого совпадения не останавливаемся, а продолжаем обход всех путей.

Во время рекурсивного спуска добавляем текущий узел в `currentPath`. Перед возвратом из функции удаляем его, чтобы восстановить путь для другой ветви дерева.

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

func findPaths(root *TreeNode, sum int) [][]int {
	allPaths := [][]int{}
	currentPath := []int{}
	findPathsRecursive(root, sum, &currentPath, &allPaths)
	return allPaths
}

func findPathsRecursive(currentNode *TreeNode, sum int, currentPath *[]int, allPaths *[][]int) {
	if currentNode == nil {
		return
	}

	*currentPath = append(*currentPath, currentNode.Value)

	if currentNode.Value == sum && currentNode.Left == nil && currentNode.Right == nil {
		path := append([]int(nil), (*currentPath)...)
		*allPaths = append(*allPaths, path)
	} else {
		remainingSum := sum - currentNode.Value
		findPathsRecursive(currentNode.Left, remainingSum, currentPath, allPaths)
		findPathsRecursive(currentNode.Right, remainingSum, currentPath, allPaths)
	}

	*currentPath = (*currentPath)[:len(*currentPath)-1]
}

func main() {
	root := &TreeNode{Value: 12}
	root.Left = &TreeNode{Value: 7}
	root.Right = &TreeNode{Value: 1}
	root.Left.Left = &TreeNode{Value: 4}
	root.Right.Left = &TreeNode{Value: 10}
	root.Right.Right = &TreeNode{Value: 5}

	fmt.Printf("Пути с суммой 23: %v\n", findPaths(root, 23))
}
```

**Вывод:**

```text
Пути с суммой 23: [[12 7 4] [12 1 10]]
```

## Временная сложность

Обход всех узлов занимает $$O(N)$$ времени. Кроме того, для каждого листа может потребоваться копирование пути длиной до $$O(N)$$, поэтому грубая верхняя оценка равна $$O(N^2)$$. Для сбалансированного дерева глубина пути равна $$O(\log N)$$, а более точная оценка — $$O(N \log N)$$.

## Пространственная сложность

Если не учитывать результат `allPaths`, стек рекурсии и текущий путь требуют $$O(H)$$ памяти, где $$H$$ — высота дерева, то есть до $$O(N)$$ в вырожденном дереве.

Если учитывать результат, его размер равен суммарной длине всех сохранённых путей. В сбалансированном бинарном дереве может быть до $$N/2$$ листьев, а длина каждого пути не превышает $$O(\log N)$$, поэтому требуется $$O(N \log N)$$ памяти. Однако в несбалансированном дереве листья могут находиться на последовательно увеличивающейся глубине, и суммарная длина путей достигает $$O(N^2)$$. Таким образом, общая пространственная сложность в худшем случае равна $$O(N^2)$$.

## Вариации задачи

**Задача 1:** верните все пути бинарного дерева от корня до листьев.

**Решение:** используйте тот же обход, но уберите проверку суммы пути.

**Задача 2:** найдите путь от корня до листа с максимальной суммой.

**Решение:** обойдите все пути и сохраняйте путь с наибольшей найденной суммой.

{% include algo-task-nav.html position="bottom" %}
