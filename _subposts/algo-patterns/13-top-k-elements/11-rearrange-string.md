---
title: Перестановка строки
description: Перестановка строки — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: top-k-elements
permalink: /posts/algo-patterns-top-k-elements/rearrange-string/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Переставьте символы так, чтобы одинаковые не стояли рядом. Если это невозможно, верните пустую строку.

```text
aappp → papap
Programming → rgmrgmPiano (один из вариантов)
aapa → пустая строка
```

## Решение

Жадно выбираем наиболее частый доступный символ из max-heap. Добавляем одно его вхождение в ответ и уменьшаем частоту. Этот символ пока не возвращаем в кучу: он не должен быть выбран следующим. Только после выбора следующего символа возвращаем предыдущий, если его частота ещё положительна. Если длина результата меньше исходной, допустимой перестановки нет.

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
func rearrangeString(str string) string {
	freq := map[rune]int{}
	for _, c := range str {
		freq[c]++
	}
	h := &FrequencyHeap{}
	for c, f := range freq {
		heap.Push(h, Entry{c, f})
	}
	previous := Entry{}
	result := []rune{}
	for h.Len() > 0 {
		current := heap.Pop(h).(Entry)
		result = append(result, current.character)
		if previous.frequency > 0 {
			heap.Push(h, previous)
		}
		current.frequency--
		previous = current
	}
	if len(result) != len([]rune(str)) {
		return ""
	}
	return string(result)
}
func main() {
	fmt.Printf("%q\n", rearrangeString("aappp"))
	fmt.Printf("%q\n", rearrangeString("Programming"))
	fmt.Printf("%q\n", rearrangeString("aapa"))
}
```
{% endraw %}

**Вывод:**

```text
"papap"
"gmrPagimnor"
""
```

## Временная сложность

$$O(N\log N)$$.

## Пространственная сложность

$$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
