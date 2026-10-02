---
title: K ближайших точек к началу координат
description: K ближайших точек к началу координат — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: top-k-elements
permalink: /posts/algo-patterns-top-k-elements/closest-points/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны точки на плоскости. Найдите `K` ближайших к началу координат.

```text
[[1, 2], [1, 3]], K = 1 → [[1, 2]]
[[1, 3], [3, 4], [2, -1]], K = 2 → [[1, 3], [2, -1]]
```

## Решение

Расстояние от `(x, y)` до начала координат равно $$\sqrt{x^2+y^2}$$. Для `(1, 2)` это $$\sqrt 5$$, для `(1, 3)` — $$\sqrt{10}$$. Сравнивать можно квадраты расстояний.

Храним `K` ближайших точек в max-heap по расстоянию. Если новая точка ближе корня, удаляем наиболее далёкого кандидата и вставляем её. Координаты в примерах достаточно малы, чтобы квадрат расстояния помещался в `int`.

## Код

{% raw %}
```go
package main

import (
	"container/heap"
	"fmt"
)

type Point struct{ X, Y int }

func (p Point) distance() int { return p.X*p.X + p.Y*p.Y }

type PointHeap []Point

func (h PointHeap) Len() int           { return len(h) }
func (h PointHeap) Less(i, j int) bool { return h[i].distance() > h[j].distance() }
func (h PointHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
func (h *PointHeap) Push(x any)        { *h = append(*h, x.(Point)) }
func (h *PointHeap) Pop() any          { old := *h; x := old[len(old)-1]; *h = old[:len(old)-1]; return x }
func findClosestPoints(points []Point, k int) []Point {
	h := &PointHeap{}
	for _, p := range points[:k] {
		heap.Push(h, p)
	}
	for _, p := range points[k:] {
		if p.distance() < (*h)[0].distance() {
			heap.Pop(h)
			heap.Push(h, p)
		}
	}
	return []Point(*h)
}
func main() {
	fmt.Println(findClosestPoints([]Point{{1, 2}, {1, 3}}, 1))
	fmt.Println(findClosestPoints([]Point{{1, 3}, {3, 4}, {2, -1}}, 2))
}
```
{% endraw %}

**Вывод:**

```text
[{1 2}]
[{1 3} {2 -1}]
```

## Временная сложность

$$O(N\log K)$$.

## Пространственная сложность

$$O(K)$$.

{% include algo-task-nav.html position="bottom" %}
