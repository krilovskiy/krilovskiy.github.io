---
title: Квадраты элементов отсортированного массива
description: Построение отсортированного массива квадратов с двумя указателями на концах исходного массива.
pattern: two-pointers
permalink: /posts/algo-patterns-two-pointers/squaring-a-sorted-array/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан отсортированный массив. Создайте новый массив, содержащий квадраты всех исходных чисел в отсортированном порядке.

**Пример 1:**

```text
Вход: [-2, -1, 0, 2, 3]
Выход: [0, 1, 4, 4, 9]
```

**Пример 2:**

```text
Вход: [-3, -1, 0, 1, 2]
Выход: [0, 1, 1, 4, 9]
```

## Решение

Отрицательные числа мешают просто возвести элементы в квадрат по порядку: квадрат числа в начале массива может оказаться самым большим.

Наибольший квадрат на каждом шаге даёт один из крайних элементов. Поставим указатели `left` и `right` на концы массива, сравним квадраты и запишем больший в конец результата. После этого сдвинем соответствующий указатель. Результат заполняется справа налево.

## Код

```go
package main

import "fmt"

func makeSquares(arr []int) []int {
	squares := make([]int, len(arr))
	left, right := 0, len(arr)-1
	highestSquareIndex := len(arr) - 1

	for left <= right {
		leftSquare := arr[left] * arr[left]
		rightSquare := arr[right] * arr[right]
		if leftSquare > rightSquare {
			squares[highestSquareIndex] = leftSquare
			left++
		} else {
			squares[highestSquareIndex] = rightSquare
			right--
		}
		highestSquareIndex--
	}

	return squares
}

func main() {
	fmt.Println(makeSquares([]int{-2, -1, 0, 2, 3}))
	fmt.Println(makeSquares([]int{-3, -1, 0, 1, 2}))
}
```

**Вывод:**

```text
[0 1 4 4 9]
[0 1 1 4 9]
```

## Временная сложность

Каждый элемент обрабатывается один раз, поэтому временная сложность равна $$O(N)$$.

## Пространственная сложность

Для выходного массива требуется $$O(N)$$ памяти. Помимо результата алгоритм использует $$O(1)$$ дополнительной памяти.

{% include algo-task-nav.html position="bottom" %}
