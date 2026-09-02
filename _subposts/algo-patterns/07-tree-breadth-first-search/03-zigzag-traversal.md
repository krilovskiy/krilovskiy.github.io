---
title: Зигзагообразный обход дерева
description: Обход уровней бинарного дерева с чередованием направления слева направо и справа налево.
pattern: tree-breadth-first-search
permalink: /posts/algo-patterns-tree-breadth-first-search/zigzag-traversal/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дано бинарное дерево. Сформируйте массив, представляющий его зигзагообразный обход по уровням: узлы первого уровня идут слева направо, следующего — справа налево, а затем направление продолжает чередоваться.

![Зигзагообразный обход бинарного дерева](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/zigzag-traversal.svg){: width="600" }

## Решение

Задача следует паттерну обхода бинарного дерева по уровням. Выполняем обычный BFS, но для каждого второго уровня записываем значения в обратном направлении.

Переменная `leftToRight` задаёт направление текущего уровня. Когда она равна `true`, помещаем очередное значение в позицию `i`; иначе — в симметричную позицию `levelSize-1-i`. После завершения уровня меняем направление.

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

func traverse(root *TreeNode) [][]int {
	result := [][]int{}
	if root == nil {
		return result
	}

	queue := []*TreeNode{root}
	leftToRight := true

	for len(queue) > 0 {
		levelSize := len(queue)
		currentLevel := make([]int, levelSize)

		for i := 0; i < levelSize; i++ {
			currentNode := queue[0]
			queue = queue[1:]

			index := i
			if !leftToRight {
				index = levelSize - 1 - i
			}
			currentLevel[index] = currentNode.Value

			if currentNode.Left != nil {
				queue = append(queue, currentNode.Left)
			}
			if currentNode.Right != nil {
				queue = append(queue, currentNode.Right)
			}
		}

		result = append(result, currentLevel)
		leftToRight = !leftToRight
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
	root.Right.Left.Left = &TreeNode{Value: 20}
	root.Right.Left.Right = &TreeNode{Value: 17}

	fmt.Printf("Зигзагообразный обход: %v\n", traverse(root))
}
```

**Вывод:**

```text
Зигзагообразный обход: [[12] [1 7] [9 10 5] [17 20]]
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в дереве.

## Пространственная сложность

Для результата и очереди требуется $$O(N)$$ памяти. Сама очередь содержит не больше $$O(W)$$ узлов, где $$W$$ — максимальная ширина дерева.

{% include algo-task-nav.html position="bottom" %}
