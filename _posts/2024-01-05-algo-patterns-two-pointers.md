---
title: Алгосы от Влада, часть 2. Два указателя
date: 2024-01-05 20:21:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
math: true
---


* [Введение](/posts/algo-patterns/)
* [Скользящее окно](/posts/algo-patterns-sliding-window/)
* <b>Два указателя или итератор</b>
* Быстрый и медленный указатель
* Мерж интервалов
* Циклическая сортировка
* Инвертирование связанного списка на месте
* Дерево BFS
* Дерево DFS
* Две кучи
* Подмножества
* Модифицированный бинарный поиск
* Побитовый XOR
* Лучшие элементы К (top K elements)
* k-образный алгоритм слияния (K-Way merge)
* 0 or 1 Knapsack (Динамическое программирование)
* Топологическая сортировки


Два указателя - это паттерн, в котором два указателя итерационно проходят через структуру данных, 
пока один или оба указателя не достигнут определенного условия. Два указателя часто полезны при поиске пар в 
отсортированном массиве или связанном списке; например, когда нужно сравнить каждый элемент массива с 
другими его элементами.

Два указателя нужны потому, что при использовании одного указателя вам пришлось бы постоянно обращаться к массиву, 
чтобы найти ответ. Эти хождения туда-сюда с одним итератором неэффективны с точки зрения временной и 
пространственной сложности - это понятие называется асимптотическим анализом. 
Хотя брутфорс или наивное решение с одним указателем будет работать, оно даст что-то вроде 
$$ 
\begin{equation} 
O(N²) 
\end{equation} 
$$ .

Также мы можем применить <b>Бинарный поиск</b>, взяв первый элемент и производя поиск второго элемента 
при помощи бинарного поиска. Это может дать нам сложность $$\begin{equation} O(N logN) \end{equation}$$


Во многих случаях два указателя могут помочь вам найти решение с лучшей временной сложностью или сложностью по памяти.


В задачах, где мы имеем дело с отсортированными массивами (или LinkedLists) и должны найти набор элементов, 
удовлетворяющих определенным ограничениям, подход Two Pointers оказывается весьма полезным. 
Набор элементов может быть парой, триплетом или даже подмассивом.

Например, посмотрите на следующую задачу:
```
Дан отсортированный массив чисел и заданная сумма M, найдите в массиве пару, 
сумма которой равна заданной сумме M.

Напишите функцию, возвращающую индексы двух чисел (т. е. пары), сумма которых равна заданной сумме М.
```

Пример №1
```go
Input: [1, 2, 3, 4, 6], сумма=6
Output: [1, 3]
Объяснение: Числа по индексу 1 и 3 в сумме дают 6: 2+4=6
```

Пример №2
```go
Input: [2, 5, 9, 11], сумм=11
Output: [0, 2]
Объяснение: Числа по индексу 0 и 2 в сумме дают 11: 2+9=11
```


Учитывая, что входной массив отсортирован, эффективным способом будет начать с одного указателя в начале 
и другого указателя в конце. На каждом шаге мы будем проверять, складываются ли числа, на которые указывают 
два указателя, в заданную сумму. Если нет, то мы сделаем одну из двух вещей:

* Если сумма двух чисел, на которые указывают два указателя, больше целевой суммы, значит, 
нам нужна пара с меньшей суммой. Поэтому, чтобы перебрать больше пар, мы можем уменьшить конечный указатель.
* Если сумма двух чисел, на которые указывают два указателя, меньше целевой суммы, это означает, 
что нам нужна пара с большей суммой. Поэтому, чтобы перебрать больше пар, мы можем увеличить начальный указатель.

Вот визуальное представление алгоритма:
![Desktop View](/assets/img/posts/2024-01-05-algo-patterns-two-pointers/two-pointers.svg){: width="700" height="400" }

Временная сложность приведенного выше алгоритма составит
$$\begin{equation} O(N) \end{equation}$$

