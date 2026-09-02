---
title: Середина связанного списка
description: Поиск среднего узла односвязного списка за один проход.
pattern: fast-slow-pointers
permalink: /posts/algo-patterns-fast-slow-pointer/middle-of-linked-list/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дана голова односвязного списка. Верните средний узел списка. Если список содержит чётное количество узлов, верните второй из двух средних узлов.

**Примеры:**

```text
Вход:  1 -> 2 -> 3 -> 4 -> 5 -> nil
Выход: 3

Вход:  1 -> 2 -> 3 -> 4 -> 5 -> 6 -> nil
Выход: 4

Вход:  1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> nil
Выход: 4
```

## Решение

Можно сначала посчитать узлы, а затем вторым проходом дойти до середины. Быстрый и медленный указатели позволяют сделать это за один проход: быстрый указатель перемещается на два узла, а медленный — на один. Когда быстрый достигнет конца списка, медленный будет указывать на середину. При чётной длине условие цикла естественным образом оставляет медленный указатель на втором среднем узле.

## Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import "fmt"

type ListNode struct {
	Value int
	Next  *ListNode
}

func findMiddle(head *ListNode) *ListNode {
	slow, fast := head, head

	for fast != nil && fast.Next != nil {
		slow = slow.Next
		fast = fast.Next.Next
	}

	return slow
}

func main() {
	head := &ListNode{Value: 1}
	head.Next = &ListNode{Value: 2}
	head.Next.Next = &ListNode{Value: 3}
	head.Next.Next.Next = &ListNode{Value: 4}
	head.Next.Next.Next.Next = &ListNode{Value: 5}

	fmt.Println("Средний узел:", findMiddle(head).Value)

	head.Next.Next.Next.Next.Next = &ListNode{Value: 6}
	fmt.Println("Средний узел:", findMiddle(head).Value)

	head.Next.Next.Next.Next.Next.Next = &ListNode{Value: 7}
	fmt.Println("Средний узел:", findMiddle(head).Value)
}
```

**Вывод:**

```text
Средний узел: 3
Средний узел: 4
Средний узел: 4
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — количество узлов в списке.

## Пространственная сложность

Алгоритм использует постоянный объём дополнительной памяти, поэтому пространственная сложность равна $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
