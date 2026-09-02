---
title: Найти пропущенное число
description: Поиск единственного пропущенного числа в диапазоне от 0 до n.
pattern: cyclic-sort
permalink: /posts/algo-patterns-cyclic-sort/find-missing-number/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан массив, содержащий `n` различных чисел из диапазона от `0` до `n`. Одно число в нём отсутствует. Найдите пропущенное число.

**Пример 1:**

- Вход: `[4, 0, 3, 1]`
- Выход: `2`

**Пример 2:**

- Вход: `[8, 3, 5, 2, 4, 6, 0, 1]`
- Выход: `7`

## Решение

Размещаем каждое число `x`, которое меньше длины массива, по индексу `x`. Значение `n` пропускаем, потому что в массиве нет индекса `n`.

После циклической сортировки первый индекс `i`, для которого `nums[i] != i`, и будет пропущенным числом. Если все числа находятся на своих индексах, пропущено число `n`.

## Код

```go
package main

import "fmt"

func findMissingNumber(nums []int) int {
	i := 0
	n := len(nums)

	for i < n {
		correctIndex := nums[i]
		if nums[i] < n && nums[i] != nums[correctIndex] {
			nums[i], nums[correctIndex] = nums[correctIndex], nums[i]
		} else {
			i++
		}
	}

	for i, number := range nums {
		if number != i {
			return i
		}
	}

	return n
}

func findMissingNumberXOR(nums []int) int {
	n := len(nums)

	xor1 := 0
	for i := 0; i <= n; i++ {
		xor1 ^= i
	}

	xor2 := 0
	for _, number := range nums {
		xor2 ^= number
	}

	return xor1 ^ xor2
}

func main() {
	fmt.Println("Пропущенное число:", findMissingNumber([]int{4, 0, 3, 1}))
	fmt.Println("Пропущенное число:", findMissingNumber([]int{8, 3, 5, 2, 4, 6, 0, 1}))

	fmt.Println("\nИспользуя XOR:")
	fmt.Println("Пропущенное число:", findMissingNumberXOR([]int{4, 0, 3, 1}))
	fmt.Println("Пропущенное число:", findMissingNumberXOR([]int{8, 3, 5, 2, 4, 6, 0, 1}))
}
```

**Вывод:**

```text
Пропущенное число: 2
Пропущенное число: 7

Используя XOR:
Пропущенное число: 2
Пропущенное число: 7
```

## Временная сложность

Временная сложность обоих вариантов равна $$O(n)$$.

## Пространственная сложность

Оба варианта используют $$O(1)$$ дополнительной памяти. Решение с циклической сортировкой изменяет входной массив.

{% include algo-task-nav.html position="bottom" %}
