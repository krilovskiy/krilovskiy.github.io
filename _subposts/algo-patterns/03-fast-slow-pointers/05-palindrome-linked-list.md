---
title: Связанный список — палиндром
description: Проверка односвязного списка на палиндром с восстановлением исходного порядка узлов.
pattern: fast-slow-pointers
permalink: /posts/algo-patterns-fast-slow-pointer/palindrome-linked-list/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дана голова односвязного списка. Определите, является ли список палиндромом. Алгоритм должен работать за $$O(N)$$ времени и использовать постоянный объём дополнительной памяти. После завершения алгоритма список необходимо вернуть в исходное состояние.

**Пример 1:**

```text
Вход:  2 -> 4 -> 6 -> 4 -> 2 -> nil
Выход: true
```

**Пример 2:**

```text
Вход:  2 -> 4 -> 6 -> 4 -> 2 -> 2 -> nil
Выход: false
```

## Решение

Значения в списке-палиндроме одинаково читаются слева направо и справа налево. В односвязном списке нельзя двигаться назад, поэтому выполним четыре шага:

1. Найдём середину списка быстрым и медленным указателями.
2. Инвертируем вторую половину списка.
3. Сравним первую половину с инвертированной второй половиной.
4. Ещё раз инвертируем вторую половину, чтобы восстановить исходный список.

## Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import "fmt"

type ListNode struct {
	Value int
	Next  *ListNode
}

func isPalindrome(head *ListNode) bool {
	if head == nil || head.Next == nil {
		return true
	}

	slow, fast := head, head
	for fast != nil && fast.Next != nil {
		slow = slow.Next
		fast = fast.Next.Next
	}

	secondHalf := reverseList(slow)
	secondHalfCopy := secondHalf
	firstHalf := head
	palindrome := true

	for secondHalf != nil {
		if firstHalf.Value != secondHalf.Value {
			palindrome = false
			break
		}
		firstHalf = firstHalf.Next
		secondHalf = secondHalf.Next
	}

	reverseList(secondHalfCopy)
	return palindrome
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
	first := newList(2, 4, 6, 4, 2)
	fmt.Println("Палиндром:", isPalindrome(first))
	printList(first)

	second := newList(2, 4, 6, 4, 2, 2)
	fmt.Println("Палиндром:", isPalindrome(second))
	printList(second)
}
```

**Вывод:**

```text
Палиндром: true
2 -> 4 -> 6 -> 4 -> 2
Палиндром: false
2 -> 4 -> 6 -> 4 -> 2 -> 2
```

Повторная печать списков показывает, что после проверки их исходный порядок восстановлен.

## Временная сложность

Поиск середины, инвертирование, сравнение и восстановление выполняются за линейное время. Общая временная сложность равна $$O(N)$$.

## Пространственная сложность

Алгоритм использует постоянный объём дополнительной памяти, поэтому пространственная сложность равна $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
