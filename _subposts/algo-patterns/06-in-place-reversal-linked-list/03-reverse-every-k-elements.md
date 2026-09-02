---
title: Инвертирование списка группами по k элементов
description: Инвертирование односвязного списка группами по k элементов.
pattern: in-place-reversal-linked-list
permalink: /posts/algo-patterns-in-place-reversal-linked-list/reverse-every-k-elements/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дана голова связанного списка и число `k`. Инвертируйте каждый подсписок из `k` элементов, начиная с головы.

Если в конце останется подсписок, содержащий меньше `k` элементов, инвертируйте и его.

![Инвертирование списка группами по k элементов](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/reverse-every-k.svg){: width="1000" }

## Решение

Задача следует паттерну инвертирования связанного списка на месте и очень похожа на инвертирование участка списка. Единственное различие состоит в том, что нужно инвертировать все подсписки. Мы можем использовать тот же подход: начать с первого подсписка, то есть с `p=1` и `q=k`, и продолжать инвертировать все подсписки размером `k`.

## Код

Большая часть кода совпадает с решением задачи об инвертировании участка списка. Вот как будет выглядеть алгоритм:

```go
package main

import "fmt"

type ListNode struct {
	Value int
	Next  *ListNode
}

func reverseEveryKElements(head *ListNode, k int) *ListNode {
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
		previous = lastNodeOfSubList
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
	head = reverseEveryKElements(head, 3)

	fmt.Print("Узлы инвертированного связанного списка: ")
	printList(head)
}
```

**Вывод:**

```text
Узлы инвертированного связанного списка: 3 2 1 6 5 4 8 7
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в связанном списке.

## Пространственная сложность

Мы использовали только постоянный объём памяти, поэтому пространственная сложность алгоритма равна $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
