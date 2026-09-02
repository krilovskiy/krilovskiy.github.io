---
title: Алгосы от Влада, часть 7. Обход дерева в ширину (BFS)
date: 2026-10-01 00:00:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
math: true
pattern: tree-breadth-first-search
short_title: Дерево BFS
primary_task_title: Обход бинарного дерева по уровням
primary_task_anchor: binary-tree-level-order-traversal
---


* [Введение](/posts/algo-patterns/)
* [Скользящее окно](/posts/algo-patterns-sliding-window/)
* [Два указателя или итератор](/posts/algo-patterns-two-pointers/)
* [Быстрый и медленный указатель](/posts/algo-patterns-fast-slow-pointer/)
* [Мерж интервалов](/posts/algo-patterns-merge-intervals/)
* [Циклическая сортировка](/posts/algo-patterns-cyclic-sort/)
* [Инвертирование связанного списка на месте](/posts/algo-patterns-in-place-reversal-linked-list/)
* <b>Дерево BFS</b>
* Дерево DFS
* Две кучи
* Подмножества
* Модифицированный бинарный поиск
* Побитовый XOR
* Лучшие элементы К (top K elements)
* k-образный алгоритм слияния (K-Way merge)
* 0 or 1 Knapsack (Динамическое программирование)
* Топологическая сортировка


## Введение

Этот паттерн основан на поиске в ширину — Breadth First Search, или BFS, — и применяется для обхода дерева.

Любую задачу, в которой дерево нужно обходить уровень за уровнем, можно эффективно решить с помощью этого подхода. Очередь позволяет сохранить все узлы текущего уровня перед переходом к следующему. Поэтому для самой очереди потребуется $$O(W)$$ памяти, где $$W$$ — максимальное количество узлов на одном уровне дерева.

Давайте перейдём к первой задаче и разберёмся, как работает этот паттерн.


## Обход бинарного дерева по уровням (простой уровень) {#binary-tree-level-order-traversal}

### Условие задачи

Дано бинарное дерево. Сформируйте массив, представляющий обход дерева по уровням. Значения узлов каждого уровня должны идти слева направо и находиться в отдельном подмассиве.

![Обход бинарного дерева по уровням слева направо](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/level-order-traversal.svg){: width="600" }

### Решение

Прежде чем перейти к следующему уровню, нужно посетить все узлы текущего. Поэтому используем поиск в ширину и очередь. Алгоритм выглядит так:

1. Добавить корневой узел в очередь.
2. Продолжать обход, пока очередь не опустеет.
3. В начале каждой итерации запомнить количество элементов в очереди в переменной `levelSize`. Столько узлов находится на текущем уровне.
4. Извлечь из очереди `levelSize` узлов и добавить их значения в массив текущего уровня.
5. После извлечения каждого узла добавить в очередь его левого и правого потомков, если они существуют.
6. Добавить собранный уровень в результат и повторить шаги для следующего уровня.

Ниже показано, как алгоритм обрабатывает дерево из примера.

![В очереди находится корень дерева](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/level-order-step-01.svg){: width="600" }

![Начало обработки первого уровня](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/level-order-step-02.svg){: width="600" }

![Первый уровень добавлен в результат](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/level-order-step-03.svg){: width="600" }

![Начало обработки второго уровня](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/level-order-step-04.svg){: width="600" }

![Второй уровень добавлен в результат](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/level-order-step-05.svg){: width="600" }

![Начало обработки третьего уровня](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/level-order-step-06.svg){: width="600" }

![Все уровни дерева добавлены в результат](/assets/img/posts/2026-10-01-algo-patterns-tree-breadth-first-search/level-order-step-07.svg){: width="600" }

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

func traverse(root *TreeNode) [][]int {
	result := [][]int{}
	if root == nil {
		return result
	}

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

		result = append(result, currentLevel)
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

	fmt.Printf("Обход по уровням: %v\n", traverse(root))
}
```

**Вывод:**

```text
Обход по уровням: [[12] [7 1] [9 10 5]]
```

### Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в дереве. Каждый узел посещается ровно один раз.

### Пространственная сложность

Для результата требуется $$O(N)$$ памяти. Очередь содержит не больше $$O(W)$$ узлов, где $$W$$ — максимальная ширина дерева; в худшем случае это также $$O(N)$$. Поэтому общая пространственная сложность равна $$O(N)$$.


## Задачи главы

1. [Обход бинарного дерева по уровням (простой уровень)](#binary-tree-level-order-traversal)
2. [Обратный обход дерева по уровням (простой уровень)](/posts/algo-patterns-tree-breadth-first-search/reverse-level-order-traversal/)
3. [Зигзагообразный обход дерева (средний уровень)](/posts/algo-patterns-tree-breadth-first-search/zigzag-traversal/)
4. [Средние значения уровней бинарного дерева (простой уровень)](/posts/algo-patterns-tree-breadth-first-search/level-averages/)
5. [Минимальная глубина бинарного дерева (простой уровень)](/posts/algo-patterns-tree-breadth-first-search/minimum-depth/)
6. [Следующий узел при обходе по уровням (простой уровень)](/posts/algo-patterns-tree-breadth-first-search/level-order-successor/)
7. [Связывание соседей одного уровня (средний уровень)](/posts/algo-patterns-tree-breadth-first-search/connect-level-order-siblings/)
8. [Связывание всех узлов по порядку обхода (средний уровень)](/posts/algo-patterns-tree-breadth-first-search/connect-all-level-order-siblings/)
9. [Правый вид бинарного дерева (простой уровень)](/posts/algo-patterns-tree-breadth-first-search/right-view/)


## Похожие задания

### Pattern: Tree Breadth First Search

1. Binary Tree Level Order Traversal [Leetcode](https://leetcode.com/problems/binary-tree-level-order-traversal/)
2. Binary Tree Level Order Traversal II [Leetcode](https://leetcode.com/problems/binary-tree-level-order-traversal-ii/)
3. Binary Tree Zigzag Level Order Traversal [Leetcode](https://leetcode.com/problems/binary-tree-zigzag-level-order-traversal/)
4. Average of Levels in Binary Tree [Leetcode](https://leetcode.com/problems/average-of-levels-in-binary-tree/)
5. Minimum Depth of Binary Tree [Leetcode](https://leetcode.com/problems/minimum-depth-of-binary-tree/)
6. Populating Next Right Pointers in Each Node II [Leetcode](https://leetcode.com/problems/populating-next-right-pointers-in-each-node-ii/)
7. Binary Tree Right Side View [Leetcode](https://leetcode.com/problems/binary-tree-right-side-view/)
