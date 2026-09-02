---
title: Алгосы от Влада, часть 8. Обход дерева в глубину (DFS)
date: 2026-11-01 00:00:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
math: true
pattern: tree-depth-first-search
short_title: Дерево DFS
primary_task_title: Путь в бинарном дереве с заданной суммой
primary_task_anchor: binary-tree-path-sum
---


* [Введение](/posts/algo-patterns/)
* [Скользящее окно](/posts/algo-patterns-sliding-window/)
* [Два указателя или итератор](/posts/algo-patterns-two-pointers/)
* [Быстрый и медленный указатель](/posts/algo-patterns-fast-slow-pointer/)
* [Мерж интервалов](/posts/algo-patterns-merge-intervals/)
* [Циклическая сортировка](/posts/algo-patterns-cyclic-sort/)
* [Инвертирование связанного списка на месте](/posts/algo-patterns-in-place-reversal-linked-list/)
* [Дерево BFS](/posts/algo-patterns-tree-breadth-first-search/)
* <b>Дерево DFS</b>
* Две кучи
* Подмножества
* Модифицированный бинарный поиск
* Побитовый XOR
* Лучшие элементы К (top K elements)
* k-образный алгоритм слияния (K-Way merge)
* 0 or 1 Knapsack (Динамическое программирование)
* Топологическая сортировка


## Введение

Этот паттерн основан на поиске в глубину — Depth First Search, или DFS, — и применяется для обхода дерева.

Во время обхода будем использовать рекурсию. Она сохраняет в стеке вызовов все предыдущие, то есть родительские, узлы. Итеративный вариант может хранить их в собственном стеке. В обоих случаях алгоритму требуется $$O(H)$$ дополнительной памяти, где $$H$$ — максимальная высота дерева.

Давайте перейдём к первой задаче и разберёмся, как работает этот паттерн.


## Путь в бинарном дереве с заданной суммой (простой уровень) {#binary-tree-path-sum}

### Условие задачи

Даны бинарное дерево и число `sum`. Определите, существует ли в дереве путь от корня до листа, сумма значений узлов которого равна `sum`.

![Путь от корня до листа с суммой 23](/assets/img/posts/2026-11-01-algo-patterns-tree-depth-first-search/binary-tree-path-sum.svg){: width="700" }

### Решение

Нужно найти путь от корня до листа, поэтому применим поиск в глубину. Рекурсивный алгоритм начинает обход с корня и для каждого внутреннего узла вызывает себя для левого и правого потомков.

Алгоритм выглядит так:

1. Начать DFS с корня дерева.
2. Если текущий узел не является листом, вычесть его значение из искомой суммы: `sum = sum - currentNode.Value`.
3. Рекурсивно проверить обоих потомков с новой суммой.
4. Если текущий узел — лист и его значение равно оставшейся сумме, нужный путь найден: вернуть `true`.
5. Если текущий узел — лист, но его значение не равно оставшейся сумме, вернуть `false`.

### Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import "fmt"

type TreeNode struct {
	Value int
	Left  *TreeNode
	Right *TreeNode
}

func hasPath(root *TreeNode, sum int) bool {
	if root == nil {
		return false
	}

	if root.Value == sum && root.Left == nil && root.Right == nil {
		return true
	}

	remainingSum := sum - root.Value
	return hasPath(root.Left, remainingSum) || hasPath(root.Right, remainingSum)
}

func main() {
	root := &TreeNode{Value: 12}
	root.Left = &TreeNode{Value: 7}
	root.Right = &TreeNode{Value: 1}
	root.Left.Left = &TreeNode{Value: 9}
	root.Right.Left = &TreeNode{Value: 10}
	root.Right.Right = &TreeNode{Value: 5}

	fmt.Printf("В дереве есть путь с суммой 23: %t\n", hasPath(root, 23))
	fmt.Printf("В дереве есть путь с суммой 16: %t\n", hasPath(root, 16))
}
```

**Вывод:**

```text
В дереве есть путь с суммой 23: true
В дереве есть путь с суммой 16: false
```

### Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в дереве. Каждый узел посещается не более одного раза.

### Пространственная сложность

Для стека рекурсивных вызовов требуется $$O(H)$$ памяти, где $$H$$ — высота дерева. В худшем случае дерево вырождается в связанный список, поэтому пространственная сложность становится $$O(N)$$.


## Задачи главы

1. [Путь в бинарном дереве с заданной суммой (простой уровень)](#binary-tree-path-sum)
2. [Все пути с заданной суммой (средний уровень)](/posts/algo-patterns-tree-depth-first-search/all-paths-for-a-sum/)
3. [Сумма чисел, образованных путями (средний уровень)](/posts/algo-patterns-tree-depth-first-search/sum-of-path-numbers/)
4. [Путь с заданной последовательностью (средний уровень)](/posts/algo-patterns-tree-depth-first-search/path-with-given-sequence/)
5. [Количество путей с заданной суммой (средний уровень)](/posts/algo-patterns-tree-depth-first-search/count-paths-for-a-sum/)
6. [Диаметр бинарного дерева (средний уровень)](/posts/algo-patterns-tree-depth-first-search/tree-diameter/)
7. [Путь с максимальной суммой (сложный уровень)](/posts/algo-patterns-tree-depth-first-search/path-with-maximum-sum/)


## Похожие задания

### Pattern: Tree Depth First Search

1. Path Sum [Leetcode](https://leetcode.com/problems/path-sum/)
2. Path Sum II [Leetcode](https://leetcode.com/problems/path-sum-ii/)
3. Sum Root to Leaf Numbers [Leetcode](https://leetcode.com/problems/sum-root-to-leaf-numbers/)
4. Check If a String Is a Valid Sequence from Root to Leaves Path in a Binary Tree [Leetcode](https://leetcode.com/problems/check-if-a-string-is-a-valid-sequence-from-root-to-leaves-path-in-a-binary-tree/)
5. Path Sum III [Leetcode](https://leetcode.com/problems/path-sum-iii/)
6. Binary Tree Maximum Path Sum [Leetcode](https://leetcode.com/problems/binary-tree-maximum-path-sum/)
