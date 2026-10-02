---
title: K пар с наибольшими суммами
description: K пар с наибольшими суммами — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: k-way-merge
permalink: /posts/algo-patterns-k-way-merge/k-pairs-with-largest-sums/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны два массива, отсортированных **по убыванию**. Найдите `K` пар с наибольшими суммами. Каждая пара содержит одно число из каждого массива.

```text
[9, 8, 2], [6, 3, 1], K = 3 → [9, 3], [9, 6], [8, 6]
[5, 2, 1], [2, -1], K = 3 → [5, 2], [5, -1], [2, 2]
```

## Решение

Перебираем пары и сохраняем `K` лучших в min-heap по сумме. Пока куча не заполнена, добавляем пары. Затем заменяем корень только парой с большей суммой.

Исходник использует две оптимизации. Достаточно первых `K` чисел каждого массива: более позднее число уже имеет перед собой `K` не меньших кандидатов. Во внутреннем цикле можно остановиться, когда сумма стала меньше минимума заполненной кучи: следующие числа ещё меньше. Порядок пар в ответе произволен.

## Код

{% raw %}
```go
package main

import (
	"container/heap"
	"fmt"
)

type Pair struct{ first, second int }
type PairHeap []Pair

func (h PairHeap) Len() int           { return len(h) }
func (h PairHeap) Less(i, j int) bool { return h[i].first+h[i].second < h[j].first+h[j].second }
func (h PairHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
func (h *PairHeap) Push(x any)        { *h = append(*h, x.(Pair)) }
func (h *PairHeap) Pop() any          { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }

func findKLargestPairs(nums1, nums2 []int, k int) []Pair {
	if k <= 0 {
		return nil
	}
	h := &PairHeap{}
	for i := 0; i < len(nums1) && i < k; i++ {
		for j := 0; j < len(nums2) && j < k; j++ {
			pair := Pair{nums1[i], nums2[j]}
			if h.Len() < k {
				heap.Push(h, pair)
			} else {
				smallest := (*h)[0]
				sum := pair.first + pair.second
				minSum := smallest.first + smallest.second
				if sum < minSum {
					break
				}
				if sum > minSum {
					heap.Pop(h)
					heap.Push(h, pair)
				}
			}
		}
	}
	return []Pair(*h)
}

func main() {
	fmt.Println(findKLargestPairs([]int{9, 8, 2}, []int{6, 3, 1}, 3))
	fmt.Println(findKLargestPairs([]int{5, 2, 1}, []int{2, -1}, 3))
}
```
{% endraw %}

**Вывод:**

```text
[{9 3} {9 6} {8 6}]
[{5 -1} {5 2} {2 2}]
```

## Временная сложность

Общая оценка — $$O(NM\log K)$$. С ограничением перебора — $$O(\min(N,K)\min(M,K)\log K)$$, то есть $$O(K^2\log K)$$, если оба массива содержат хотя бы `K` элементов.

## Пространственная сложность

$$O(K)$$.

{% include algo-task-nav.html position="bottom" %}
