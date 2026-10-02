---
title: Алгосы от Влада, часть 14. K-way merge
date: 2027-05-01 00:00:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
math: true
pattern: k-way-merge
short_title: K-way merge
primary_task_title: Слияние K отсортированных списков
primary_task_anchor: merge-k-sorted-lists
---

* [Введение](/posts/algo-patterns/)
* [Скользящее окно](/posts/algo-patterns-sliding-window/)
* [Два указателя или итератор](/posts/algo-patterns-two-pointers/)
* [Быстрый и медленный указатель](/posts/algo-patterns-fast-slow-pointer/)
* [Мерж интервалов](/posts/algo-patterns-merge-intervals/)
* [Циклическая сортировка](/posts/algo-patterns-cyclic-sort/)
* [Инвертирование связанного списка на месте](/posts/algo-patterns-in-place-reversal-linked-list/)
* [Дерево BFS](/posts/algo-patterns-tree-breadth-first-search/)
* [Дерево DFS](/posts/algo-patterns-tree-depth-first-search/)
* [Две кучи](/posts/algo-patterns-two-heaps/)
* [Подмножества](/posts/algo-patterns-subsets/)
* [Модифицированный бинарный поиск](/posts/algo-patterns-modified-binary-search/)
* [Побитовый XOR](/posts/algo-patterns-bitwise-xor/)
* [Лучшие K элементов](/posts/algo-patterns-top-k-elements/)
* <b>K-way merge</b>
* 0 or 1 Knapsack (Динамическое программирование)
* Топологическая сортировка

## Введение

Этот паттерн помогает обходить несколько отсортированных последовательностей в общем порядке. Помещаем первый элемент каждой в min-heap, извлекаем минимум и добавляем следующий элемент той последовательности, откуда он пришёл. Куча хранит текущих кандидатов, а принадлежность элемента исходному списку позволяет продолжить обход.

## Слияние K отсортированных списков {#merge-k-sorted-lists}

### Условие задачи

Даны `K` отсортированных связных списков. Объедините их в один отсортированный список.

```text
L1 = [2, 6, 8], L2 = [3, 6, 7], L3 = [1, 3, 4]
→ [1, 2, 3, 3, 4, 6, 6, 7, 8]

L1 = [5, 8, 9], L2 = [1, 7]
→ [1, 5, 7, 8, 9]
```

### Решение

Если собрать все `N` элементов и отсортировать, понадобится $$O(N\log N)$$ времени. Но списки уже упорядочены: минимальный ещё не обработанный элемент каждого находится в его голове.

1. Помещаем головы непустых списков в min-heap.
2. Извлекаем минимальный узел и присоединяем к результату.
3. Если у узла есть следующий, помещаем его в кучу.
4. Повторяем, пока куча не опустеет.

В первом примере начинаем с `2`, `3`, `1`. Извлекаем `1`, добавляем следующую `3` из третьего списка; затем извлекаем `2` и добавляем `6` из первого. Так в куче остаётся не более одного кандидата от каждого списка. Код переиспользует исходные узлы.

![Слияние трёх списков через минимальную кучу, шаг 1](/assets/img/posts/2027-05-01-algo-patterns-k-way-merge/merge-01.svg)

![Слияние трёх списков через минимальную кучу, шаг 2](/assets/img/posts/2027-05-01-algo-patterns-k-way-merge/merge-02.svg)

![Слияние трёх списков через минимальную кучу, шаг 3](/assets/img/posts/2027-05-01-algo-patterns-k-way-merge/merge-03.svg)

![Слияние трёх списков через минимальную кучу, шаг 4](/assets/img/posts/2027-05-01-algo-patterns-k-way-merge/merge-04.svg)

### Код

{% raw %}
```go
package main

import (
	"container/heap"
	"fmt"
)

type ListNode struct {
	Value int
	Next  *ListNode
}
type NodeHeap []*ListNode

func (h NodeHeap) Len() int           { return len(h) }
func (h NodeHeap) Less(i, j int) bool { return h[i].Value < h[j].Value }
func (h NodeHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
func (h *NodeHeap) Push(x any)        { *h = append(*h, x.(*ListNode)) }
func (h *NodeHeap) Pop() any          { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }

func merge(lists []*ListNode) *ListNode {
	h := &NodeHeap{}
	for _, head := range lists {
		if head != nil {
			heap.Push(h, head)
		}
	}
	var resultHead, resultTail *ListNode
	for h.Len() > 0 {
		node := heap.Pop(h).(*ListNode)
		if node.Next != nil {
			heap.Push(h, node.Next)
		}
		if resultHead == nil {
			resultHead = node
		} else {
			resultTail.Next = node
		}
		resultTail = node
	}
	if resultTail != nil {
		resultTail.Next = nil
	}
	return resultHead
}
func list(nums ...int) *ListNode {
	dummy := &ListNode{}
	tail := dummy
	for _, n := range nums {
		tail.Next = &ListNode{Value: n}
		tail = tail.Next
	}
	return dummy.Next
}
func values(head *ListNode) []int {
	result := []int{}
	for head != nil {
		result = append(result, head.Value)
		head = head.Next
	}
	return result
}

func main() {
	fmt.Println(values(merge([]*ListNode{list(2, 6, 8), list(3, 6, 7), list(1, 3, 4)})))
	fmt.Println(values(merge([]*ListNode{list(5, 8, 9), list(1, 7)})))
}
```
{% endraw %}

**Вывод:**

```text
[1 2 3 3 4 6 6 7 8]
[1 5 7 8 9]
```

### Временная сложность

$$O(N\log K)$$ для `N` узлов суммарно; при одном списке — $$O(N)$$.

### Пространственная сложность

$$O(K)$$ для кучи, без новых узлов результата.

## Задачи главы

1. [Слияние K отсортированных списков](#merge-k-sorted-lists)
2. [K-е наименьшее число в M списках](/posts/algo-patterns-k-way-merge/kth-smallest-in-sorted-lists/)
3. [K-е наименьшее число в матрице](/posts/algo-patterns-k-way-merge/kth-smallest-in-sorted-matrix/)
4. [Минимальный диапазон чисел](/posts/algo-patterns-k-way-merge/smallest-number-range/)
5. [K пар с наибольшими суммами](/posts/algo-patterns-k-way-merge/k-pairs-with-largest-sums/)

## Похожие задания

1. Merge k Sorted Lists [Leetcode](https://leetcode.com/problems/merge-k-sorted-lists/)
2. Kth Smallest Element in a Sorted Matrix [Leetcode](https://leetcode.com/problems/kth-smallest-element-in-a-sorted-matrix/)
3. Smallest Range Covering Elements from K Lists [Leetcode](https://leetcode.com/problems/smallest-range-covering-elements-from-k-lists/)
