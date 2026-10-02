---
title: Сортировка символов по частоте
description: Сортировка символов по частоте — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: top-k-elements
permalink: /posts/algo-patterns-top-k-elements/frequency-sort/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Отсортируйте символы строки по убыванию частоты. Порядок символов с одинаковой частотой произволен.

```text
Programming → rrggmmPiano
abcbab → bbbaac
```

## Решение

Считаем частоты символов и помещаем пары «символ, частота» в max-heap. Извлекаем самый частый символ и дописываем все его вхождения в результат. Затем переходим к следующему. В Go перебираем строку как последовательность `rune`.

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
func sortCharacterByFrequency(str string) string {
	freq := map[rune]int{}
	for _, c := range str {
		freq[c]++
	}
	h := &FrequencyHeap{}
	for c, f := range freq {
		heap.Push(h, Entry{c, f})
	}
	result := []rune{}
	for h.Len() > 0 {
		e := heap.Pop(h).(Entry)
		for i := 0; i < e.frequency; i++ {
			result = append(result, e.character)
		}
	}
	return string(result)
}
func main() {
	fmt.Println(sortCharacterByFrequency("Programming"))
	fmt.Println(sortCharacterByFrequency("abcbab"))
}
```
{% endraw %}

**Вывод:**

```text
ggmmrrPaino
bbbaac
```

## Временная сложность

Работа с кучей требует $$O(D\log D)$$, где $$D$$ — число различных символов. С учётом подсчёта частот и записи результата — $$O(N+D\log D)$$; в худшем случае $$O(N\log N)$$.

## Пространственная сложность

$$O(N)$$ с учётом результата.

{% include algo-task-nav.html position="bottom" %}
