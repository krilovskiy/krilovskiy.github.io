---
title: Циклический сдвиг связанного списка вправо
description: Циклический сдвиг односвязного списка вправо на k узлов.
pattern: in-place-reversal-linked-list
permalink: /posts/algo-patterns-in-place-reversal-linked-list/rotate-linked-list/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дана голова односвязного списка и число `k`. Выполните циклический сдвиг списка вправо на `k` узлов.

![Исходный связанный список до циклического сдвига](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/rotate-linked-list-01.svg){: width="800" }

![Связанный список после циклического сдвига](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/rotate-linked-list-02.svg){: width="800" }

## Решение

Циклический сдвиг можно описать и по-другому: взять подсписок из последних `k` узлов связанного списка и присоединить его к началу. Кроме того, нужно выполнить ещё три действия:

1. Соединить последний узел связанного списка с головой, поскольку после сдвига у списка будет другой хвост.
2. Новой головой связанного списка станет узел в начале переносимого подсписка.
3. Узел непосредственно перед началом переносимого подсписка станет новым хвостом сдвинутого списка.

## Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import "fmt"

type ListNode struct {
	Value int
	Next  *ListNode
}

func rotate(head *ListNode, k int) *ListNode {
	if head == nil || head.Next == nil || k <= 0 {
		return head
	}

	lastNode := head
	listLength := 1
	for lastNode.Next != nil {
		lastNode = lastNode.Next
		listLength++
	}

	rotations := k % listLength
	if rotations == 0 {
		return head
	}

	lastNode.Next = head
	nodesToSkip := listLength - rotations
	newTail := head

	for i := 0; i < nodesToSkip-1; i++ {
		newTail = newTail.Next
	}

	newHead := newTail.Next
	newTail.Next = nil
	return newHead
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
	head := newList(1, 2, 3, 4, 5, 6)
	head = rotate(head, 3)

	fmt.Print("Узлы сдвинутого связанного списка: ")
	printList(head)
}
```

**Вывод:**

```text
Узлы сдвинутого связанного списка: 4 5 6 1 2 3
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в связанном списке.

## Пространственная сложность

Мы использовали только постоянный объём памяти, поэтому пространственная сложность алгоритма равна $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
