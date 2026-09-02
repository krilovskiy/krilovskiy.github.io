---
title: Путь с заданной последовательностью
description: Проверка последовательности значений на пути от корня бинарного дерева до листа.
pattern: tree-depth-first-search
permalink: /posts/algo-patterns-tree-depth-first-search/path-with-given-sequence/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны бинарное дерево и последовательность чисел. Определите, представлена ли эта последовательность путём от корня до листа в данном дереве.

![Путь 1, 1, 6 совпадает с заданной последовательностью](/assets/img/posts/2026-11-01-algo-patterns-tree-depth-first-search/path-with-given-sequence.svg){: width="700" }

## Решение

Задача следует паттерну поиска пути с заданной суммой. Используем тот же DFS и дополнительно отслеживаем индекс элемента последовательности, который должен совпасть со значением текущего узла.

Как только значение узла не совпало с текущим элементом или последовательность закончилась раньше пути, возвращаем `false`. Совпадение считается найденным, только если одновременно достигнут лист и проверен последний элемент последовательности.

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

func findPath(root *TreeNode, sequence []int) bool {
	if root == nil {
		return len(sequence) == 0
	}
	return findPathRecursive(root, sequence, 0)
}

func findPathRecursive(currentNode *TreeNode, sequence []int, sequenceIndex int) bool {
	if currentNode == nil || sequenceIndex >= len(sequence) ||
		currentNode.Value != sequence[sequenceIndex] {
		return false
	}

	if currentNode.Left == nil && currentNode.Right == nil &&
		sequenceIndex == len(sequence)-1 {
		return true
	}

	return findPathRecursive(currentNode.Left, sequence, sequenceIndex+1) ||
		findPathRecursive(currentNode.Right, sequence, sequenceIndex+1)
}

func main() {
	root := &TreeNode{Value: 1}
	root.Left = &TreeNode{Value: 0}
	root.Right = &TreeNode{Value: 1}
	root.Left.Left = &TreeNode{Value: 1}
	root.Right.Left = &TreeNode{Value: 6}
	root.Right.Right = &TreeNode{Value: 5}

	fmt.Printf("В дереве есть путь [1 0 7]: %t\n", findPath(root, []int{1, 0, 7}))
	fmt.Printf("В дереве есть путь [1 1 6]: %t\n", findPath(root, []int{1, 1, 6}))
}
```

**Вывод:**

```text
В дереве есть путь [1 0 7]: false
В дереве есть путь [1 1 6]: true
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в дереве. Каждый узел посещается не более одного раза.

## Пространственная сложность

Для стека рекурсивных вызовов требуется $$O(H)$$ памяти, где $$H$$ — высота дерева. В худшем случае дерево вырождается в связанный список, поэтому пространственная сложность становится $$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
