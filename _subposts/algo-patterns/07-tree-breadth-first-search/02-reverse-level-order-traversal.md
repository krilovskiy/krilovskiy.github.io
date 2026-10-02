---
title: Обратный обход дерева по уровням
description: Обход бинарного дерева снизу вверх с сохранением порядка узлов слева направо.
pattern: tree-breadth-first-search
permalink: /posts/algo-patterns-tree-breadth-first-search/reverse-level-order-traversal/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дано бинарное дерево. Сформируйте массив, представляющий обход дерева по уровням в обратном порядке: сначала самый нижний уровень, затем все остальные вплоть до корня. Значения узлов каждого уровня должны идти слева направо и находиться в отдельном подмассиве.

![Обратный обход бинарного дерева по уровням](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/reverse-level-order.svg){: width="600" }

## Решение

Задача следует паттерну обхода бинарного дерева по уровням. Используем тот же поиск в ширину, но каждый собранный уровень добавляем не в конец, а в начало результата.

Чтобы добавление в начало оставалось операцией за постоянное время, временно сохраним уровни в двусвязном списке. После обхода перенесём их в итоговый срез.

## Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import (
	"container/list"
	"fmt"
)

type TreeNode struct {
	Value int
	Left  *TreeNode
	Right *TreeNode
}

func traverse(root *TreeNode) [][]int {
	if root == nil {
		return [][]int{}
	}

	levels := list.New()
	queue := []*TreeNode{root}

	for len(queue) > 0 {
		levelSize := len(queue)
		currentLevel := make([]int, 0, levelSize)

		for i := 0; i < levelSize; i++ {
			currentNode := queue[0]
			queue = queue[1:]
			currentLevel = append(currentLevel, currentNode.Value)

			if currentNode.Left != nil {
				queue = append(queue, currentNode.Left)
			}
			if currentNode.Right != nil {
				queue = append(queue, currentNode.Right)
			}
		}

		levels.PushFront(currentLevel)
	}

	result := make([][]int, 0, levels.Len())
	for level := levels.Front(); level != nil; level = level.Next() {
		result = append(result, level.Value.([]int))
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

	fmt.Printf("Обратный обход по уровням: %v\n", traverse(root))
}
```

**Вывод:**

```text
Обратный обход по уровням: [[9 10 5] [7 1] [12]]
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в дереве. Каждый узел посещается один раз.

## Пространственная сложность

Для результата требуется $$O(N)$$ памяти. В очереди одновременно находится не больше $$O(W)$$ узлов, где $$W$$ — максимальная ширина дерева, поэтому общая пространственная сложность равна $$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
