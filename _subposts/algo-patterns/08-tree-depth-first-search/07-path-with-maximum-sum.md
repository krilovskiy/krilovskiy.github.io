---
title: Путь с максимальной суммой
description: Поиск максимальной суммы значений на пути между любыми узлами бинарного дерева.
pattern: tree-depth-first-search
permalink: /posts/algo-patterns-tree-depth-first-search/path-with-maximum-sum/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Найдите путь с максимальной суммой в данном бинарном дереве и верните эту сумму. Путь — последовательность узлов между любыми двумя узлами; он необязательно проходит через корень.

![Путь с максимальной суммой 31](/assets/img/posts/2026-11-01-algo-patterns-tree-depth-first-search/path-with-maximum-sum.svg){: width="760" }

## Решение

Задача следует паттерну поиска пути с заданной суммой и использует ту же логику, что и диаметр дерева. Выполняем DFS, но игнорируем ветви с отрицательной суммой: они могут только уменьшить сумму пути.

Для каждого узла:

1. Рекурсивно вычисляем максимальные суммы путей, которые можно продолжить через левого и правого потомков.
2. Заменяем каждую отрицательную сумму на ноль.
3. Сумма лучшего пути через текущий узел равна сумме обеих неотрицательных ветвей и значения узла. Ею обновляем общий максимум.
4. Родительскому узлу возвращаем только одну, лучшую из двух ветвей, плюс значение текущего узла: продолжить путь сразу в обе стороны нельзя.

## Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import (
	"fmt"
	"math"
)

type TreeNode struct {
	Value int
	Left  *TreeNode
	Right *TreeNode
}

func findMaximumPathSum(root *TreeNode) int {
	globalMaximumSum := math.MinInt
	findMaximumPathSumRecursive(root, &globalMaximumSum)
	return globalMaximumSum
}

func findMaximumPathSumRecursive(currentNode *TreeNode, globalMaximumSum *int) int {
	if currentNode == nil {
		return 0
	}

	maxPathSumFromLeft := findMaximumPathSumRecursive(currentNode.Left, globalMaximumSum)
	maxPathSumFromRight := findMaximumPathSumRecursive(currentNode.Right, globalMaximumSum)

	if maxPathSumFromLeft < 0 {
		maxPathSumFromLeft = 0
	}
	if maxPathSumFromRight < 0 {
		maxPathSumFromRight = 0
	}

	localMaximumSum := maxPathSumFromLeft + maxPathSumFromRight + currentNode.Value
	if localMaximumSum > *globalMaximumSum {
		*globalMaximumSum = localMaximumSum
	}

	if maxPathSumFromLeft > maxPathSumFromRight {
		return maxPathSumFromLeft + currentNode.Value
	}
	return maxPathSumFromRight + currentNode.Value
}

func main() {
	root := &TreeNode{Value: 1}
	root.Left = &TreeNode{Value: 2}
	root.Right = &TreeNode{Value: 3}
	fmt.Printf("Максимальная сумма пути: %d\n", findMaximumPathSum(root))

	root.Left.Left = &TreeNode{Value: 1}
	root.Left.Right = &TreeNode{Value: 3}
	root.Right.Left = &TreeNode{Value: 5}
	root.Right.Right = &TreeNode{Value: 6}
	root.Right.Left.Left = &TreeNode{Value: 7}
	root.Right.Left.Right = &TreeNode{Value: 8}
	root.Right.Right.Left = &TreeNode{Value: 9}
	fmt.Printf("Максимальная сумма пути: %d\n", findMaximumPathSum(root))

	root = &TreeNode{Value: -1}
	root.Left = &TreeNode{Value: -3}
	fmt.Printf("Максимальная сумма пути: %d\n", findMaximumPathSum(root))
}
```

**Вывод:**

```text
Максимальная сумма пути: 6
Максимальная сумма пути: 31
Максимальная сумма пути: -1
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в дереве. Каждый узел посещается один раз.

## Пространственная сложность

Для стека рекурсивных вызовов требуется $$O(H)$$ памяти, где $$H$$ — высота дерева. В худшем случае дерево вырождается в связанный список, поэтому пространственная сложность становится $$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
