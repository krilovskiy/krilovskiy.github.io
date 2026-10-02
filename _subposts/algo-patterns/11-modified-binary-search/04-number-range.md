---
title: Диапазон числа
description: Поиск первого и последнего вхождения key в отсортированном массиве.
pattern: modified-binary-search
permalink: /posts/algo-patterns-modified-binary-search/number-range/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан массив чисел, отсортированный по возрастанию. Найдите диапазон числа `key` — его первую и последнюю позиции в массиве.

Верните пару индексов. Если число отсутствует, верните `[-1, -1]`.

**Пример 1:**

```text
Вход: [4, 6, 6, 6, 9], key = 6
Выход: [1, 3]
```

**Пример 2:**

```text
Вход: [1, 3, 8, 10, 15], key = 10
Выход: [3, 3]
```

**Пример 3:**

```text
Вход: [1, 3, 8, 10, 15], key = 12
Выход: [-1, -1]
```

## Решение

Применим бинарный поиск дважды. При нахождении `key` сохраняем его индекс в `keyIndex`, но продолжаем поиск:

* для первой позиции передвигаем `end = mid-1`, проверяя, есть ли число раньше;
* для последней позиции передвигаем `start = mid+1`, проверяя, есть ли число позже.

Последний сохранённый индекс в каждом поиске даёт соответствующую границу. Если первый поиск не нашёл `key`, второй запускать не нужно.

## Код

{% raw %}
```go
package main

import "fmt"

func findRange(arr []int, key int) [2]int {
	result := [2]int{-1, -1}
	result[0] = search(arr, key, false)
	if result[0] != -1 {
		result[1] = search(arr, key, true)
	}
	return result
}
func search(arr []int, key int, findMaxIndex bool) int {
	keyIndex := -1
	start, end := 0, len(arr)-1
	for start <= end {
		mid := start + (end-start)/2
		if key < arr[mid] {
			end = mid - 1
		} else if key > arr[mid] {
			start = mid + 1
		} else {
			keyIndex = mid
			if findMaxIndex {
				start = mid + 1
			} else {
				end = mid - 1
			}
		}
	}
	return keyIndex
}
func main() {
	fmt.Println("Диапазон:", findRange([]int{4, 6, 6, 6, 9}, 6))
	fmt.Println("Диапазон:", findRange([]int{1, 3, 8, 10, 15}, 10))
	fmt.Println("Диапазон:", findRange([]int{1, 3, 8, 10, 15}, 12))
}
```
{% endraw %}

**Вывод:**

```text
Диапазон: [1 3]
Диапазон: [3 3]
Диапазон: [-1 -1]
```

## Временная сложность

Выполняем не более двух бинарных поисков, каждый за $$O(\log N)$$. Временная сложность — $$O(\log N)$$, где $$N$$ — число элементов массива.

## Пространственная сложность

Алгоритм использует постоянную дополнительную память — $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
