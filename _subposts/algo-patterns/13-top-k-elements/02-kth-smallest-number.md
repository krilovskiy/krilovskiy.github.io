---
title: K-е наименьшее число
description: K-е наименьшее число — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: top-k-elements
permalink: /posts/algo-patterns-top-k-elements/kth-smallest-number/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Найдите `K`-е число в порядке возрастания в неотсортированном массиве. Повторения учитываются: речь не о `K`-м различном числе.

```text
[1, 5, 12, 2, 11, 5], K = 3 → 5
[1, 5, 12, 2, 11, 5], K = 4 → 5
[5, 12, 11, -1, 12], K = 3 → 11
```

## Решение

Теперь сохраняем `K` наименьших чисел в max-heap. Корень — наибольшее среди них. Если очередное число меньше корня, заменяем корень. После обхода корень и будет `K`-м наименьшим числом.

## Код

{% raw %}
```go
package main

import (
	"container/heap"
	"fmt"
)

type IntHeap []int

func (h IntHeap) Len() int           { return len(h) }
func (h IntHeap) Less(i, j int) bool { return h[i] > h[j] }
func (h IntHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
func (h *IntHeap) Push(x any)        { *h = append(*h, x.(int)) }
func (h *IntHeap) Pop() any          { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }
func findKthSmallestNumber(nums []int, k int) int {
	h := &IntHeap{}
	for _, n := range nums[:k] {
		heap.Push(h, n)
	}
	for _, n := range nums[k:] {
		if n < (*h)[0] {
			heap.Pop(h)
			heap.Push(h, n)
		}
	}
	return (*h)[0]
}
func main() {
	fmt.Println(findKthSmallestNumber([]int{1, 5, 12, 2, 11, 5}, 3))
	fmt.Println(findKthSmallestNumber([]int{1, 5, 12, 2, 11, 5}, 4))
	fmt.Println(findKthSmallestNumber([]int{5, 12, 11, -1, 12}, 3))
}
```
{% endraw %}

**Вывод:**

```text
5
5
11
```

## Временная сложность

$$O(N\log K)$$; при `K = 1` — $$O(N)$$.

## Пространственная сложность

$$O(K)$$.

## Альтернативный подход

Можно построить min-heap из всех чисел за $$O(N)$$, затем извлечь `K` элементов. Последнее извлечённое число — ответ. Время составит $$O(N+K\log N)$$, память — $$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
