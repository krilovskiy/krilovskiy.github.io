---
title: Структурно уникальные бинарные деревья поиска
description: Построение всех различных структур BST для значений от 1 до n.
pattern: subsets
permalink: /posts/algo-patterns-subsets/structurally-unique-bst/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дано число $$n$$. Напишите функцию, которая возвращает все структурно уникальные бинарные деревья поиска — Binary Search Trees (BST), содержащие значения от `1` до `n`.

**Пример 1:**

```text
Вход: n = 2
Выход: 2 различных дерева
```

Все структуры для значений `1` и `2`:

[![Два структурно различных дерева поиска со значениями 1 и 2](/assets/img/posts/2027-01-01-algo-patterns-subsets/unique-bst-two-nodes.svg)](/assets/img/posts/2027-01-01-algo-patterns-subsets/unique-bst-two-nodes.svg)

**Пример 2:**

```text
Вход: n = 3
Выход: 5 различных деревьев
```

Все структуры для значений от `1` до `3`:

[![Пять структурно различных деревьев поиска со значениями от 1 до 3](/assets/img/posts/2027-01-01-algo-patterns-subsets/unique-bst-three-nodes.svg)](/assets/img/posts/2027-01-01-algo-patterns-subsets/unique-bst-three-nodes.svg)

## Решение

Задача следует паттерну «Подмножества» и похожа на вычисление выражения с разными скобками.

1. Перебираем числа от `1` до `n`, рассматривая каждое как корень дерева.
2. Все меньшие числа образуют левое поддерево, а все большие — правое.
3. Рекурсивно строим все варианты левого и правого поддеревьев.
4. Для каждой пары создаём корень и присоединяем выбранные поддеревья.

Пустой диапазон возвращает список с одним `nil`, обозначающим пустое поддерево. Это позволяет построить дерево, у которого отсутствует один или оба потомка. Например, для `n=1` оба рекурсивных вызова возвращают `nil`, а результат содержит единственный узел `1`.

## Код

Функция `findUniqueTrees` возвращает корни деревьев. В примере печатаем каждое дерево в виде `значение(левое поддерево, правое поддерево)`, где `nil` обозначает пустое поддерево.

{% raw %}
```go
package main

import "fmt"

type TreeNode struct {
	val   int
	left  *TreeNode
	right *TreeNode
}

func findUniqueTrees(n int) []*TreeNode {
	if n <= 0 {
		return []*TreeNode{}
	}
	return findUniqueTreesRecursive(1, n)
}
func findUniqueTreesRecursive(start, end int) []*TreeNode {
	if start > end {
		return []*TreeNode{nil}
	}
	result := []*TreeNode{}
	for i := start; i <= end; i++ {
		leftSubtrees := findUniqueTreesRecursive(start, i-1)
		rightSubtrees := findUniqueTreesRecursive(i+1, end)
		for _, leftTree := range leftSubtrees {
			for _, rightTree := range rightSubtrees {
				root := &TreeNode{val: i, left: leftTree, right: rightTree}
				result = append(result, root)
			}
		}
	}
	return result
}

// Запись дерева: значение(левое поддерево, правое поддерево); nil — пустое поддерево.
func describeTree(root *TreeNode) string {
	if root == nil {
		return "nil"
	}
	return fmt.Sprintf("%d(%s,%s)", root.val, describeTree(root.left), describeTree(root.right))
}
func main() {
	for _, n := range []int{2, 3} {
		trees := findUniqueTrees(n)
		fmt.Printf("n=%d, деревьев: %d\n", n, len(trees))
		for _, tree := range trees {
			fmt.Println(describeTree(tree))
		}
	}
}
```
{% endraw %}

**Вывод:**

```text
n=2, деревьев: 2
1(nil,2(nil,nil))
2(1(nil,nil),nil)
n=3, деревьев: 5
1(nil,2(nil,3(nil,nil)))
1(nil,3(2(nil,nil),nil))
2(1(nil,nil),3(nil,nil))
3(1(nil,2(nil,nil)),nil)
3(2(1(nil,nil),nil),nil)
```

## Временная сложность

Сложность экспоненциальная, как в задаче со сбалансированными скобками. В оригинале приведены приблизительная оценка $$O(n \cdot 2^n)$$ и более точная $$O(4^n / \sqrt{n})$$, связанная с числами Каталана. Для оценки построения всех деревьев используем вторую; первая не является корректной верхней границей по числу значений $$n$$.

## Пространственная сложность

Оригинал приводит приблизительную оценку $$O(2^n)$$ и уточнённую $$O(4^n / \sqrt{n})$$. Память требуется для построенных деревьев и промежуточных результатов.

## Мемоизация

В оригинале обсуждается возможность мемоизации, поскольку подзадачи повторяются. Однако при извлечении деревьев из кеша для использования в качестве левого или правого потомка нужно клонировать результат, если требуется независимость деревьев.

Такое клонирование равносильно повторному построению деревьев, поэтому по приведённой в оригинале оценке мемоизация не изменяет общую временную сложность. Отдельного алгоритма с кешем в исходнике нет.

{% include algo-task-nav.html position="bottom" %}
