---
title: Удаление дубликатов
description: Удаление дубликатов из отсортированного массива на месте методом двух указателей.
pattern: two-pointers
permalink: /posts/algo-patterns-two-pointers/remove-duplicates/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан отсортированный массив чисел. Удалите из него все дубликаты на месте, не используя дополнительный массив, и верните новую длину массива.

**Пример 1:**

```text
Вход: [2, 3, 3, 3, 6, 9, 9]
Выход: 4
Пояснение: после удаления дубликатов первые четыре элемента равны [2, 3, 6, 9].
```

**Пример 2:**

```text
Вход: [2, 2, 2, 11]
Выход: 2
Пояснение: после удаления дубликатов первые два элемента равны [2, 11].
```

## Решение

Поскольку массив отсортирован, одинаковые числа стоят рядом. Один указатель `i` перебирает элементы, а `nextNonDuplicate` указывает на позицию для следующего уникального числа.

Если текущее число отличается от последнего записанного уникального числа, переносим его в позицию `nextNonDuplicate` и сдвигаем этот указатель. После прохода все уникальные элементы находятся в начале массива.

## Код

```go
package main

import "fmt"

func removeDuplicates(arr []int) int {
	if len(arr) == 0 {
		return 0
	}

	nextNonDuplicate := 1
	for i := 1; i < len(arr); i++ {
		if arr[nextNonDuplicate-1] != arr[i] {
			arr[nextNonDuplicate] = arr[i]
			nextNonDuplicate++
		}
	}
	return nextNonDuplicate
}

func removeKey(arr []int, key int) int {
	nextElement := 0
	for _, value := range arr {
		if value != key {
			arr[nextElement] = value
			nextElement++
		}
	}
	return nextElement
}

func main() {
	first := []int{2, 3, 3, 3, 6, 9, 9}
	firstLength := removeDuplicates(first)
	fmt.Println(firstLength, first[:firstLength])

	second := []int{2, 2, 2, 11}
	secondLength := removeDuplicates(second)
	fmt.Println(secondLength, second[:secondLength])

	withKey := []int{3, 2, 3, 6, 3, 10, 9, 3}
	withoutKeyLength := removeKey(withKey, 3)
	fmt.Println(withoutKeyLength, withKey[:withoutKeyLength])
}
```

**Вывод:**

```text
4 [2 3 6 9]
2 [2 11]
4 [2 6 10 9]
```

## Временная сложность

Алгоритм проходит по массиву один раз, поэтому его временная сложность равна $$O(N)$$.

## Пространственная сложность

Изменение выполняется на месте с постоянным объёмом дополнительной памяти, поэтому пространственная сложность равна $$O(1)$$.

## Вариация задачи

Дан неотсортированный массив и ключ `key`. Удалите на месте все вхождения ключа и верните новую длину массива.

Для `[3, 2, 3, 6, 3, 10, 9, 3]` и `key=3` первые четыре элемента результата равны `[2, 6, 10, 9]`. Для `[2, 11, 2, 2, 1]` и `key=2` первые два элемента равны `[11, 1]`.

Функция `removeKey` использует тот же подход: указатель записи сдвигается только для элементов, не равных ключу. Её временная сложность равна $$O(N)$$, пространственная — $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
