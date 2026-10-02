---
title: Следующий узел при обходе по уровням
description: Поиск узла, следующего за заданным значением при BFS-обходе бинарного дерева.
pattern: tree-breadth-first-search
permalink: /posts/algo-patterns-tree-breadth-first-search/level-order-successor/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны бинарное дерево и значение узла. Найдите следующий узел при обходе дерева по уровням — узел, который появляется сразу после заданного в последовательности BFS.

![Следующий узел при обходе бинарного дерева по уровням](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/level-order-successor.svg){: width="600" }

## Решение

Задача следует паттерну обхода бинарного дерева по уровням. Нам не нужно сохранять уровни: достаточно извлекать узлы из очереди и сразу добавлять их потомков. Когда найден узел с заданным значением, следующий элемент в очереди и будет его преемником при BFS-обходе.

Если заданный узел идёт последним или не найден, функция вернёт `nil`.

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

func findSuccessor(root *TreeNode, key int) *TreeNode {
	if root == nil {
		return nil
	}

	queue := []*TreeNode{root}
	for len(queue) > 0 {
		currentNode := queue[0]
		queue = queue[1:]

		if currentNode.Left != nil {
			queue = append(queue, currentNode.Left)
		}
		if currentNode.Right != nil {
			queue = append(queue, currentNode.Right)
		}

		if currentNode.Value == key {
			break
		}
	}

	if len(queue) == 0 {
		return nil
	}
	return queue[0]
}

func printSuccessor(root *TreeNode, key int) {
	successor := findSuccessor(root, key)
	if successor == nil {
		fmt.Printf("После %d нет следующего узла\n", key)
		return
	}
	fmt.Printf("Следующий узел после %d: %d\n", key, successor.Value)
}

func main() {
	root := &TreeNode{Value: 12}
	root.Left = &TreeNode{Value: 7}
	root.Right = &TreeNode{Value: 1}
	root.Left.Left = &TreeNode{Value: 9}
	root.Right.Left = &TreeNode{Value: 10}
	root.Right.Right = &TreeNode{Value: 5}

	printSuccessor(root, 12)
	printSuccessor(root, 9)
}
```

**Вывод:**

```text
Следующий узел после 12: 7
Следующий узел после 9: 10
```

## Временная сложность

В худшем случае алгоритм посещает все узлы, поэтому его временная сложность равна $$O(N)$$.

## Пространственная сложность

Для очереди требуется $$O(W)$$ памяти, где $$W$$ — максимальная ширина дерева. В худшем случае пространственная сложность равна $$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
