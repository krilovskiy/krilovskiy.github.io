---
title: Поиск в повёрнутом массиве
description: Поиск key в циклически повёрнутом массиве, включая вариацию с дубликатами.
pattern: modified-binary-search
permalink: /posts/algo-patterns-modified-binary-search/search-in-rotated-array/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан массив чисел, отсортированный по возрастанию и затем циклически повёрнутый на произвольное число позиций. Найдите индекс `key`, если число присутствует, иначе верните `-1`.

В основной задаче повторяющихся чисел нет.

**Пример 1:**

```text
Вход: [10, 15, 1, 3, 8], key = 15
Выход: 1
```

Число `15` находится по индексу `1`. Исходный массив и результат двух поворотов:

[![Массив 1, 3, 8, 10, 15 до и после двух циклических поворотов вправо](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/array-after-two-rotations.svg)](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/array-after-two-rotations.svg)

**Пример 2:**

```text
Вход: [4, 5, 7, 9, 10, -1, 2], key = 10
Выход: 4
```

Число `10` находится по индексу `4`. Исходный массив и результат пяти поворотов:

[![Отсортированный массив от минус 1 до 10 после пяти циклических поворотов вправо](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/array-after-five-rotations.svg)](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/array-after-five-rotations.svg)

## Решение

Применим модифицированный бинарный поиск. После вычисления `mid` сравним элементы на позициях `start` и `mid`:

1. Если `arr[start] <= arr[mid]`, левая часть от `start` до `mid` отсортирована по возрастанию.
2. Иначе отсортирована правая часть от `mid+1` до `end`.

Зная упорядоченную часть, легко решить, где продолжать поиск. Например, если отсортирована левая часть:

* если `arr[start] <= key < arr[mid]`, число может быть слева: устанавливаем `end = mid-1`;
* иначе пропускаем левую часть: `start = mid+1`.

Для отсортированной правой части проверяем `arr[mid] < key <= arr[end]` и аналогично выбираем направление.

Разберём поиск `10` во втором примере:

[![Выбор отсортированной половины и сужение диапазона при поиске 10 в повёрнутом массиве](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/rotated-array-search-steps.svg)](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/rotated-array-search-steps.svg)

При отсутствии дубликатов на каждом шаге можно исключить половину диапазона. Вариацию с повторениями разберём ниже.

## Код

{% raw %}
```go
package main

import "fmt"

func search(arr []int, key int) int {
	start, end := 0, len(arr)-1
	for start <= end {
		mid := start + (end-start)/2
		if arr[mid] == key {
			return mid
		}

		if arr[start] <= arr[mid] {
			if key >= arr[start] && key < arr[mid] {
				end = mid - 1
			} else {
				start = mid + 1
			}
		} else {
			if key > arr[mid] && key <= arr[end] {
				start = mid + 1
			} else {
				end = mid - 1
			}
		}
	}
	return -1
}
func main() {
	fmt.Println("Индекс:", search([]int{10, 15, 1, 3, 8}, 15))
	fmt.Println("Индекс:", search([]int{4, 5, 7, 9, 10, -1, 2}, 10))
}
```
{% endraw %}

**Вывод:**

```text
Индекс: 1
Индекс: 4
```

## Временная сложность

На каждом шаге диапазон поиска уменьшается вдвое. Временная сложность — $$O(\log N)$$, где $$N$$ — число элементов массива.

## Пространственная сложность

Алгоритм использует постоянную дополнительную память — $$O(1)$$.

## Вариации задачи

### Поиск с дубликатами

Как искать в отсортированном и повёрнутом массиве, если числа могут повторяться? Основной алгоритм не справится со следующим примером:

```text
Вход: [3, 7, 3, 3, 3], key = 7
Выход: 1
```

Число `7` находится по индексу `1`.

[![Повёрнутый массив с повторяющимися тройками, в котором нужно найти число 7](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/rotated-array-with-duplicates.svg)](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/rotated-array-with-duplicates.svg)

### Решение

Проблема возникает, когда `arr[start] == arr[mid] == arr[end]`: невозможно определить, какая половина упорядочена. Если `key` не совпал с `arr[mid]`, можно безопасно пропустить по одному элементу с обоих концов: `start++`, `end--`.

Все остальные шаги остаются прежними.

### Код

{% raw %}
```go
package main

import "fmt"

func search(arr []int, key int) int {
	start, end := 0, len(arr)-1
	for start <= end {
		mid := start + (end-start)/2
		if arr[mid] == key {
			return mid
		}
		if arr[start] == arr[mid] && arr[end] == arr[mid] {
			start++
			end--
			continue
		}
		if arr[start] <= arr[mid] {
			if key >= arr[start] && key < arr[mid] {
				end = mid - 1
			} else {
				start = mid + 1
			}
		} else {
			if key > arr[mid] && key <= arr[end] {
				start = mid + 1
			} else {
				end = mid - 1
			}
		}
	}
	return -1
}
func main() {
	fmt.Println("Индекс:", search([]int{3, 7, 3, 3, 3}, 7))
}
```
{% endraw %}

**Вывод:**

```text
Индекс: 1
```

### Временная сложность

В оригинале указано, что поиск обычно работает за $$O(\log N)$$. Однако при совпадающих крайних и среднем элементах исключаем только два числа, поэтому худшая временная сложность — $$O(N)$$.

### Пространственная сложность

Алгоритм использует постоянную дополнительную память — $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
