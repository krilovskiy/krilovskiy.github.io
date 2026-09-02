---
title: Максимизация капитала
description: Жадный выбор наиболее прибыльных доступных проектов с помощью двух куч.
pattern: two-heaps
permalink: /posts/algo-patterns-two-heaps/maximize-capital/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан набор инвестиционных проектов с требуемым капиталом и прибылью каждого проекта. Также заданы начальный капитал и максимальное количество проектов, которые можно выбрать. Найдите максимальный капитал после выполнения выбранных проектов.

Проект можно начать, только если доступного капитала достаточно. После завершения проекта его прибыль прибавляется к капиталу.

**Пример 1:**

```text
Капитал проектов: [0, 1, 2]
Прибыль проектов: [1, 2, 3]
Начальный капитал: 1
Количество проектов: 2
Результат: 6
```

Сначала можно выбрать второй проект с прибылью `2`, после чего капитал станет равен `3`. Затем выбираем третий проект с прибылью `3`. Итоговый капитал равен `1 + 2 + 3 = 6`.

**Пример 2:**

```text
Капитал проектов: [0, 1, 2, 3]
Прибыль проектов: [1, 2, 3, 5]
Начальный капитал: 0
Количество проектов: 3
Результат: 8
```

При капитале `0` доступен только первый проект, который увеличит капитал до `1`. Затем выбираем второй проект и получаем капитал `3`. После этого становится доступен четвёртый проект с прибылью `5`. Итоговый капитал равен `1 + 2 + 5 = 8`.

## Решение

При выборе проектов действуют два ограничения:

* проект можно выбрать только при достаточном капитале;
* можно выбрать не больше заданного количества проектов.

Среди всех доступных проектов выгодно каждый раз выбирать проект с максимальной прибылью. Реализуем этот жадный подход с двумя кучами:

1. Добавляем все проекты в минимальную кучу, упорядоченную по требуемому капиталу.
2. Перемещаем из неё в максимальную кучу прибыли всех проектов, доступных при текущем капитале.
3. Выбираем вершину максимальной кучи — самую большую прибыль среди доступных проектов — и прибавляем её к капиталу.
4. Повторяем второй и третий шаги, пока не выберем разрешённое количество проектов или пока доступные проекты не закончатся.

## Код

Вот как будет выглядеть наш алгоритм:

```go
package main

import (
	"container/heap"
	"fmt"
)

type Project struct {
	Capital int
	Profit  int
}

type MinCapitalHeap []Project

func (h MinCapitalHeap) Len() int           { return len(h) }
func (h MinCapitalHeap) Less(i, j int) bool { return h[i].Capital < h[j].Capital }
func (h MinCapitalHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }

func (h *MinCapitalHeap) Push(value any) {
	*h = append(*h, value.(Project))
}

func (h *MinCapitalHeap) Pop() any {
	old := *h
	lastIndex := len(old) - 1
	value := old[lastIndex]
	*h = old[:lastIndex]
	return value
}

type MaxProfitHeap []int

func (h MaxProfitHeap) Len() int           { return len(h) }
func (h MaxProfitHeap) Less(i, j int) bool { return h[i] > h[j] }
func (h MaxProfitHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }

func (h *MaxProfitHeap) Push(value any) {
	*h = append(*h, value.(int))
}

func (h *MaxProfitHeap) Pop() any {
	old := *h
	lastIndex := len(old) - 1
	value := old[lastIndex]
	*h = old[:lastIndex]
	return value
}

func findMaximumCapital(
	capital []int,
	profits []int,
	numberOfProjects int,
	initialCapital int,
) int {
	minCapitalHeap := &MinCapitalHeap{}
	maxProfitHeap := &MaxProfitHeap{}
	heap.Init(minCapitalHeap)
	heap.Init(maxProfitHeap)

	for index, requiredCapital := range capital {
		heap.Push(minCapitalHeap, Project{
			Capital: requiredCapital,
			Profit:  profits[index],
		})
	}

	availableCapital := initialCapital
	for selected := 0; selected < numberOfProjects; selected++ {
		for minCapitalHeap.Len() > 0 && (*minCapitalHeap)[0].Capital <= availableCapital {
			project := heap.Pop(minCapitalHeap).(Project)
			heap.Push(maxProfitHeap, project.Profit)
		}

		if maxProfitHeap.Len() == 0 {
			break
		}

		availableCapital += heap.Pop(maxProfitHeap).(int)
	}

	return availableCapital
}

func main() {
	fmt.Println("Максимальный капитал:", findMaximumCapital(
		[]int{0, 1, 2}, []int{1, 2, 3}, 2, 1,
	))
	fmt.Println("Максимальный капитал:", findMaximumCapital(
		[]int{0, 1, 2, 3}, []int{1, 2, 3, 5}, 3, 0,
	))
}
```

**Вывод:**

```text
Максимальный капитал: 6
Максимальный капитал: 8
```

## Временная сложность

Каждый из $$N$$ проектов не более одного раза добавляется в обе кучи и извлекается из них. Подготовка и перенос проектов требуют $$O(N \log N)$$ времени, а выбор не более $$K$$ проектов — $$O(K \log N)$$. Общая временная сложность равна $$O(N \log N + K \log N)$$.

## Пространственная сложность

Пространственная сложность равна $$O(N)$$, потому что проекты хранятся в кучах.

{% include algo-task-nav.html position="bottom" %}
