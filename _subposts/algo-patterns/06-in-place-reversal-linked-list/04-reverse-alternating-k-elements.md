---
title: Инвертирование каждой второй группы из k элементов
description: Инвертирование каждой второй группы из k элементов односвязного списка.
pattern: in-place-reversal-linked-list
permalink: /posts/algo-patterns-in-place-reversal-linked-list/reverse-alternating-k-elements/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дана голова связанного списка и число `k`. Инвертируйте каждый второй подсписок размером `k`, начиная с головы.

Если в конце останется подсписок, содержащий меньше `k` элементов, инвертируйте и его.

![Инвертирование каждой второй группы из k элементов](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/reverse-alternating-k.svg){: width="1000" }

## Решение

Задача следует паттерну инвертирования связанного списка на месте и очень похожа на инвертирование каждого подсписка из `k` элементов. Единственное различие состоит в том, что нужно пропускать чередующиеся группы из `k` элементов. Можно использовать тот же подход: на каждой итерации после инвертирования `k` элементов пропускать следующие `k` элементов.

## Код

Большая часть кода совпадает с решением предыдущей задачи. Вот как будет выглядеть алгоритм:

```go
package main

import "fmt"

type ListNode struct {
	Value int
	Next  *ListNode
}

func reverseAlternatingKElements(head *ListNode, k int) *ListNode {
	if head == nil || k <= 1 {
		return head
	}

	current := head
	var previous *ListNode

	for current != nil {
		lastNodeOfPreviousPart := previous
		lastNodeOfSubList := current

		for i := 0; current != nil && i < k; i++ {
			next := current.Next
			current.Next = previous
			previous = current
			current = next
		}

		if lastNodeOfPreviousPart != nil {
			lastNodeOfPreviousPart.Next = previous
		} else {
			head = previous
		}

		lastNodeOfSubList.Next = current

		if current == nil {
			break
		}

		previous = lastNodeOfSubList
		for i := 0; current != nil && i < k; i++ {
			previous = current
			current = current.Next
		}
	}

	return head
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
	head := newList(1, 2, 3, 4, 5, 6, 7, 8)
	head = reverseAlternatingKElements(head, 2)

	fmt.Print("Узлы инвертированного связанного списка: ")
	printList(head)
}
```

**Вывод:**

```text
Узлы инвертированного связанного списка: 2 1 3 4 6 5 7 8
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в связанном списке.

## Пространственная сложность

Мы использовали только постоянный объём памяти, поэтому пространственная сложность алгоритма равна $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
