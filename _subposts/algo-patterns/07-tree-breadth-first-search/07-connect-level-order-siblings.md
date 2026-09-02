---
title: Связывание соседей одного уровня
description: Заполнение указателей Next между соседними узлами каждого уровня бинарного дерева.
pattern: tree-breadth-first-search
permalink: /posts/algo-patterns-tree-breadth-first-search/connect-level-order-siblings/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дано бинарное дерево. Свяжите каждый узел с его следующим соседом при обходе уровня слева направо. Указатель последнего узла каждого уровня должен быть равен `nil`.

![Связи между соседними узлами каждого уровня](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/connect-level-order-siblings.svg){: width="600" }

## Решение

Задача следует паттерну обхода бинарного дерева по уровням. Выполняем обычный BFS и запоминаем предыдущий узел текущего уровня. После извлечения следующего узла связываем с ним поле `Next` предыдущего узла.

В начале каждого уровня переменная `previousNode` снова получает значение `nil`, поэтому последний узел уровня не связывается с первым узлом следующего.

## Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import "fmt"

type TreeNode struct {
	Value int
	Left  *TreeNode
	Right *TreeNode
	Next  *TreeNode
}

func connect(root *TreeNode) {
	if root == nil {
		return
	}

	queue := []*TreeNode{root}
	for len(queue) > 0 {
		levelSize := len(queue)
		var previousNode *TreeNode

		for i := 0; i < levelSize; i++ {
			currentNode := queue[0]
			queue = queue[1:]

			if previousNode != nil {
				previousNode.Next = currentNode
			}
			previousNode = currentNode

			if currentNode.Left != nil {
				queue = append(queue, currentNode.Left)
			}
			if currentNode.Right != nil {
				queue = append(queue, currentNode.Right)
			}
		}
	}
}

func printLevelOrder(root *TreeNode) {
	nextLevelRoot := root
	for nextLevelRoot != nil {
		current := nextLevelRoot
		nextLevelRoot = nil

		for current != nil {
			fmt.Printf("%d ", current.Value)
			if nextLevelRoot == nil {
				if current.Left != nil {
					nextLevelRoot = current.Left
				} else if current.Right != nil {
					nextLevelRoot = current.Right
				}
			}
			current = current.Next
		}
		fmt.Println()
	}
}

func main() {
	root := &TreeNode{Value: 12}
	root.Left = &TreeNode{Value: 7}
	root.Right = &TreeNode{Value: 1}
	root.Left.Left = &TreeNode{Value: 9}
	root.Right.Left = &TreeNode{Value: 10}
	root.Right.Right = &TreeNode{Value: 5}

	connect(root)
	fmt.Println("Обход уровней по указателям Next:")
	printLevelOrder(root)
}
```

**Вывод:**

```text
Обход уровней по указателям Next:
12 
7 1 
9 10 5 
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в дереве.

## Пространственная сложность

Для очереди требуется $$O(W)$$ памяти, где $$W$$ — максимальная ширина дерева. В худшем случае это $$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
