---
title: Сумма чисел, образованных путями
description: Суммирование чисел, которые образуют пути от корня бинарного дерева до листьев.
pattern: tree-depth-first-search
permalink: /posts/algo-patterns-tree-depth-first-search/sum-of-path-numbers/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дано бинарное дерево, каждый узел которого содержит одну цифру от `0` до `9`. Каждый путь от корня до листа образует число. Найдите сумму всех чисел, представленных такими путями.

![Числа 101, 116 и 115 образованы путями бинарного дерева](/assets/img/posts/2026-11-01-algo-patterns-tree-depth-first-search/sum-of-path-numbers.svg){: width="700" }

## Решение

Задача следует паттерну поиска пути с заданной суммой. Используем тот же DFS и дополнительно отслеживаем число, образованное текущим путём.

Если в уже пройденной части пути записано число `pathSum`, то после перехода в узел с цифрой `currentNode.Value` новое число равно:

$$
pathSum = 10 \cdot pathSum + currentNode.Value
$$

Например, в узле `7` путь `1 → 7` представляет число `17`, потому что $$1 \cdot 10 + 7 = 17$$. Достигнув листа, возвращаем число текущего пути. Для внутреннего узла складываем результаты левого и правого поддеревьев.

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

func findSumOfPathNumbers(root *TreeNode) int {
	return findRootToLeafPathNumbers(root, 0)
}

func findRootToLeafPathNumbers(currentNode *TreeNode, pathSum int) int {
	if currentNode == nil {
		return 0
	}

	pathSum = 10*pathSum + currentNode.Value
	if currentNode.Left == nil && currentNode.Right == nil {
		return pathSum
	}

	return findRootToLeafPathNumbers(currentNode.Left, pathSum) +
		findRootToLeafPathNumbers(currentNode.Right, pathSum)
}

func main() {
	root := &TreeNode{Value: 1}
	root.Left = &TreeNode{Value: 0}
	root.Right = &TreeNode{Value: 1}
	root.Left.Left = &TreeNode{Value: 1}
	root.Right.Left = &TreeNode{Value: 6}
	root.Right.Right = &TreeNode{Value: 5}

	fmt.Printf("Сумма чисел всех путей: %d\n", findSumOfPathNumbers(root))
}
```

**Вывод:**

```text
Сумма чисел всех путей: 332
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в дереве. Каждый узел посещается один раз.

## Пространственная сложность

Для стека рекурсивных вызовов требуется $$O(H)$$ памяти, где $$H$$ — высота дерева. В худшем случае дерево вырождается в связанный список, поэтому пространственная сложность становится $$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