Вот как наш алгоритм будет выглядеть
```go
package main

import (
	"fmt"
)

func pairWithTargetSum(arr []int, targetSum int) (int, int) {
	left, right := 0, len(arr)-1
	for left < right {
		currentSum := arr[left] + arr[right]
		if currentSum == targetSum {
			return left, right
		}
		if targetSum > currentSum {
			left++ // we need a pair with a bigger sum
		} else {
			right-- // we need a pair with a smaller sum
		}
	}
	return -1, -1
}

func main() {
	fmt.Println(pairWithTargetSum([]int{1, 2, 3, 4, 6}, 6))
	fmt.Println(pairWithTargetSum([]int{2, 5, 9, 11}, 11))
}
```

Вывод
```
1 3
0 2
```
Временная сложность приведенного выше алгоритма составит 
$$\begin{equation} O(N) \end{equation}$$
, где 'N' - общее количество элементов в заданном массиве.

Сложность по памяти составит $$\begin{equation} O(1) \end{equation}$$

Потребление памяти - константа

Альтернативное решение

Вместо использования двух указателей или двоичного поиска мы можем использовать HashTable для поиска нужной пары. 
Мы можем перебирать массив по одному числу за раз. 
Допустим, во время итерации мы находимся на номере
$$\begin{equation} X \end{equation}$$, поэтому нам нужно 
найти $$\begin{equation} Y \end{equation} $$, такое, что
$$\begin{equation} X + Y == Target \end{equation}$$.
Для этого мы сделаем две вещи: 

1. Поиск $$\begin{equation} Y \end{equation}$$ (Что является эквивалентом $$\begin{equation} Target - X \end{equation}$$)
В <b>Хэш-таблице<b>. Если такой элемент есть, значит мы нашли нужную пару
2. Если нет, вставляем $$\begin{equation} Х \end{equation}$$ в <b>Хэш-таблицу<b>, чтобы мы могли найти его позже

Вот алгоритм решения: 
```go
package main

import (
	"fmt"
)

func pairWithTargetSum(arr []int, targetSum int) (int, int) {
	nums := make(map[int]int) // to store numbers and their indices
	for i, num := range arr {
		if j, ok := nums[targetSum-num]; ok {
			return j, i
		}
		nums[num] = i
	}
	return -1, -1
}

func main() {
	fmt.Println(pairWithTargetSum([]int{1, 2, 3, 4, 6}, 6))
	fmt.Println(pairWithTargetSum([]int{2, 5, 9, 11}, 11))
}
```

Вывод
```
1 3
0 2
```
Вот и все, мои дорогие папищики. Теперь мы умеем решать задачи на два указателя. 

Если ты хочешь попрактиковаться, велкам.
Вот несколько задач, в которых используется паттерн "Два указателя":
* Pair with Target Sum (easy) [LeetCode](https://leetcode.com/problems/two-sum/)
* Remove Duplicates (easy) [LeetCode](https://leetcode.com/problems/remove-duplicates-from-sorted-list/) [LeetCode](https://leetcode.com/problems/remove-duplicates-from-sorted-list-ii/) [LeetCode](https://leetcode.com/problems/remove-duplicates-from-sorted-array-ii/) [LeetCode](https://leetcode.com/problems/find-the-duplicate-number/) [LeetCode](https://leetcode.com/problems/duplicate-zeros/)
* Squaring a Sorted Array (easy) [LeetCode](https://leetcode.com/problems/squares-of-a-sorted-array/)
* Triplet Sum to Zero (medium) [LeetCode](https://leetcode.com/problems/3sum/)
* Triplet Sum Close to Target (medium) [LeetCode](https://leetcode.com/problems/3sum-closest/)
* Triplets with Smaller Sum (medium) [LintCode](https://www.lintcode.com/problem/3sum-smaller/description)
* Subarrays with Product Less than a Target (medium) [LeetCode](https://leetcode.com/problems/subarray-product-less-than-k/)
* Dutch National Flag Problem (medium) [CoderByte](https://coderbyte.com/algorithm/dutch-national-flag-sorting-problem)
* Problem Challenge 1 - Quadruple Sum to Target (medium) [Leetcode](https://leetcode.com/problems/4sum/)
* Problem Challenge 2 - Comparing Strings containing Backspaces (medium) [Leetcode](https://leetcode.com/problems/backspace-string-compare/)

