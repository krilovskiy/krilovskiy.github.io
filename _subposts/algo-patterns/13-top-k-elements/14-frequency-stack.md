---
title: Частотный стек
description: Частотный стек — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: top-k-elements
permalink: /posts/algo-patterns-top-k-elements/frequency-stack/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Реализуйте `push(num)` и `pop()`. Удаление возвращает самое частое число, а при равенстве частот — добавленное позже.

```text
push(1), push(2), push(3), push(2), push(1), push(2), push(5)
pop() → 2
pop() → 1
pop() → 2
```

## Решение

Хеш-таблица хранит текущую частоту каждого числа. В max-heap помещаем отдельную запись для каждого добавления: значение, частоту на момент добавления и порядковый номер. Сначала сравниваем частоты, затем порядковые номера.

При `push` увеличиваем частоту и создаём запись. При `pop` извлекаем корень и уменьшаем частоту его числа. Старые записи отражают предыдущие добавления и станут актуальны по мере удаления более новых. Как у обычного стека, `pop` вызывается только для непустой структуры.

## Код

{% raw %}
```go
package main

import (
	"container/heap"
	"fmt"
)

type Element struct{ number, frequency, sequenceNumber int }
type ElementHeap []Element

func (h ElementHeap) Len() int { return len(h) }
func (h ElementHeap) Less(i, j int) bool {
	return h[i].frequency > h[j].frequency || h[i].frequency == h[j].frequency && h[i].sequenceNumber > h[j].sequenceNumber
}
func (h ElementHeap) Swap(i, j int) { h[i], h[j] = h[j], h[i] }
func (h *ElementHeap) Push(x any)   { *h = append(*h, x.(Element)) }
func (h *ElementHeap) Pop() any     { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }

type FrequencyStack struct {
	maxHeap        ElementHeap
	frequencyMap   map[int]int
	sequenceNumber int
}

func (s *FrequencyStack) push(num int) {
	if s.frequencyMap == nil {
		s.frequencyMap = map[int]int{}
	}
	s.frequencyMap[num]++
	heap.Push(&s.maxHeap, Element{num, s.frequencyMap[num], s.sequenceNumber})
	s.sequenceNumber++
}
func (s *FrequencyStack) pop() int {
	element := heap.Pop(&s.maxHeap).(Element)
	s.frequencyMap[element.number]--
	if s.frequencyMap[element.number] == 0 {
		delete(s.frequencyMap, element.number)
	}
	return element.number
}

func main() {
	s := &FrequencyStack{}
	for _, n := range []int{1, 2, 3, 2, 1, 2, 5} {
		s.push(n)
	}
	fmt.Println(s.pop())
	fmt.Println(s.pop())
	fmt.Println(s.pop())
}
```
{% endraw %}

**Вывод:**

```text
2
1
2
```

## Временная сложность

`push` и `pop` — $$O(\log N)$$, где $$N$$ — текущее число элементов.

## Пространственная сложность

$$O(N)$$ для кучи и таблицы.

{% include algo-task-nav.html position="bottom" %}
