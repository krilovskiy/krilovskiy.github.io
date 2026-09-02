---
title: Связывание всех узлов по порядку обхода
description: Заполнение указателей Next между всеми узлами в последовательности BFS.
pattern: tree-breadth-first-search
permalink: /posts/algo-patterns-tree-breadth-first-search/connect-all-level-order-siblings/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дано бинарное дерево. Свяжите каждый узел с его преемником при обходе по уровням. Последний узел каждого уровня должен указывать на первый узел следующего уровня.

![Связи между всеми узлами в порядке BFS](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/connect-all-level-order-siblings.svg){: width="600" }

## Решение

Задача следует паттерну обхода бинарного дерева по уровням. В отличие от связывания соседей одного уровня, переменная `previousNode` не сбрасывается при переходе между уровнями. Каждый извлечённый из очереди узел становится следующим для предыдущего, поэтому поле `Next` образует единую цепочку в порядке BFS.

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
	var previousNode *TreeNode

	for len(queue) > 0 {
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

func printTree(root *TreeNode) {
	fmt.Print("Обход по указателям Next: ")
	for current := root; current != nil; current = current.Next {
		fmt.Printf("%d ", current.Value)
	}
	fmt.Println()
}

func main() {
	root := &TreeNode{Value: 12}
	root.Left = &TreeNode{Value: 7}
	root.Right = &TreeNode{Value: 1}
	root.Left.Left = &TreeNode{Value: 9}
	root.Right.Left = &TreeNode{Value: 10}
	root.Right.Right = &TreeNode{Value: 5}

	connect(root)
	printTree(root)
}
```

**Вывод:**

```text
Обход по указателям Next: 12 7 1 9 10 5 
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в дереве.

## Пространственная сложность

Для очереди требуется $$O(W)$$ памяти, где $$W$$ — максимальная ширина дерева. В худшем случае это $$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
