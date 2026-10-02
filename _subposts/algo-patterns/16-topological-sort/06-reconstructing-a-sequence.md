---
title: Однозначное восстановление последовательности
description: Однозначное восстановление последовательности — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: topological-sort
permalink: /posts/algo-patterns-topological-sort/reconstructing-a-sequence/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны исходная последовательность различных чисел `originalSeq` и набор последовательностей. Проверьте, является ли `originalSeq` **единственной** последовательностью, в которую каждая заданная последовательность входит как подпоследовательность.

```text
[1,2,3,4], [[1,2], [2,3], [3,4]] → true
[1,2,3,4], [[1,2], [2,3], [2,4]] → false
[3,1,4,2,5], [[3,1,5], [1,4,2,5]] → true
```

Во втором примере возможны как `[1,2,3,4]`, так и `[1,2,4,3]`.

## Решение

Соседние числа каждой подпоследовательности задают направленные рёбра. Строим граф и выполняем топологический обход, проверяя два дополнительных условия:

1. На каждом шаге должен быть **ровно один** источник. Несколько источников допускают разные порядки.
2. Единственный источник должен совпасть со следующим элементом `originalSeq`.

Также сверяем число различных вершин с длиной оригинала и в конце требуем обработки всех элементов. Это исключает отсутствующие числа и циклы.

## Код

{% raw %}
```go
package main

import (
	"fmt"
)

func canConstruct(originalSeq []int, sequences [][]int) bool {
	graph := map[int][]int{}
	inDegree := map[int]int{}
	for _, seq := range sequences {
		for _, n := range seq {
			if _, ok := inDegree[n]; !ok {
				inDegree[n] = 0
			}
		}
	}
	if len(inDegree) != len(originalSeq) {
		return false
	}
	for _, seq := range sequences {
		for i := 1; i < len(seq); i++ {
			parent, child := seq[i-1], seq[i]
			graph[parent] = append(graph[parent], child)
			inDegree[child]++
		}
	}
	sources := []int{}
	for n, d := range inDegree {
		if d == 0 {
			sources = append(sources, n)
		}
	}
	count := 0
	for len(sources) > 0 {
		if len(sources) != 1 {
			return false
		}
		vertex := sources[0]
		sources = sources[1:]
		if count >= len(originalSeq) || originalSeq[count] != vertex {
			return false
		}
		count++
		for _, child := range graph[vertex] {
			inDegree[child]--
			if inDegree[child] == 0 {
				sources = append(sources, child)
			}
		}
	}
	return count == len(originalSeq)
}

func main() {
	fmt.Println(canConstruct([]int{1, 2, 3, 4}, [][]int{{1, 2}, {2, 3}, {3, 4}}))
	fmt.Println(canConstruct([]int{1, 2, 3, 4}, [][]int{{1, 2}, {2, 3}, {2, 4}}))
	fmt.Println(canConstruct([]int{3, 1, 4, 2, 5}, [][]int{{3, 1, 5}, {1, 4, 2, 5}}))
}
```
{% endraw %}

**Вывод:**

```text
true
false
true
```

## Временная сложность

$$O(V+N)$$, где `V` — число различных чисел, `N` — суммарное число вхождений в подпоследовательностях.

## Пространственная сложность

$$O(V+N)$$ для графа, входящих степеней и очереди.

{% include algo-task-nav.html position="bottom" %}
