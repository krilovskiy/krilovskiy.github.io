---
title: Алгосы от Влада, часть 10. Подмножества
date: 2027-01-01 00:00:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
math: true
pattern: subsets
short_title: Подмножества
primary_task_title: Подмножества
primary_task_anchor: subsets
---


* [Введение](/posts/algo-patterns/)
* [Скользящее окно](/posts/algo-patterns-sliding-window/)
* [Два указателя или итератор](/posts/algo-patterns-two-pointers/)
* [Быстрый и медленный указатель](/posts/algo-patterns-fast-slow-pointer/)
* [Мерж интервалов](/posts/algo-patterns-merge-intervals/)
* [Циклическая сортировка](/posts/algo-patterns-cyclic-sort/)
* [Инвертирование связанного списка на месте](/posts/algo-patterns-in-place-reversal-linked-list/)
* [Дерево BFS](/posts/algo-patterns-tree-breadth-first-search/)
* [Дерево DFS](/posts/algo-patterns-tree-depth-first-search/)
* [Две кучи](/posts/algo-patterns-two-heaps/)
* <b>Подмножества</b>
* [Модифицированный бинарный поиск](/posts/algo-patterns-modified-binary-search/)
* [Побитовый XOR](/posts/algo-patterns-bitwise-xor/)
* [Лучшие K элементов](/posts/algo-patterns-top-k-elements/)
* [K-way merge](/posts/algo-patterns-k-way-merge/)
* [Рюкзак 0/1](/posts/algo-patterns-0-1-knapsack/)
* [Топологическая сортировка](/posts/algo-patterns-topological-sort/)


## Введение

Во многих задачах на собеседованиях нужно получить перестановки и комбинации заданного набора элементов. Паттерн «Подмножества» описывает подход на основе поиска в ширину — Breadth First Search (BFS), который помогает решать такие задачи.

Начнём с первой задачи, чтобы разобраться, как он работает.


## Подмножества (простой уровень) {#subsets}

### Условие задачи

Дан набор различных элементов. Найдите все его различные подмножества.

**Пример 1:**

```text
Вход: [1, 3]
Выход: [], [1], [3], [1, 3]
```

**Пример 2:**

```text
Вход: [1, 5, 3]
Выход: [], [1], [5], [3], [1, 5], [1, 3], [5, 3], [1, 5, 3]
```

### Решение

Применим подход BFS: начнём с пустого множества, будем перебирать числа по одному и добавлять каждое число к уже существующим подмножествам, создавая новые.

Для набора `[1, 5, 3]` алгоритм выполняет следующие шаги:

1. Начинаем с пустого подмножества: `[[]]`.
2. Добавляем `1` ко всем существующим подмножествам: `[[], [1]]`.
3. Добавляем `5`: `[[], [1], [5], [1, 5]]`.
4. Добавляем `3`: `[[], [1], [5], [1, 5], [3], [1, 3], [5, 3], [1, 5, 3]]`.

Старые подмножества сохраняются. На каждом шаге их количество фиксируем до добавления новых, чтобы текущее число появилось в каждом новом подмножестве только один раз.

[![Построение всех подмножеств набора 1, 5, 3 по уровням BFS](/assets/img/posts/2027-01-01-algo-patterns-subsets/subsets-steps.svg)](/assets/img/posts/2027-01-01-algo-patterns-subsets/subsets-steps.svg)

Поскольку исходные элементы различны, полученные подмножества не повторяются.

### Код

Вот как будет выглядеть наш алгоритм:

{% raw %}
```go
package main

import "fmt"

func findSubsets(nums []int) [][]int {
	subsets := [][]int{{}}
	for _, currentNumber := range nums {
		n := len(subsets)
		for i := 0; i < n; i++ {
			set := make([]int, len(subsets[i])+1)
			copy(set, subsets[i])
			set[len(subsets[i])] = currentNumber
			subsets = append(subsets, set)
		}
	}
	return subsets
}
func main() {
	fmt.Println("Подмножества:", findSubsets([]int{1, 3}))
	fmt.Println("Подмножества:", findSubsets([]int{1, 5, 3}))
}
```
{% endraw %}

**Вывод:**

```text
Подмножества: [[] [1] [3] [1 3]]
Подмножества: [[] [1] [5] [1 5] [3] [1 3] [5 3] [1 5 3]]
```

### Временная сложность

На каждом шаге количество подмножеств удваивается. Для $$N$$ элементов получается $$2^N$$ подмножеств. В оригинале приведена оценка $$O(2^N)$$ по количеству создаваемых подмножеств.

В показанном Go-коде каждое новое подмножество копируется в отдельный срез. С учётом копирования его элементов временная сложность составляет $$O(N \cdot 2^N)$$.

### Пространственная сложность

Дополнительная память используется для результата. Оценка оригинала — $$O(2^N)$$ подмножеств; с учётом хранения всех элементов в Go-срезах — $$O(N \cdot 2^N)$$.


## Задачи главы

1. [Подмножества (простой уровень)](#subsets)
2. [Подмножества с дубликатами (простой уровень)](/posts/algo-patterns-subsets/subsets-with-duplicates/)
3. [Перестановки (средний уровень)](/posts/algo-patterns-subsets/permutations/)
4. [Перестановки регистра строки (средний уровень)](/posts/algo-patterns-subsets/letter-case-permutations/)
5. [Сбалансированные скобки (сложный уровень)](/posts/algo-patterns-subsets/balanced-parentheses/)
6. [Уникальные обобщённые сокращения (сложный уровень)](/posts/algo-patterns-subsets/unique-generalized-abbreviations/)
7. [Вычисление выражения (сложный уровень)](/posts/algo-patterns-subsets/evaluate-expression/)
8. [Структурно уникальные бинарные деревья поиска (сложный уровень)](/posts/algo-patterns-subsets/structurally-unique-bst/)
9. [Количество структурно уникальных бинарных деревьев поиска (сложный уровень)](/posts/algo-patterns-subsets/count-unique-bst/)


## Похожие задания

### Pattern: Subsets

1. Subsets [Leetcode](https://leetcode.com/problems/subsets/)
2. Subsets II [Leetcode](https://leetcode.com/problems/subsets-ii/)
3. Permutations [Leetcode](https://leetcode.com/problems/permutations/)
4. Letter Case Permutation [Leetcode](https://leetcode.com/problems/letter-case-permutation/)
5. Generate Parentheses [Leetcode](https://leetcode.com/problems/generate-parentheses/)
6. Different Ways to Add Parentheses [Leetcode](https://leetcode.com/problems/different-ways-to-add-parentheses/)
7. Unique Binary Search Trees II [Leetcode](https://leetcode.com/problems/unique-binary-search-trees-ii/)
8. Unique Binary Search Trees [Leetcode](https://leetcode.com/problems/unique-binary-search-trees/)
