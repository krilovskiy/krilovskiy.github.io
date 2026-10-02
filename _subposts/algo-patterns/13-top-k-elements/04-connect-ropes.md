---
title: Соединение верёвок
description: Соединение верёвок — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: top-k-elements
permalink: /posts/algo-patterns-top-k-elements/connect-ropes/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Нужно соединить `N` верёвок в одну с минимальной суммарной стоимостью. Соединение двух верёвок стоит сумму их длин.

```text
[1, 3, 11, 5] → 33
[3, 4, 5, 6] → 36
[1, 3, 11, 5, 2] → 42
```

## Решение

Жадно соединяем две самые короткие верёвки. Для этого храним длины в min-heap: извлекаем две минимальные длины, прибавляем их сумму к стоимости и возвращаем полученную верёвку в кучу. Повторяем, пока не останется одна верёвка.

В первом примере соединения стоят `1+3=4`, `4+5=9`, `9+11=20`; всего `33`. Во втором — `7+11+18=36`, в третьем — `3+6+11+22=42`.

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
func (h IntHeap) Less(i, j int) bool { return h[i] < h[j] }
func (h IntHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
func (h *IntHeap) Push(x any)        { *h = append(*h, x.(int)) }
func (h *IntHeap) Pop() any          { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }
func minimumCostToConnectRopes(ropeLengths []int) int {
	h := &IntHeap{}
	for _, n := range ropeLengths {
		heap.Push(h, n)
	}
	result := 0
	for h.Len() > 1 {
		cost := heap.Pop(h).(int) + heap.Pop(h).(int)
		result += cost
		heap.Push(h, cost)
	}
	return result
}
func main() {
	fmt.Println(minimumCostToConnectRopes([]int{1, 3, 11, 5}))
	fmt.Println(minimumCostToConnectRopes([]int{3, 4, 5, 6}))
	fmt.Println(minimumCostToConnectRopes([]int{1, 3, 11, 5, 2}))
}
```
{% endraw %}

**Вывод:**

```text
33
36
42
```

## Временная сложность

$$O(N\log N)$$: каждое соединение уменьшает число верёвок на одну.

## Пространственная сложность

$$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
