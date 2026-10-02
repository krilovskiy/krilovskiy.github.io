---
title: Планирование задач с паузой
description: Планирование задач с паузой — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: top-k-elements
permalink: /posts/algo-patterns-top-k-elements/scheduling-tasks/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Сервер выполняет задачи в любом порядке. Одна задача занимает один интервал CPU, но между двумя выполнениями одинаковой задачи должно пройти `K` интервалов охлаждения. Найдите минимальное время выполнения всех задач, включая простой.

```text
[a, a, a, b, c, c], K = 2 → 7
[a, b, a], K = 3 → 5
```

## Решение

Используем max-heap по частоте. В каждом цикле выполняем до `K+1` различных задач, начиная с наиболее частой. Уменьшаем их частоты и временно помещаем в список ожидания. Затем возвращаем незавершённые задачи в кучу. Если задачи ещё остались, а цикл неполон, добавляем интервалы простоя. После последней задачи охлаждение не нужно.

Первый пример: `a → c → b → a → c → простой → a`. Второй: `a → b → простой → простой → a`.

## Код

{% raw %}
```go
package main

import (
	"container/heap"
	"fmt"
)

type Entry struct {
	character rune
	frequency int
}
type FrequencyHeap []Entry

func (h FrequencyHeap) Len() int { return len(h) }
func (h FrequencyHeap) Less(i, j int) bool {
	return h[i].frequency > h[j].frequency || h[i].frequency == h[j].frequency && h[i].character < h[j].character
}
func (h FrequencyHeap) Swap(i, j int) { h[i], h[j] = h[j], h[i] }
func (h *FrequencyHeap) Push(x any)   { *h = append(*h, x.(Entry)) }
func (h *FrequencyHeap) Pop() any     { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }
func scheduleTasks(tasks []rune, k int) int {
	freq := map[rune]int{}
	for _, c := range tasks {
		freq[c]++
	}
	h := &FrequencyHeap{}
	for c, f := range freq {
		heap.Push(h, Entry{c, f})
	}
	intervalCount := 0
	for h.Len() > 0 {
		waitList := []Entry{}
		n := k + 1
		for n > 0 && h.Len() > 0 {
			current := heap.Pop(h).(Entry)
			intervalCount++
			current.frequency--
			if current.frequency > 0 {
				waitList = append(waitList, current)
			}
			n--
		}
		for _, e := range waitList {
			heap.Push(h, e)
		}
		if h.Len() > 0 {
			intervalCount += n
		}
	}
	return intervalCount
}
func main() {
	fmt.Println(scheduleTasks([]rune("aaabcc"), 2))
	fmt.Println(scheduleTasks([]rune("aba"), 3))
}
```
{% endraw %}

**Вывод:**

```text
7
5
```

## Временная сложность

$$O(N\log N)$$: каждый шаг обработки выполняет задачу, а простой прибавляется сразу числом.

## Пространственная сложность

$$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
