---
title: Максимум чисел без повторений
description: Максимум чисел без повторений — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: top-k-elements
permalink: /posts/algo-patterns-top-k-elements/maximum-distinct-elements/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Удалите ровно `K` элементов так, чтобы осталось как можно больше чисел, встречающихся **ровно один раз**. Именно это в исходнике означает `distinct`.

```text
[7, 3, 5, 8, 5, 3, 3], K = 2 → 3
[3, 5, 12, 11, 12], K = 3 → 2
[1, 2, 3, 3, 3, 3, 4, 4, 5, 5, 5], K = 2 → 3
```

## Решение

Считаем частоты. Числа с частотой `1` сразу входят в ответ, остальные помещаем в min-heap по частоте. Чтобы сделать число одиночным, нужно удалить `frequency-1` вхождений. Сначала расходуем удаления на самые дешёвые преобразования. Если бюджета хватает, увеличиваем ответ. Если все повторы уже устранены, оставшиеся удаления уменьшают число одиночных элементов.

В первом примере можно удалить две тройки: одиночными станут `7`, `3`, `8`. Во втором удаляем один повтор `12`, затем любые два одиночных числа. В третьем удаляем одну `4` и одно вхождение `3` либо `5`: остаются три одиночных числа.

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
func findMaximumDistinctElements(nums []int, k int) int {
	if k >= len(nums) {
		return 0
	}
	freq := map[int]int{}
	for _, n := range nums {
		freq[n]++
	}
	h := &IntHeap{}
	count := 0
	for _, f := range freq {
		if f == 1 {
			count++
		} else {
			heap.Push(h, f)
		}
	}
	for k > 0 && h.Len() > 0 {
		k -= heap.Pop(h).(int) - 1
		if k >= 0 {
			count++
		}
	}
	if k > 0 {
		count -= k
	}
	return count
}
func main() {
	fmt.Println(findMaximumDistinctElements([]int{7, 3, 5, 8, 5, 3, 3}, 2))
	fmt.Println(findMaximumDistinctElements([]int{3, 5, 12, 11, 12}, 3))
	fmt.Println(findMaximumDistinctElements([]int{1, 2, 3, 3, 3, 3, 4, 4, 5, 5, 5}, 2))
}
```
{% endraw %}

**Вывод:**

```text
3
2
3
```

## Временная сложность

$$O(N\log N+K\log N)$$. В исходнике также отмечена оптимизация: сохранять только `K` кандидатов с наименьшими частотами, получая $$O(N\log K+K\log K)$$.

## Пространственная сложность

$$O(N)$$ для частот и кучи.

{% include algo-task-nav.html position="bottom" %}
