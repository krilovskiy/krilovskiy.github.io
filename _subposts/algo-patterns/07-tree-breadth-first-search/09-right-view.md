---
title: Правый вид бинарного дерева
description: Поиск узлов бинарного дерева, видимых при взгляде справа.
pattern: tree-breadth-first-search
permalink: /posts/algo-patterns-tree-breadth-first-search/right-view/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дано бинарное дерево. Верните массив узлов, образующих его правый вид — множество узлов, видимых при взгляде на дерево справа.

![Правый вид бинарного дерева](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/right-view.svg){: width="600" }

## Решение

Задача следует паттерну обхода бинарного дерева по уровням. Выполняем обычный BFS и добавляем в результат последний узел каждого уровня.

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

func traverse(root *TreeNode) []*TreeNode {
	result := []*TreeNode{}
	if root == nil {
		return result
	}

	queue := []*TreeNode{root}
	for len(queue) > 0 {
		levelSize := len(queue)

		for i := 0; i < levelSize; i++ {
			currentNode := queue[0]
			queue = queue[1:]

			if i == levelSize-1 {
				result = append(result, currentNode)
			}
			if currentNode.Left != nil {
				queue = append(queue, currentNode.Left)
			}
			if currentNode.Right != nil {
				queue = append(queue, currentNode.Right)
			}
		}
	}

	return result
}

func main() {
	root := &TreeNode{Value: 12}
	root.Left = &TreeNode{Value: 7}
	root.Right = &TreeNode{Value: 1}
	root.Left.Left = &TreeNode{Value: 9}
	root.Right.Left = &TreeNode{Value: 10}
	root.Right.Right = &TreeNode{Value: 5}
	root.Left.Left.Left = &TreeNode{Value: 3}

	fmt.Print("Правый вид дерева: ")
	for _, node := range traverse(root) {
		fmt.Printf("%d ", node.Value)
	}
	fmt.Println()
}
```

**Вывод:**

```text
Правый вид дерева: 12 1 5 3 
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в дереве.

## Пространственная сложность

Результат содержит не больше $$O(H)$$ узлов, где $$H$$ — высота дерева. Для очереди требуется $$O(W)$$ памяти, где $$W$$ — максимальная ширина дерева; в худшем случае общая пространственная сложность равна $$O(N)$$.

## Вариации задачи

**Задача:** верните массив узлов, образующих левый вид бинарного дерева.

**Решение:** используйте тот же обход, но добавляйте в результат первый, а не последний узел каждого уровня.

{% include algo-task-nav.html position="bottom" %}
