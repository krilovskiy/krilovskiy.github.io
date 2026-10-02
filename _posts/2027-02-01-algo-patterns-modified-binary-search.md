---
title: Алгосы от Влада, часть 11. Модифицированный бинарный поиск
date: 2027-02-01 00:00:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
math: true
pattern: modified-binary-search
short_title: Модифицированный бинарный поиск
primary_task_title: Бинарный поиск с неизвестным порядком сортировки
primary_task_anchor: order-agnostic-binary-search
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
* [Подмножества](/posts/algo-patterns-subsets/)
* <b>Модифицированный бинарный поиск</b>
* Побитовый XOR
* Лучшие элементы К (top K elements)
* k-образный алгоритм слияния (K-Way merge)
* 0 or 1 Knapsack (Динамическое программирование)
* Топологическая сортировка


## Введение

Для поиска заданного элемента в отсортированном массиве подходит бинарный поиск. Паттерн «Модифицированный бинарный поиск» описывает, как приспосабливать этот подход к разным условиям.

Разберём набор задач, который поможет понять паттерн и применять его к другим вопросам на собеседованиях. Начнём с первой задачи.


## Бинарный поиск с неизвестным порядком сортировки (простой уровень) {#order-agnostic-binary-search}

### Условие задачи

Дан отсортированный массив чисел. Определите, присутствует ли в нём число `key`. Массив отсортирован, но неизвестно, по возрастанию или по убыванию. Он может содержать повторяющиеся числа.

Верните индекс `key`, если число найдено, иначе верните `-1`.

**Пример 1:**

```text
Вход: [4, 6, 10], key = 10
Выход: 2
```

**Пример 2:**

```text
Вход: [1, 2, 3, 4, 5, 6, 7], key = 5
Выход: 4
```

**Пример 3:**

```text
Вход: [10, 6, 4], key = 10
Выход: 0
```

**Пример 4:**

```text
Вход: [10, 6, 4], key = 4
Выход: 2
```

### Решение

Сначала предположим, что массив отсортирован по возрастанию.

1. Устанавливаем `start` на первый индекс массива `arr`, а `end` — на последний: `start = 0`, `end = len(arr)-1`.
2. Находим середину диапазона. Формула `(start+end)/2` может вызвать переполнение целого числа, если индексы велики. В Java, C++ и Go безопаснее использовать `mid = start+(end-start)/2`. Для целых чисел произвольной точности в Python такой проблемы нет.
3. Если `key == arr[mid]`, возвращаем `mid`.
4. Если `key < arr[mid]`, искомое число не может находиться справа от середины. Продолжаем в левой половине: `end = mid-1`.
5. Если `key > arr[mid]`, продолжаем в правой половине: `start = mid+1`.
6. Повторяем шаги, пока `start <= end`. Если `start` стал больше `end`, число отсутствует: возвращаем `-1`.

Поиск `5` во втором примере:

[![Последовательное сужение диапазона при бинарном поиске числа 5 в массиве от 1 до 7](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/order-agnostic-search-steps.svg)](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/order-agnostic-search-steps.svg)

Для массива, отсортированного по убыванию, меняются направления сравнений:

* если `key > arr[mid]`, продолжаем слева: `end = mid-1`;
* если `key < arr[mid]`, продолжаем справа: `start = mid+1`.

Порядок определяем сравнением первого и последнего элементов. Если `arr[start] < arr[end]`, массив упорядочен по возрастанию, иначе используем ветку для убывания. Если крайние элементы равны, в отсортированном массиве равны и все остальные: проверка равенства на середине всё равно даёт правильный результат.

### Код

{% raw %}
```go
package main

import "fmt"

func search(arr []int, key int) int {
	if len(arr) == 0 {
		return -1
	}
	start, end := 0, len(arr)-1
	isAscending := arr[start] < arr[end]
	for start <= end {
		mid := start + (end-start)/2
		if key == arr[mid] {
			return mid
		}
		if isAscending {
			if key < arr[mid] {
				end = mid - 1
			} else {
				start = mid + 1
			}
		} else {
			if key > arr[mid] {
				end = mid - 1
			} else {
				start = mid + 1
			}
		}
	}
	return -1
}
func main() {
	fmt.Println("Индекс:", search([]int{4, 6, 10}, 10))
	fmt.Println("Индекс:", search([]int{1, 2, 3, 4, 5, 6, 7}, 5))
	fmt.Println("Индекс:", search([]int{10, 6, 4}, 10))
	fmt.Println("Индекс:", search([]int{10, 6, 4}, 4))
}
```
{% endraw %}

**Вывод:**

```text
Индекс: 2
Индекс: 4
Индекс: 0
Индекс: 2
```

### Временная сложность

На каждом шаге диапазон поиска уменьшается вдвое. Временная сложность — $$O(\log N)$$, где $$N$$ — число элементов массива.

### Пространственная сложность

Алгоритм использует постоянную дополнительную память — $$O(1)$$.


## Задачи главы

1. [Бинарный поиск с неизвестным порядком сортировки (простой уровень)](#order-agnostic-binary-search)
2. [Верхняя граница числа (средний уровень)](/posts/algo-patterns-modified-binary-search/ceiling-of-a-number/)
3. [Следующая буква (средний уровень)](/posts/algo-patterns-modified-binary-search/next-letter/)
4. [Диапазон числа (средний уровень)](/posts/algo-patterns-modified-binary-search/number-range/)
5. [Поиск в отсортированном бесконечном массиве (средний уровень)](/posts/algo-patterns-modified-binary-search/search-in-sorted-infinite-array/)
6. [Элемент с минимальной разницей (средний уровень)](/posts/algo-patterns-modified-binary-search/minimum-difference-element/)
7. [Максимум битонического массива (простой уровень)](/posts/algo-patterns-modified-binary-search/bitonic-array-maximum/)
8. [Поиск в битоническом массиве (средний уровень)](/posts/algo-patterns-modified-binary-search/search-bitonic-array/)
9. [Поиск в повёрнутом массиве (средний уровень)](/posts/algo-patterns-modified-binary-search/search-in-rotated-array/)
10. [Количество поворотов массива (средний уровень)](/posts/algo-patterns-modified-binary-search/rotation-count/)


## Похожие задания

### Pattern: Modified Binary Search

1. Binary Search [Leetcode](https://leetcode.com/problems/binary-search/)
2. Find Smallest Letter Greater Than Target [Leetcode](https://leetcode.com/problems/find-smallest-letter-greater-than-target/)
3. Find First and Last Position of Element in Sorted Array [Leetcode](https://leetcode.com/problems/find-first-and-last-position-of-element-in-sorted-array/)
4. Search in Rotated Sorted Array [Leetcode](https://leetcode.com/problems/search-in-rotated-sorted-array/)
5. Search in Rotated Sorted Array II [Leetcode](https://leetcode.com/problems/search-in-rotated-sorted-array-ii/)
6. Find Minimum in Rotated Sorted Array [Leetcode](https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/)
7. Find Minimum in Rotated Sorted Array II [Leetcode](https://leetcode.com/problems/find-minimum-in-rotated-sorted-array-ii/)
