---
title: Алгосы от Влада, часть 3. Быстрый и медленный указатель
date: 2024-02-01 20:21:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
math: true
---


* [Введение](/posts/algo-patterns/)
* [Скользящее окно](/posts/algo-patterns-sliding-window/)
* [Два указателя или итератор](/posts/algo-patterns-two-pointers/)
* <b>Быстрый и медленный указатель</b>
* Мерж интервалов
* Циклическая сортировка
* Инвертирование связанного списка на месте
* Дерево BFS
* Дерево DFS
* Две кучи
* Подмножества
* Модифицированный бинарный поиск
* Побитовый XOR
* Лучшие элементы К (top K elements)
* k-образный алгоритм слияния (K-Way merge)
* 0 or 1 Knapsack (Динамическое программирование)
* Топологическая сортировки


## Введение
Подход с использованием указателей <b>Fast & Slow</b>, также известный как <b>алгоритм "заяц и черепаха"</b>s, - это 
алгоритм с использованием двух указателей, которые перемещаются по массиву (или последовательности/LinkedList) 
с разной скоростью. Этот подход весьма полезен при работе с циклическими LinkedList'ами или массивами.


Двигаясь с разной скоростью (скажем, в циклическом LinkedList), алгоритм доказывает, 
что два указателя обязательно встретятся. Быстрый указатель должен догнать медленный, 
как только оба указателя окажутся в замкнутом цикле.


Одной из известных задач, решенных с помощью этой техники, был <b>"Поиск цикла в LinkedList"</b>. 
Давайте рассмотрим эту задачу, чтобы понять принцип <b>Fast & Slow</b>.

# Постановка задачи
Задав голову односвязного списка LinkedList, напишите функцию, определяющую, есть ли в LinkedList цикл или нет.

![Desktop View](/assets/img/posts/2024-02-01-algo-patterns-fast-slow-pointer/cyclic-loop.svg){: width="700" height="400" }

## Решение
Представьте себе двух гонщиков, бегущих по круговой гоночной трассе. Если один гонщик быстрее другого, 
то он обязательно догонит и обойдет медленного гонщика сзади. Мы можем использовать этот факт,
чтобы разработать алгоритм для определения того, есть ли в LinkedList цикл или нет.

Представьте, что у нас есть медленный и быстрый указатели для обхода LinkedList. 
На каждой итерации медленный указатель перемещается на один шаг, а быстрый - на два. Это дает нам два вывода:
1. Если в LinkedList нет циклов, то быстрый указатель достигнет конца LinkedList раньше медленного указателя и покажет, что в LinkedList нет циклов.
2. Медленный указатель никогда не сможет догнать быстрый указатель, если в LinkedList нет цикла.


Если LinkedList имеет цикл, то сначала в цикл попадает быстрый указатель, а затем медленный. 
После этого оба указателя будут двигаться по циклу бесконечно. 
Если на каком-то этапе оба указателя встретятся, можно сделать вывод, что в LinkedList есть цикл. 
Давайте проанализируем, возможна ли встреча двух указателей. Когда быстрый указатель приближается к медленному сзади, 
у нас есть две возможности:
1. Быстрый указатель отстает от медленного на один шаг.
2. Быстрый указатель отстает от медленного на два шага.

Все остальные расстояния между быстрым и медленным указателями будут сводиться к одной из этих двух возможностей. 
Давайте проанализируем эти сценарии, считая, что быстрый указатель всегда перемещается первым:
1. <b>Если быстрый указатель отстает от медленного на один шаг</b>: Быстрый указатель перемещается на два шага, 
а медленный - на один, и они оба встречаются.
2. <b>Если быстрый указатель отстает от медленного на два шага</b>: Быстрый указатель перемещается на два шага, 
а медленный - на один. После этих перемещений быстрый указатель будет отставать от медленного на один шаг, 
что сводит этот сценарий к первому сценарию. Это означает, что два указателя встретятся на следующей итерации.
Отсюда следует вывод, что два указателя обязательно встретятся, если LinkedList имеет цикл. 
Аналогичный анализ можно провести и в случае, когда медленный указатель движется первым. 
Вот визуальное представление вышеприведенного обсуждения:

![Desktop View](/assets/img/posts/2024-02-01-algo-patterns-fast-slow-pointer/loop-v2.svg){: width="700" height="400" }

## Код 
Вот как будет выглядеть наш алгоритм:

```go
package main

import "fmt"

type Node struct {
  Value int
  Next  *Node
}

func hasCycle(head *Node) bool {
  slow, fast := head, head
  for fast != nil && fast.Next != nil {
    fast = fast.Next.Next
    slow = slow.Next
    if slow == fast {
      return true // found the cycle
    }
  }
  return false
}

func main() {
  head := &Node{Value: 1}
  head.Next = &Node{Value: 2}
  head.Next.Next = &Node{Value: 3}
  head.Next.Next.Next = &Node{Value: 4}
  head.Next.Next.Next.Next = &Node{Value: 5}
  head.Next.Next.Next.Next.Next = &Node{Value: 6}
  
  fmt.Printf("LinkedList has cycle: %t\n", hasCycle(head))
  
  head.Next.Next.Next.Next.Next.Next = head.Next.Next
  fmt.Printf("LinkedList has cycle: %t\n", hasCycle(head))
  
  head.Next.Next.Next.Next.Next.Next = head.Next.Next.Next
  fmt.Printf("LinkedList has cycle: %t\n", hasCycle(head))
}
```

[Вывод](https://go.dev/play/p/dbfMk7fxoHK)  :
```
LinkedList has cycle: false
LinkedList has cycle: true
LinkedList has cycle: true
```

## Временная сложность 
Как мы выяснили выше, как только медленный указатель войдет в цикл, 
быстрый указатель встретится с медленным указателем в том же цикле. 
Поэтому временная сложность нашего алгоритма будет равна $$O(N)$$ где $$N$$ - общее количество узлов в LinkedList.

## Пространственная сложность 
Алгоритм работает в постоянном пространстве $$O(1)$$.

# Похожие задания
### 2. Pattern: Fast & Slow pointers

1. Introduction [emre.me](https://emre.me/coding-patterns/fast-slow-pointers/)
2. LinkedList Cycle (easy) [Leetcode](https://leetcode.com/problems/linked-list-cycle/)
3. Start of LinkedList Cycle (medium) [Leetcode](https://leetcode.com/problems/linked-list-cycle-ii/)
4. Happy Number (medium) [Leetcode](https://leetcode.com/problems/happy-number/)
5. Middle of the LinkedList (easy) [Leetcode](https://leetcode.com/problems/middle-of-the-linked-list/)
6. Problem Challenge 1: Palindrome LinkedList (medium) [Leetcode](https://leetcode.com/problems/palindrome-linked-list/)
7. Problem Challenge 2: Rearrange a LinkedList (medium) [Leetcode](https://leetcode.com/problems/reorder-list/)
8. Problem Challenge 3: Cycle in a Circular Array (hard) [Leetcode](https://leetcode.com/problems/circular-array-loop/)
