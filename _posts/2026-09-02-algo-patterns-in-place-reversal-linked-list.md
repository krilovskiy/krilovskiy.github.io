---
title: Алгосы от Влада, часть 6. Инвертирование связанного списка на месте
date: 2026-09-01 20:21:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
math: true
---


* [Введение](/posts/algo-patterns/)
* [Скользящее окно](/posts/algo-patterns-sliding-window/)
* [Два указателя или итератор](/posts/algo-patterns-two-pointers/)
* [Быстрый и медленный указатель](/posts/algo-patterns-fast-slow-pointer/)
* [Мерж интервалов](/posts/algo-patterns-merge-intervals/)
* [Циклическая сортировка](/posts/algo-patterns-cyclic-sort/)
* <b>Инвертирование связанного списка на месте</b>
* Дерево BFS
* Дерево DFS
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


## Инвертирование всего связанного списка (простой уровень)

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


## Инвертирование участка связанного списка (средний уровень)

### Условие задачи

Дана голова связанного списка и две позиции `p` и `q`. Инвертируйте участок списка от позиции `p` до позиции `q`.

![Инвертирование участка связанного списка](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/reverse-sub-list.svg){: width="800" }

### Решение

Задача следует паттерну инвертирования связанного списка на месте. Мы можем использовать подход, похожий на рассмотренный в задаче об инвертировании всего списка. Нужно выполнить следующие шаги:

1. Пропустить первые `p-1` узлов, чтобы дойти до узла в позиции `p`.
2. Запомнить узел в позиции `p-1`, чтобы позднее соединить его с инвертированным участком списка.
3. Инвертировать узлы от позиции `p` до позиции `q` тем же способом, который использовался для инвертирования всего списка.
4. Соединить узлы в позициях `p-1` и `q+1` с инвертированным участком.

### Код

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

### Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в связанном списке.

### Пространственная сложность

Мы использовали только постоянный объём памяти, поэтому пространственная сложность алгоритма равна $$O(1)$$.

### Вариации задачи

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


## Инвертирование списка группами по k элементов (средний уровень)

### Условие задачи

Дана голова связанного списка и число `k`. Инвертируйте каждый подсписок из `k` элементов, начиная с головы.

Если в конце останется подсписок, содержащий меньше `k` элементов, инвертируйте и его.

![Инвертирование списка группами по k элементов](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/reverse-every-k.svg){: width="1000" }

### Решение

Задача следует паттерну инвертирования связанного списка на месте и очень похожа на инвертирование участка списка. Единственное различие состоит в том, что нужно инвертировать все подсписки. Мы можем использовать тот же подход: начать с первого подсписка, то есть с `p=1` и `q=k`, и продолжать инвертировать все подсписки размером `k`.

### Код

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

### Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в связанном списке.

### Пространственная сложность

Мы использовали только постоянный объём памяти, поэтому пространственная сложность алгоритма равна $$O(1)$$.


## Инвертирование каждой второй группы из k элементов (средний уровень)

### Условие задачи

Дана голова связанного списка и число `k`. Инвертируйте каждый второй подсписок размером `k`, начиная с головы.

Если в конце останется подсписок, содержащий меньше `k` элементов, инвертируйте и его.

![Инвертирование каждой второй группы из k элементов](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/reverse-alternating-k.svg){: width="1000" }

### Решение

Задача следует паттерну инвертирования связанного списка на месте и очень похожа на инвертирование каждого подсписка из `k` элементов. Единственное различие состоит в том, что нужно пропускать чередующиеся группы из `k` элементов. Можно использовать тот же подход: на каждой итерации после инвертирования `k` элементов пропускать следующие `k` элементов.

### Код

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

### Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в связанном списке.

### Пространственная сложность

Мы использовали только постоянный объём памяти, поэтому пространственная сложность алгоритма равна $$O(1)$$.


## Циклический сдвиг связанного списка вправо (средний уровень)

### Условие задачи

Дана голова односвязного списка и число `k`. Выполните циклический сдвиг списка вправо на `k` узлов.

![Исходный связанный список до циклического сдвига](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/rotate-linked-list-01.svg){: width="800" }

![Связанный список после циклического сдвига](/assets/img/posts/2026-09-02-algo-patterns-in-place-reversal-linked-list/rotate-linked-list-02.svg){: width="800" }

### Решение

Циклический сдвиг можно описать и по-другому: взять подсписок из последних `k` узлов связанного списка и присоединить его к началу. Кроме того, нужно выполнить ещё три действия:

1. Соединить последний узел связанного списка с головой, поскольку после сдвига у списка будет другой хвост.
2. Новой головой связанного списка станет узел в начале переносимого подсписка.
3. Узел непосредственно перед началом переносимого подсписка станет новым хвостом сдвинутого списка.

### Код

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

### Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — общее количество узлов в связанном списке.

### Пространственная сложность

Мы использовали только постоянный объём памяти, поэтому пространственная сложность алгоритма равна $$O(1)$$.


# Похожие задания

### 6. Pattern: In-place Reversal of a LinkedList

1. Reverse a LinkedList (easy) [Leetcode](https://leetcode.com/problems/reverse-linked-list/)
2. Reverse a Sub-list (medium) [Leetcode](https://leetcode.com/problems/reverse-linked-list-ii/)
3. Reverse every K-element Sub-list (medium) [Leetcode](https://leetcode.com/problems/reverse-nodes-in-k-group/)
4. Reverse alternating K-element Sub-list (medium) [GeeksforGeeks](https://www.geeksforgeeks.org/dsa/reverse-alternate-k-nodes-in-a-singly-linked-list/)
5. Rotate a LinkedList (medium) [Leetcode](https://leetcode.com/problems/rotate-list/)
6. Swap Nodes in Pairs (medium) [Leetcode](https://leetcode.com/problems/swap-nodes-in-pairs/)
7. Reverse Nodes in Even Length Groups (medium) [Leetcode](https://leetcode.com/problems/reverse-nodes-in-even-length-groups/)
8. Reorder List (medium) [Leetcode](https://leetcode.com/problems/reorder-list/)
