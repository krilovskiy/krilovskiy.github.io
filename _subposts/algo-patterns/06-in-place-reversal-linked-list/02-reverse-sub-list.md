---
title: Инвертирование участка связанного списка
description: Инвертирование участка односвязного списка между позициями p и q.
subpost_type: algo-task
series: algo-patterns
pattern: in-place-reversal-linked-list
parent_title: Инвертирование связанного списка на месте
parent_url: /posts/algo-patterns-in-place-reversal-linked-list/
order: 2
total_tasks: 5
permalink: /posts/algo-patterns-in-place-reversal-linked-list/reverse-sub-list/
previous_task_title: Инвертирование всего связанного списка
previous_task_url: /posts/algo-patterns-in-place-reversal-linked-list/#reverse-linked-list
next_task_title: Инвертирование списка группами по k элементов
next_task_url: /posts/algo-patterns-in-place-reversal-linked-list/reverse-every-k-elements/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дана голова связанного списка и две позиции `p` и `q`. Инвертируйте участок списка от позиции `p` до позиции `q`.

![Инвертирование участка связанного списка](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/reverse-sub-list.svg){: width="800" }

## Решение

Задача следует паттерну инвертирования связанного списка на месте. Мы можем использовать подход, похожий на рассмотренный в задаче об инвертировании всего списка. Нужно выполнить следующие шаги:

1. Пропустить первые `p-1` узлов, чтобы дойти до узла в позиции `p`.
2. Запомнить узел в позиции `p-1`, чтобы позднее соединить его с инвертированным участком списка.
3. Инвертировать узлы от позиции `p` до позиции `q` тем же способом, который использовался для инвертирования всего списка.
4. Соединить узлы в позициях `p-1` и `q+1` с инвертированным участком.

## Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import "fmt"

type ListNode struct {
	Value int
	Next  *ListNode
}

func reverseSubList(head *ListNode, p, q int) *ListNode {
	if head == nil || p == q {
		return head
	}

	current := head
	var previous *ListNode

	for i := 0; current != nil && i < p-1; i++ {
		previous = current
		current = current.Next
	}

	if current == nil {
		return head
	}

	lastNodeOfFirstPart := previous
	lastNodeOfSubList := current

	for i := 0; current != nil && i < q-p+1; i++ {
		next := current.Next
		current.Next = previous
		previous = current
		current = next
	}

	if lastNodeOfFirstPart != nil {
		lastNodeOfFirstPart.Next = previous
	} else {
		head = previous
	}

	lastNodeOfSubList.Next = current
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
	head := newList(1, 2, 3, 4, 5)
	head = reverseSubList(head, 2, 4)

	fmt.Print("Узлы инвертированного связанного списка: ")
	printList(head)
}
```

**Вывод:**

```text
Узлы инвертированного связанного списка: 1 4 3 2 5
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в связанном списке.

## Пространственная сложность

Мы использовали только постоянный объём памяти, поэтому пространственная сложность алгоритма равна $$O(1)$$.

## Вариации задачи

**Задача 1:** инвертируйте первые `k` элементов заданного связанного списка.

**Решение:** эту задачу легко свести к исходной. Чтобы инвертировать первые `k` узлов списка, нужно передать `p=1` и `q=k`.

**Задача 2:** дан связанный список из `n` узлов. Инвертируйте его в зависимости от размера следующим образом:

- Если `n` чётно, инвертируйте список группами по `n/2` узлов.
- Если `n` нечётно, оставьте средний узел на месте, инвертируйте первые `n/2` узлов и последние `n/2` узлов.

**Решение:** если `n` чётно, можно выполнить следующие шаги:

- Инвертировать первые `n/2` узлов: `head = reverseSubList(head, 1, n/2)`.
- Инвертировать последние `n/2` узлов: `head = reverseSubList(head, n/2+1, n)`.

Если `n` нечётно, алгоритм будет выглядеть так:

- `head = reverseSubList(head, 1, n/2)`.
- `head = reverseSubList(head, n/2+2, n)`.

Обратите внимание на вызов функции на втором шаге. Мы пропускаем две позиции, поскольку средний элемент должен остаться на месте.

{% include algo-task-nav.html position="bottom" %}
