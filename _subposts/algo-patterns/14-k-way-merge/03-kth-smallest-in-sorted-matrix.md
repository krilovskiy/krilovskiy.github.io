---
title: K-е наименьшее число в матрице
description: K-е наименьшее число в матрице — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: k-way-merge
permalink: /posts/algo-patterns-k-way-merge/kth-smallest-in-sorted-matrix/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дана непустая матрица `N × N`, в которой каждая строка и каждый столбец отсортированы по возрастанию. Найдите `K`-й элемент в общем отсортированном порядке.

```text
[2, 6, 8]
[3, 7, 10]   K = 5 → 7
[5, 8, 11]
```

## Решение

Каждая строка — отдельный отсортированный список. Применяем слияние через min-heap и останавливаемся после `K` извлечений. Благодаря сортировке столбцов достаточно первых `min(K, N)` строк: начала остальных уже имеют перед собой не менее `K` не больших элементов.

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
func findKthSmallest(matrix [][]int, k int) int {
	n := len(matrix)
	h := &EntryHeap{}
	for i := 0; i < n && i < k; i++ {
		*h = append(*h, Entry{matrix[i][0], i, 0})
	}
	heap.Init(h)
	number := 0
	for count := 0; count < k; count++ {
		current := heap.Pop(h).(Entry)
		number = current.value
		next := current.elementIndex + 1
		if next < n {
			heap.Push(h, Entry{matrix[current.arrayIndex][next], current.arrayIndex, next})
		}
	}
	return number
}

func main() {
	fmt.Println(findKthSmallest([][]int{{1, 4}, {2, 5}}, 2))
	fmt.Println(findKthSmallest([][]int{{-5}}, 1))
	fmt.Println(findKthSmallest([][]int{{2, 6, 8}, {3, 7, 10}, {5, 8, 11}}, 5))
	fmt.Println(findKthSmallest([][]int{{1, 5, 9}, {10, 11, 13}, {12, 13, 15}}, 8))
}
```
{% endraw %}

**Вывод:**

```text
2
-5
7
13
```

## Временная сложность

$$O(\min(K,N)+K\log N)$$.

## Пространственная сложность

$$O(N)$$ в худшем случае.

## Альтернативное решение: бинарный поиск по значениям

Ищем не индекс, а число в диапазоне от верхнего левого до нижнего правого элемента. Середина диапазона может отсутствовать в матрице.

Для `mid` считаем элементы `≤ mid`. Начинаем в левом нижнем углу: если значение больше `mid`, идём вверх; иначе все элементы над ним в этом столбце подходят, прибавляем `row+1` и идём вправо. Заодно сохраняем наибольшее значение `≤ mid` и наименьшее значение `> mid`.

Если количество равно `K`, возвращаем наибольшее значение `≤ mid`. Если меньше — поднимаем нижнюю границу до наименьшего `> mid`; если больше — опускаем верхнюю до наибольшего `≤ mid`. В исходном описании имена двух границ местами перепутаны; здесь порядок соответствует его коду.

![Бинарный поиск пятого элемента матрицы по диапазону значений, шаг 1](/assets/img/posts/2027-05-01-algo-patterns-k-way-merge/matrix-01.svg)

В примере `mid=6` даёт четыре элемента: нижняя граница становится `7`. Затем `mid=9` даёт семь элементов, верхняя граница становится `8`. При `mid=7` получаем пять элементов и ответ `7`.

{% raw %}
```go
package main

import (
	"fmt"
)

func findKthSmallest(matrix [][]int, k int) int {
	n := len(matrix)
	start, end := matrix[0][0], matrix[n-1][n-1]
	for start < end {
		mid := start + (end-start)/2
		smallLargePair := [2]int{matrix[0][0], matrix[n-1][n-1]}
		count := countLessEqual(matrix, mid, &smallLargePair)
		if count == k {
			return smallLargePair[0]
		}
		if count < k {
			start = smallLargePair[1]
		} else {
			end = smallLargePair[0]
		}
	}
	return start
}
func countLessEqual(matrix [][]int, mid int, smallLargePair *[2]int) int {
	n := len(matrix)
	count, row, col := 0, n-1, 0
	for row >= 0 && col < n {
		value := matrix[row][col]
		if value > mid {
			if value < smallLargePair[1] {
				smallLargePair[1] = value
			}
			row--
		} else {
			if value > smallLargePair[0] {
				smallLargePair[0] = value
			}
			count += row + 1
			col++
		}
	}
	return count
}

func main() {
	fmt.Println(findKthSmallest([][]int{{1, 4}, {2, 5}}, 2))
	fmt.Println(findKthSmallest([][]int{{-5}}, 1))
	fmt.Println(findKthSmallest([][]int{{2, 6, 8}, {3, 7, 10}, {5, 8, 11}}, 5))
	fmt.Println(findKthSmallest([][]int{{1, 5, 9}, {10, 11, 13}, {12, 13, 15}}, 8))
}
```
{% endraw %}

**Вывод:**

```text
2
-5
7
13
```

Время — $$O(N\log(\max-\min))$$ при ненулевом диапазоне, память — $$O(1)$$. Если минимум равен максимуму, ответ возвращается сразу.

{% include algo-task-nav.html position="bottom" %}
