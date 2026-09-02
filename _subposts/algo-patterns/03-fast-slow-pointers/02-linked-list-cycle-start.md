---
title: Начало цикла в связанном списке
description: Поиск узла, с которого начинается цикл в односвязном списке.
pattern: fast-slow-pointers
permalink: /posts/algo-patterns-fast-slow-pointer/linked-list-cycle-start/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дана голова односвязного списка, содержащего цикл. Напишите функцию, которая находит начальный узел цикла.

## Решение

Если известна длина цикла, его начало можно найти с помощью двух указателей:

1. Сначала обнаружим цикл быстрым и медленным указателями. После их встречи обойдём цикл ещё раз и посчитаем его длину `k`.
2. Установим два новых указателя на голову списка и передвинем второй на `k` узлов вперёд.
3. Будем перемещать оба указателя на один узел за шаг. Когда они встретятся, второй указатель успеет пройти внутри цикла ровно один дополнительный круг, поэтому точка встречи будет началом цикла.

## Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import "fmt"

type ListNode struct {
	Value int
	Next  *ListNode
}

func findCycleStart(head *ListNode) *ListNode {
	slow, fast := head, head

	for fast != nil && fast.Next != nil {
		slow = slow.Next
		fast = fast.Next.Next

		if slow == fast {
			cycleLength := calculateCycleLength(slow)
			return findStart(head, cycleLength)
		}
	}

	return nil
}

func calculateCycleLength(node *ListNode) int {
	current := node.Next
	cycleLength := 1

	for current != node {
		current = current.Next
		cycleLength++
	}

	return cycleLength
}

func findStart(head *ListNode, cycleLength int) *ListNode {
	pointer1, pointer2 := head, head

	for i := 0; i < cycleLength; i++ {
		pointer2 = pointer2.Next
	}

	for pointer1 != pointer2 {
		pointer1 = pointer1.Next
		pointer2 = pointer2.Next
	}

	return pointer1
}

func main() {
	head := &ListNode{Value: 1}
	head.Next = &ListNode{Value: 2}
	head.Next.Next = &ListNode{Value: 3}
	head.Next.Next.Next = &ListNode{Value: 4}
	head.Next.Next.Next.Next = &ListNode{Value: 5}
	head.Next.Next.Next.Next.Next = &ListNode{Value: 6}
	tail := head.Next.Next.Next.Next.Next

	tail.Next = head.Next.Next
	fmt.Println("Начало цикла:", findCycleStart(head).Value)

	tail.Next = head.Next.Next.Next
	fmt.Println("Начало цикла:", findCycleStart(head).Value)

	tail.Next = head
	fmt.Println("Начало цикла:", findCycleStart(head).Value)
}
```

**Вывод:**

```text
Начало цикла: 3
Начало цикла: 4
Начало цикла: 1
```

## Временная сложность

Обнаружение цикла, вычисление его длины и поиск начального узла требуют линейного времени. Общая временная сложность равна $$O(N)$$, где $$N$$ — количество узлов в списке.

## Пространственная сложность

Алгоритм использует постоянный объём дополнительной памяти, поэтому пространственная сложность равна $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
