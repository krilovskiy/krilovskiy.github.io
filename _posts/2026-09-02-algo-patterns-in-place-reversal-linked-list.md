---
title: Алгосы от Влада, часть 6. Инвертирование связанного списка на месте
date: 2026-09-01 20:21:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
math: true
pattern: in-place-reversal-linked-list
short_title: Инвертирование связанного списка на месте
primary_task_title: Инвертирование всего связанного списка
primary_task_anchor: reverse-linked-list
---


* [Введение](/posts/algo-patterns/)
* [Скользящее окно](/posts/algo-patterns-sliding-window/)
* [Два указателя или итератор](/posts/algo-patterns-two-pointers/)
* [Быстрый и медленный указатель](/posts/algo-patterns-fast-slow-pointer/)
* [Мерж интервалов](/posts/algo-patterns-merge-intervals/)
* [Циклическая сортировка](/posts/algo-patterns-cyclic-sort/)
* <b>Инвертирование связанного списка на месте</b>
* [Дерево BFS](/posts/algo-patterns-tree-breadth-first-search/)
* [Дерево DFS](/posts/algo-patterns-tree-depth-first-search/)
* Две кучи
* Подмножества
* Модифицированный бинарный поиск
* Побитовый XOR
* Лучшие элементы К (top K elements)
* k-образный алгоритм слияния (K-Way merge)
* 0 or 1 Knapsack (Динамическое программирование)
* Топологическая сортировка


## Введение

Во многих задачах нас просят инвертировать связи между некоторым набором узлов связанного списка. Часто требуется сделать это на месте, то есть использовать существующие объекты узлов и не выделять дополнительную память.

Паттерн инвертирования связанного списка на месте описывает эффективный способ решения такой задачи. В следующих разделах мы решим несколько задач с помощью этого паттерна.

Давайте перейдём к первой задаче, чтобы разобраться, как работает этот паттерн.


## Инвертирование всего связанного списка (простой уровень) {#reverse-linked-list}

### Условие задачи

Дана голова односвязного списка. Инвертируйте связанный список. Напишите функцию, которая возвращает новую голову инвертированного списка.

![Исходный связанный список](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/reverse-linked-list-01.svg){: width="800" }

### Решение

Чтобы инвертировать связанный список, нужно разворачивать по одному узлу за раз. Начнём с переменной `current`, которая изначально указывает на голову списка, и переменной `previous`, которая указывает на предыдущий уже обработанный узел. Изначально `previous` указывает на `nil`.

На каждом шаге мы инвертируем текущий узел, направляя его ссылку на `previous`, а затем переходим к следующему узлу. Также мы обновляем `previous`, чтобы эта переменная всегда указывала на предыдущий обработанный узел. Ниже показана работа алгоритма:

![Инвертирование связанного списка — шаг 1](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/reverse-linked-list-02.svg){: width="800" }

![Инвертирование связанного списка — шаг 2](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/reverse-linked-list-03.svg){: width="800" }

![Инвертирование связанного списка — шаг 3](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/reverse-linked-list-04.svg){: width="800" }

![Инвертирование связанного списка — шаг 4](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/reverse-linked-list-05.svg){: width="800" }

![Инвертирование связанного списка — шаг 5](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/reverse-linked-list-06.svg){: width="800" }

![Инвертирование связанного списка — шаг 6](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/reverse-linked-list-07.svg){: width="800" }

![Инвертирование связанного списка — шаг 7](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/reverse-linked-list-08.svg){: width="800" }

### Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import "fmt"

type ListNode struct {
	Value int
	Next  *ListNode
}

func reverse(head *ListNode) *ListNode {
	current := head
	var previous *ListNode

	for current != nil {
		next := current.Next
		current.Next = previous
		previous = current
		current = next
	}

	return previous
}

func newList(values ...int) *ListNode {
	dummy := &ListNode{}
	current := dummy

	for _, value := range values {
		current.Next = &ListNode{Value: value}
		current = current.Next
	}

	return dummy.Next
}

func printList(head *ListNode) {
	first := true
	for current := head; current != nil; current = current.Next {
		if !first {
			fmt.Print(" ")
		}
		fmt.Print(current.Value)
		first = false
	}
	fmt.Println()
}

func main() {
	head := newList(2, 4, 6, 8, 10)
	head = reverse(head)

	fmt.Print("Узлы инвертированного связанного списка: ")
	printList(head)
}
```

**Вывод:**

```text
Узлы инвертированного связанного списка: 10 8 6 4 2
```

### Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в связанном списке.

### Пространственная сложность

Мы использовали только постоянный объём памяти, поэтому пространственная сложность алгоритма равна $$O(1)$$.


## Задачи главы

1. [Инвертирование всего связанного списка (простой уровень)](#reverse-linked-list)
2. [Инвертирование участка связанного списка (средний уровень)](/posts/algo-patterns-in-place-reversal-linked-list/reverse-sub-list/)
3. [Инвертирование списка группами по k элементов (средний уровень)](/posts/algo-patterns-in-place-reversal-linked-list/reverse-every-k-elements/)
4. [Инвертирование каждой второй группы из k элементов (средний уровень)](/posts/algo-patterns-in-place-reversal-linked-list/reverse-alternating-k-elements/)
5. [Циклический сдвиг связанного списка вправо (средний уровень)](/posts/algo-patterns-in-place-reversal-linked-list/rotate-linked-list/)


## Похожие задания

### Pattern: In-place Reversal of a LinkedList

1. Reverse a LinkedList (easy) [Leetcode](https://leetcode.com/problems/reverse-linked-list/)
2. Reverse a Sub-list (medium) [Leetcode](https://leetcode.com/problems/reverse-linked-list-ii/)
3. Reverse every K-element Sub-list (medium) [Leetcode](https://leetcode.com/problems/reverse-nodes-in-k-group/)
4. Reverse alternating K-element Sub-list (medium) [GeeksforGeeks](https://www.geeksforgeeks.org/dsa/reverse-alternate-k-nodes-in-a-singly-linked-list/)
5. Rotate a LinkedList (medium) [Leetcode](https://leetcode.com/problems/rotate-list/)
6. Swap Nodes in Pairs (medium) [Leetcode](https://leetcode.com/problems/swap-nodes-in-pairs/)
7. Reverse Nodes in Even Length Groups (medium) [Leetcode](https://leetcode.com/problems/reverse-nodes-in-even-length-groups/)
8. Reorder List (medium) [Leetcode](https://leetcode.com/problems/reorder-list/)
