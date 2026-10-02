---
title: K-е наименьшее число в M списках
description: K-е наименьшее число в M списках — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: k-way-merge
permalink: /posts/algo-patterns-k-way-merge/kth-smallest-in-sorted-lists/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны `M` отсортированных массивов. Найдите `K`-е наименьшее число среди всех их элементов, учитывая повторы.

```text
[2, 6, 8], [3, 6, 7], [1, 3, 4], K = 5 → 4
[5, 8, 9], [1, 7], K = 3 → 7
```

## Решение

Выполняем слияние, но не сохраняем объединённый список. Вместо этого считаем извлечения из min-heap и возвращаем `K`-е значение. Так как вход представлен массивами, запись в куче хранит значение, номер массива и индекс внутри него. Это позволяет добавить следующий элемент того же массива. Предполагается, что `K` находится между `1` и общим числом элементов.

## Код

{% raw %}
```go
package main

import (
	"container/heap"
	"fmt"
)

type Entry struct{ value, arrayIndex, elementIndex int }
type EntryHeap []Entry

func (h EntryHeap) Len() int           { return len(h) }
func (h EntryHeap) Less(i, j int) bool { return h[i].value < h[j].value }
func (h EntryHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
func (h *EntryHeap) Push(x any)        { *h = append(*h, x.(Entry)) }
func (h *EntryHeap) Pop() any          { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }
func findKthSmallest(lists [][]int, k int) int {
	h := &EntryHeap{}
	for i, arr := range lists {
		if len(arr) > 0 {
			*h = append(*h, Entry{arr[0], i, 0})
		}
	}
	heap.Init(h)
	number := 0
	for count := 0; count < k; count++ {
		current := heap.Pop(h).(Entry)
		number = current.value
		next := current.elementIndex + 1
		if next < len(lists[current.arrayIndex]) {
			heap.Push(h, Entry{lists[current.arrayIndex][next], current.arrayIndex, next})
		}
	}
	return number
}

func main() {
	fmt.Println(findKthSmallest([][]int{{2, 6, 8}, {3, 6, 7}, {1, 3, 4}}, 5))
	fmt.Println(findKthSmallest([][]int{{5, 8, 9}, {1, 7}}, 3))
}
```
{% endraw %}

**Вывод:**

```text
4
7
```

## Временная сложность

Основная фаза — $$O(K\log M)$$, как в исходнике. С учётом построения кучи и просмотра входных массивов — $$O(M+K\log M)$$.

## Пространственная сложность

$$O(M)$$.

## Вариации задачи

* **Медиана M массивов.** Если суммарно `N` элементов и `N` нечётно, нужна позиция `(N+1)/2`. При чётном `N` берём среднее элементов с позициями `N/2` и `N/2+1`. Позиции здесь считаются с единицы.
* **Слияние K массивов.** Продолжаем извлечение до опустошения кучи, сохраняя каждое число в результат. Индексы массива и элемента заменяют ссылки на узлы.

{% include algo-task-nav.html position="bottom" %}
