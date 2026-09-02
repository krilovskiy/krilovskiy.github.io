---
title: Минимальная глубина бинарного дерева
description: Поиск кратчайшего пути от корня бинарного дерева до ближайшего листа.
pattern: tree-breadth-first-search
permalink: /posts/algo-patterns-tree-breadth-first-search/minimum-depth/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Найдите минимальную глубину бинарного дерева. Минимальная глубина — количество узлов на кратчайшем пути от корня до ближайшего листа.

![Минимальная глубина бинарного дерева](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/minimum-depth.svg){: width="800" }

## Решение

Задача следует паттерну обхода бинарного дерева по уровням. Вместо сохранения всех уровней отслеживаем только текущую глубину. Первый найденный при BFS лист обязательно принадлежит ближайшему к корню уровню, поэтому его глубина и будет ответом.

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

func findDepth(root *TreeNode) int {
	if root == nil {
		return 0
	}

	queue := []*TreeNode{root}
	minimumTreeDepth := 0

	for len(queue) > 0 {
		minimumTreeDepth++
		levelSize := len(queue)

		for i := 0; i < levelSize; i++ {
			currentNode := queue[0]
			queue = queue[1:]

			if currentNode.Left == nil && currentNode.Right == nil {
				return minimumTreeDepth
			}
			if currentNode.Left != nil {
				queue = append(queue, currentNode.Left)
			}
			if currentNode.Right != nil {
				queue = append(queue, currentNode.Right)
			}
		}
	}

	return minimumTreeDepth
}

func main() {
	root := &TreeNode{Value: 12}
	root.Left = &TreeNode{Value: 7}
	root.Right = &TreeNode{Value: 1}
	root.Right.Left = &TreeNode{Value: 10}
	root.Right.Right = &TreeNode{Value: 5}

	fmt.Printf("Минимальная глубина дерева: %d\n", findDepth(root))

	root.Left.Left = &TreeNode{Value: 9}
	root.Right.Left.Left = &TreeNode{Value: 11}
	fmt.Printf("Минимальная глубина дерева: %d\n", findDepth(root))
}
```

**Вывод:**

```text
Минимальная глубина дерева: 2
Минимальная глубина дерева: 3
```

## Временная сложность

В худшем случае алгоритм посещает все узлы, поэтому его временная сложность равна $$O(N)$$.

## Пространственная сложность

Для очереди требуется $$O(W)$$ памяти, где $$W$$ — максимальная ширина дерева. В худшем случае это $$O(N)$$.

## Вариации задачи

**Задача:** найдите максимальную глубину, или высоту, бинарного дерева.

**Решение:** продолжайте обход до последнего уровня и увеличивайте `maximumTreeDepth` после каждого полностью обработанного уровня.

```go
package main

import "fmt"

type TreeNode struct {
	Value int
	Left  *TreeNode
	Right *TreeNode
}

func findDepth(root *TreeNode) int {
	if root == nil {
		return 0
	}

	queue := []*TreeNode{root}
	maximumTreeDepth := 0

	for len(queue) > 0 {
		maximumTreeDepth++
		levelSize := len(queue)

		for i := 0; i < levelSize; i++ {
			currentNode := queue[0]
			queue = queue[1:]

			if currentNode.Left != nil {
				queue = append(queue, currentNode.Left)
			}
			if currentNode.Right != nil {
				queue = append(queue, currentNode.Right)
			}
		}
	}

	return maximumTreeDepth
}

func main() {
	root := &TreeNode{Value: 12}
	root.Left = &TreeNode{Value: 7}
	root.Right = &TreeNode{Value: 1}
	root.Right.Left = &TreeNode{Value: 10}
	root.Right.Right = &TreeNode{Value: 5}

	fmt.Printf("Максимальная глубина дерева: %d\n", findDepth(root))

	root.Left.Left = &TreeNode{Value: 9}
	root.Right.Left.Left = &TreeNode{Value: 11}
	fmt.Printf("Максимальная глубина дерева: %d\n", findDepth(root))
}
```

**Вывод:**

```text
Максимальная глубина дерева: 3
Максимальная глубина дерева: 4
```

{% include algo-task-nav.html position="bottom" %}
