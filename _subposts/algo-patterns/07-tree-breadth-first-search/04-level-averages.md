---
title: Средние значения уровней бинарного дерева
description: Вычисление среднего значения узлов на каждом уровне бинарного дерева.
pattern: tree-breadth-first-search
permalink: /posts/algo-patterns-tree-breadth-first-search/level-averages/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дано бинарное дерево. Сформируйте массив со средними значениями всех его уровней.

![Средние значения уровней бинарного дерева](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/level-averages.svg){: width="600" }

## Решение

Задача следует паттерну обхода бинарного дерева по уровням. Выполняем обычный BFS, но вместо сохранения всех узлов уровня поддерживаем сумму их значений. После обработки уровня делим сумму на количество узлов и добавляем среднее значение в результат.

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

func findLevelAverages(root *TreeNode) []float64 {
	result := []float64{}
	if root == nil {
		return result
	}

	queue := []*TreeNode{root}
	for len(queue) > 0 {
		levelSize := len(queue)
		levelSum := 0.0

		for i := 0; i < levelSize; i++ {
			currentNode := queue[0]
			queue = queue[1:]
			levelSum += float64(currentNode.Value)

			if currentNode.Left != nil {
				queue = append(queue, currentNode.Left)
			}
			if currentNode.Right != nil {
				queue = append(queue, currentNode.Right)
			}
		}

		result = append(result, levelSum/float64(levelSize))
	}

	return result
}

func main() {
	root := &TreeNode{Value: 12}
	root.Left = &TreeNode{Value: 7}
	root.Right = &TreeNode{Value: 1}
	root.Left.Left = &TreeNode{Value: 9}
	root.Left.Right = &TreeNode{Value: 2}
	root.Right.Left = &TreeNode{Value: 10}
	root.Right.Right = &TreeNode{Value: 5}

	fmt.Printf("Средние значения уровней: %v\n", findLevelAverages(root))
}
```

**Вывод:**

```text
Средние значения уровней: [12 4 6.5]
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в дереве.

## Пространственная сложность

Для очереди требуется $$O(W)$$ памяти, где $$W$$ — максимальная ширина дерева. В худшем случае пространственная сложность равна $$O(N)$$.

## Вариации задачи

**Задача:** найдите наибольшее значение на каждом уровне бинарного дерева.

**Решение:** используйте тот же обход, но вместо суммы отслеживайте максимальное значение текущего уровня.

{% include algo-task-nav.html position="bottom" %}
