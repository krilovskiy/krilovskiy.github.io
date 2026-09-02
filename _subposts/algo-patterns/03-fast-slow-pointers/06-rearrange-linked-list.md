---
title: Перестройка связанного списка
description: Чередование узлов первой половины списка с узлами второй половины в обратном порядке.
pattern: fast-slow-pointers
permalink: /posts/algo-patterns-fast-slow-pointer/rearrange-linked-list/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дана голова односвязного списка. Измените список так, чтобы узлы второй половины в обратном порядке чередовались с узлами первой половины. Например, список

```text
1 -> 2 -> 3 -> 4 -> 5 -> 6 -> nil
```

нужно преобразовать в

```text
1 -> 6 -> 2 -> 5 -> 3 -> 4 -> nil
```

Алгоритм не должен использовать дополнительную память и должен изменять исходный список на месте.

**Примеры:**

```text
Вход:  2 -> 4 -> 6 -> 8 -> 10 -> 12 -> nil
Выход: 2 -> 12 -> 4 -> 10 -> 6 -> 8 -> nil

Вход:  2 -> 4 -> 6 -> 8 -> 10 -> nil
Выход: 2 -> 10 -> 4 -> 8 -> 6 -> nil
```

## Решение

Задача похожа на проверку списка на палиндром:

1. Найдём средний узел быстрым и медленным указателями.
2. Инвертируем вторую половину списка.
3. Поочерёдно соединим узлы первой половины и инвертированной второй половины.
4. Установим ссылку последнего узла в `nil`, чтобы список завершался корректно.

## Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import "fmt"

type ListNode struct {
	Value int
	Next  *ListNode
}

func reorder(head *ListNode) {
	if head == nil || head.Next == nil {
		return
	}

	slow, fast := head, head
	for fast != nil && fast.Next != nil {
		slow = slow.Next
		fast = fast.Next.Next
	}

	firstHalf := head
	secondHalf := reverseList(slow)

	for firstHalf != nil && secondHalf != nil {
		nextFirst := firstHalf.Next
		firstHalf.Next = secondHalf
		firstHalf = nextFirst

		nextSecond := secondHalf.Next
		secondHalf.Next = firstHalf
		secondHalf = nextSecond
	}

	if firstHalf != nil {
		firstHalf.Next = nil
	}
}

func reverseList(head *ListNode) *ListNode {
	var previous *ListNode
	current := head

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
	for current := head; current != nil; current = current.Next {
		if current != head {
			fmt.Print(" -> ")
		}
		fmt.Print(current.Value)
	}
	fmt.Println()
}

func main() {
	even := newList(2, 4, 6, 8, 10, 12)
	reorder(even)
	printList(even)

	odd := newList(2, 4, 6, 8, 10)
	reorder(odd)
	printList(odd)
}
```

**Вывод:**

```text
2 -> 12 -> 4 -> 10 -> 6 -> 8
2 -> 10 -> 4 -> 8 -> 6
```

## Временная сложность

Поиск середины, инвертирование и слияние половин выполняются за линейное время. Общая временная сложность равна $$O(N)$$.

## Пространственная сложность

Алгоритм использует постоянный объём дополнительной памяти, поэтому пространственная сложность равна $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
