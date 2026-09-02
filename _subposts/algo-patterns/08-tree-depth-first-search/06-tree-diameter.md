---
title: Диаметр бинарного дерева
description: Поиск количества узлов на самом длинном пути между двумя листьями бинарного дерева.
pattern: tree-depth-first-search
permalink: /posts/algo-patterns-tree-depth-first-search/tree-diameter/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дано бинарное дерево. Найдите длину его диаметра — количество узлов на самом длинном пути между любыми двумя листьями. Диаметр может проходить через корень, но это необязательно.

Можно считать, что в дереве есть как минимум два листа.

![Диаметр бинарного дерева проходит через семь узлов](/assets/img/posts/2026-11-01-algo-patterns-tree-depth-first-search/tree-diameter.svg){: width="760" }

## Решение

Задача следует паттерну поиска пути с заданной суммой. Используем тот же DFS со следующими изменениями:

1. Для каждого узла рекурсивно вычисляем высоты его левого и правого поддеревьев.
2. Высота текущего узла равна большей из двух высот плюс один для самого узла.
3. Диаметр, проходящий через текущий узел, равен `leftTreeHeight + rightTreeHeight + 1`.
4. Сохраняем максимальный диаметр среди всех посещённых узлов.

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

func findDiameter(root *TreeNode) int {
	treeDiameter := 0
	calculateHeight(root, &treeDiameter)
	return treeDiameter
}

func calculateHeight(currentNode *TreeNode, treeDiameter *int) int {
	if currentNode == nil {
		return 0
	}

	leftTreeHeight := calculateHeight(currentNode.Left, treeDiameter)
	rightTreeHeight := calculateHeight(currentNode.Right, treeDiameter)

	diameter := leftTreeHeight + rightTreeHeight + 1
	if diameter > *treeDiameter {
		*treeDiameter = diameter
	}

	if leftTreeHeight > rightTreeHeight {
		return leftTreeHeight + 1
	}
	return rightTreeHeight + 1
}

func main() {
	root := &TreeNode{Value: 1}
	root.Left = &TreeNode{Value: 2}
	root.Right = &TreeNode{Value: 3}
	root.Left.Left = &TreeNode{Value: 4}
	root.Right.Left = &TreeNode{Value: 5}
	root.Right.Right = &TreeNode{Value: 6}
	fmt.Printf("Диаметр дерева: %d\n", findDiameter(root))

	root.Left.Left = nil
	root.Right.Left.Left = &TreeNode{Value: 7}
	root.Right.Left.Right = &TreeNode{Value: 8}
	root.Right.Right.Left = &TreeNode{Value: 9}
	root.Right.Left.Right.Left = &TreeNode{Value: 10}
	root.Right.Right.Left.Left = &TreeNode{Value: 11}
	fmt.Printf("Диаметр дерева: %d\n", findDiameter(root))
}
```

**Вывод:**

```text
Диаметр дерева: 5
Диаметр дерева: 7
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в дереве. Каждый узел посещается один раз.

## Пространственная сложность

Для стека рекурсивных вызовов требуется $$O(H)$$ памяти, где $$H$$ — высота дерева. В худшем случае дерево вырождается в связанный список, поэтому пространственная сложность становится $$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
