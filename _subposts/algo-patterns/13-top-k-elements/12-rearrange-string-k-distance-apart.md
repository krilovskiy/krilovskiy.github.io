---
title: Одинаковые символы на расстоянии K
description: Одинаковые символы на расстоянии K — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: top-k-elements
permalink: /posts/algo-patterns-top-k-elements/rearrange-string-k-distance-apart/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Переставьте строку так, чтобы расстояние между одинаковыми символами было не меньше `K`. При невозможности верните пустую строку.

```text
mmpp, K = 2 → mpmp или pmpm
Programming, K = 3 → rgmPrgmiano (один из вариантов)
aab, K = 2 → aba
aappa, K = 3 → пустая строка
```

## Решение

Это обобщение предыдущей задачи, где расстояние равнялось `2`. Символ возвращается в max-heap только после `K` шагов. Для ожидания используем очередь: после выбора символа уменьшаем частоту и добавляем его в конец очереди. Когда её размер достигает `K`, извлекаем самый старый элемент и возвращаем в кучу, если у него остались вхождения.

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
func reorganizeString(str string, k int) string {
	if k <= 1 {
		return str
	}
	freq := map[rune]int{}
	for _, c := range str {
		freq[c]++
	}
	h := &FrequencyHeap{}
	for c, f := range freq {
		heap.Push(h, Entry{c, f})
	}
	queue := []Entry{}
	result := []rune{}
	for h.Len() > 0 {
		current := heap.Pop(h).(Entry)
		result = append(result, current.character)
		current.frequency--
		queue = append(queue, current)
		if len(queue) >= k {
			previous := queue[0]
			queue = queue[1:]
			if previous.frequency > 0 {
				heap.Push(h, previous)
			}
		}
	}
	if len(result) != len([]rune(str)) {
		return ""
	}
	return string(result)
}
func main() {
	fmt.Printf("%q\n", reorganizeString("mmpp", 2))
	fmt.Printf("%q\n", reorganizeString("Programming", 3))
	fmt.Printf("%q\n", reorganizeString("aab", 2))
	fmt.Printf("%q\n", reorganizeString("aappa", 3))
}
```
{% endraw %}

**Вывод:**

```text
"mpmp"
"gmrPagimnor"
"aba"
""
```

## Временная сложность

$$O(N\log N)$$.

## Пространственная сложность

$$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
