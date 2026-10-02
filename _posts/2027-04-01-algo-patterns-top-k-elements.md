---
title: Алгосы от Влада, часть 13. Лучшие K элементов
date: 2027-04-01 00:00:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
math: true
pattern: top-k-elements
short_title: Лучшие K элементов
primary_task_title: K наибольших чисел
primary_task_anchor: top-k-numbers
---

* [Введение](/posts/algo-patterns/)
* [Скользящее окно](/posts/algo-patterns-sliding-window/)
* [Два указателя или итератор](/posts/algo-patterns-two-pointers/)
* [Быстрый и медленный указатель](/posts/algo-patterns-fast-slow-pointer/)
* [Мерж интервалов](/posts/algo-patterns-merge-intervals/)
* [Циклическая сортировка](/posts/algo-patterns-cyclic-sort/)
* [Инвертирование связанного списка на месте](/posts/algo-patterns-in-place-reversal-linked-list/)
* [Дерево BFS](/posts/algo-patterns-tree-breadth-first-search/)
* [Дерево DFS](/posts/algo-patterns-tree-depth-first-search/)
* [Две кучи](/posts/algo-patterns-two-heaps/)
* [Подмножества](/posts/algo-patterns-subsets/)
* [Модифицированный бинарный поиск](/posts/algo-patterns-modified-binary-search/)
* [Побитовый XOR](/posts/algo-patterns-bitwise-xor/)
* <b>Лучшие K элементов</b>
* [K-way merge](/posts/algo-patterns-k-way-merge/)
* [Рюкзак 0/1](/posts/algo-patterns-0-1-knapsack/)
* [Топологическая сортировка](/posts/algo-patterns-topological-sort/)

## Введение

Задачи на поиск `K` наибольших, наименьших или наиболее частых элементов объединяет один паттерн. Куча помогает сохранять нужных кандидатов и быстро находить того, кого следует заменить. В этой главе используем min-heap и max-heap, а затем добавим таблицы частот и очереди ожидания.

## K наибольших чисел {#top-k-numbers}

### Условие задачи

Дан неотсортированный массив чисел. Найдите `K` наибольших элементов.

```text
[3, 1, 5, 12, 2, 11], K = 3 → [5, 12, 11]
[5, 12, 11, -1, 12], K = 3 → [12, 11, 12]
```

### Решение

Можно отсортировать массив за $$O(N\log N)$$ и взять последние `K` чисел. Куча позволяет ограничить работу `K` кандидатами.

1. Кладём первые `K` чисел в min-heap. В корне находится наименьшее из выбранных чисел.
2. Для каждого следующего числа сравниваем его с корнем. Если оно больше, удаляем корень и вставляем новое число.
3. После обхода в куче останутся `K` наибольших чисел. Их порядок не обязан быть отсортированным.

В первом примере после первых трёх чисел корень равен `1`. Число `12` заменяет `1`, и корнем становится `3`. Число `2` пропускаем, а `11` заменяет `3`. Получаем `[5, 12, 11]`.

Чтение корня занимает $$O(1)$$, удаление и вставка — $$O(\log K)$$. Далее предполагаем `1 ≤ K ≤ N`.

![Шаг 1: сохранение трёх наибольших чисел в минимальной куче](/assets/img/posts/2027-04-01-algo-patterns-top-k-elements/top-k-step-1.svg)

![Шаг 2: сохранение трёх наибольших чисел в минимальной куче](/assets/img/posts/2027-04-01-algo-patterns-top-k-elements/top-k-step-2.svg)

![Шаг 3: сохранение трёх наибольших чисел в минимальной куче](/assets/img/posts/2027-04-01-algo-patterns-top-k-elements/top-k-step-3.svg)

![Шаг 4: сохранение трёх наибольших чисел в минимальной куче](/assets/img/posts/2027-04-01-algo-patterns-top-k-elements/top-k-step-4.svg)

### Код

{% raw %}
```go
package main

import (
	"container/heap"
	"fmt"
)

type IntHeap []int

func (h IntHeap) Len() int           { return len(h) }
func (h IntHeap) Less(i, j int) bool { return h[i] < h[j] }
func (h IntHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
func (h *IntHeap) Push(x any)        { *h = append(*h, x.(int)) }
func (h *IntHeap) Pop() any          { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }
func findKLargestNumbers(nums []int, k int) []int {
	h := &IntHeap{}
	for _, n := range nums[:k] {
		heap.Push(h, n)
	}
	for _, n := range nums[k:] {
		if n > (*h)[0] {
			heap.Pop(h)
			heap.Push(h, n)
		}
	}
	return []int(*h)
}
func main() {
	fmt.Println(findKLargestNumbers([]int{3, 1, 5, 12, 2, 11}, 3))
	fmt.Println(findKLargestNumbers([]int{5, 12, 11, -1, 12}, 3))
}
```
{% endraw %}

**Вывод:**

```text
[5 12 11]
[11 12 12]
```

### Временная сложность

$$O(K\log K+(N-K)\log K)=O(N\log K)$$. При `K = 1` выполняется линейный проход.

### Пространственная сложность

$$O(K)$$ для кучи.

## Задачи главы

1. [K наибольших чисел](#top-k-numbers)
2. [K-е наименьшее число](/posts/algo-patterns-top-k-elements/kth-smallest-number/)
3. [K ближайших точек к началу координат](/posts/algo-patterns-top-k-elements/closest-points/)
4. [Соединение верёвок](/posts/algo-patterns-top-k-elements/connect-ropes/)
5. [K наиболее частых чисел](/posts/algo-patterns-top-k-elements/top-k-frequent-numbers/)
6. [Сортировка символов по частоте](/posts/algo-patterns-top-k-elements/frequency-sort/)
7. [K-е наибольшее число в потоке](/posts/algo-patterns-top-k-elements/kth-largest-in-stream/)
8. [K ближайших чисел](/posts/algo-patterns-top-k-elements/closest-numbers/)
9. [Максимум чисел без повторений](/posts/algo-patterns-top-k-elements/maximum-distinct-elements/)
10. [Сумма между порядковыми элементами](/posts/algo-patterns-top-k-elements/sum-of-elements/)
11. [Перестановка строки](/posts/algo-patterns-top-k-elements/rearrange-string/)
12. [Одинаковые символы на расстоянии K](/posts/algo-patterns-top-k-elements/rearrange-string-k-distance-apart/)
13. [Планирование задач с паузой](/posts/algo-patterns-top-k-elements/scheduling-tasks/)
14. [Частотный стек](/posts/algo-patterns-top-k-elements/frequency-stack/)

## Похожие задания

1. Top K Frequent Elements [Leetcode](https://leetcode.com/problems/top-k-frequent-elements/)
2. Task Scheduler [Leetcode](https://leetcode.com/problems/task-scheduler/)
3. Maximum Frequency Stack [Leetcode](https://leetcode.com/problems/maximum-frequency-stack/)
