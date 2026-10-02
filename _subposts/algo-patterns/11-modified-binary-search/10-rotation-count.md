---
title: Количество поворотов массива
description: Поиск числа циклических поворотов массива без повторов и с дубликатами.
pattern: modified-binary-search
permalink: /posts/algo-patterns-modified-binary-search/rotation-count/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан массив чисел, отсортированный по возрастанию и циклически повёрнутый вправо $$k$$ раз. Найдите $$k$$. В основной задаче повторяющихся чисел нет.

**Пример 1:**

```text
Вход: [10, 15, 1, 3, 8]
Выход: 2
```

Массив повёрнут два раза:

[![Два поворота вправо переносят минимум 1 на индекс 2](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/array-after-two-rotations.svg)](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/array-after-two-rotations.svg)

**Пример 2:**

```text
Вход: [4, 5, 7, 9, 10, -1, 2]
Выход: 5
```

Массив повёрнут пять раз:

[![Пять поворотов вправо переносят минимум минус 1 на индекс 5](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/array-after-five-rotations.svg)](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/array-after-five-rotations.svg)

**Пример 3:**

```text
Вход: [1, 3, 8, 10]
Выход: 0
```

Массив не повёрнут.

## Решение

Задача следует паттерну бинарного поиска. Используем стратегию из поиска в повёрнутом массиве.

Фактически нужно найти индекс минимального элемента: насколько он сместился вправо, столько поворотов и произошло. В повёрнутом массиве без повторов минимум после точки поворота — единственный элемент, который меньше предыдущего.

После вычисления `mid` сравниваем его с соседями:

1. Если `arr[mid] > arr[mid+1]`, минимум находится на позиции `mid+1`.
2. Если `arr[mid-1] > arr[mid]`, минимум находится на позиции `mid`.

Перед сравнением проверяем, что соседний индекс находится в текущем диапазоне.

Если минимум пока не найден, сравниваем `arr[start]` и `arr[mid]`. При `arr[start] < arr[mid]` левая часть упорядочена, поэтому продолжаем справа: `start = mid+1`. Иначе продолжаем слева: `end = mid-1`.

Если не встретили падение между соседними элементами, возвращаем `0`: массив не повёрнут.

## Код

{% raw %}
```go
package main

import "fmt"

func countRotations(arr []int) int {
	start, end := 0, len(arr)-1
	for start < end {
		mid := start + (end-start)/2
		if mid < end && arr[mid] > arr[mid+1] {
			return mid + 1
		}
		if mid > start && arr[mid-1] > arr[mid] {
			return mid
		}
		if arr[start] < arr[mid] {
			start = mid + 1
		} else {
			end = mid - 1
		}
	}
	return 0
}
func main() {
	fmt.Println("Количество поворотов:", countRotations([]int{10, 15, 1, 3, 8}))
	fmt.Println("Количество поворотов:", countRotations([]int{4, 5, 7, 9, 10, -1, 2}))
	fmt.Println("Количество поворотов:", countRotations([]int{1, 3, 8, 10}))
}
```
{% endraw %}

**Вывод:**

```text
Количество поворотов: 2
Количество поворотов: 5
Количество поворотов: 0
```

## Временная сложность

На каждом шаге диапазон поиска уменьшается вдвое. Временная сложность — $$O(\log N)$$, где $$N$$ — число элементов массива.

## Пространственная сложность

Алгоритм использует постоянную дополнительную память — $$O(1)$$.

## Вариации задачи

### Подсчёт поворотов с дубликатами

Как найти число поворотов, если массив также содержит повторяющиеся числа? Основной код ошибается на следующем примере:

```text
Вход: [3, 3, 7, 3]
Выход: 3
```

Массив повёрнут три раза:

[![Три поворота массива 3, 3, 3, 7 дают 3, 3, 7, 3](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/rotation-count-with-duplicates.svg)](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/rotation-count-with-duplicates.svg)

### Решение

Как и в поиске с дубликатами, при `arr[start] == arr[mid] == arr[end]` нельзя выбрать половину. Но прежде чем сдвинуть `start` или `end`, проверяем, не находится ли рядом минимум:

1. Если `arr[start] > arr[start+1]`, возвращаем `start+1`. Иначе увеличиваем `start`.
2. Если `arr[end-1] > arr[end]`, возвращаем `end`. Иначе уменьшаем `end`.

В остальных случаях выбираем упорядоченную половину, как в исходном алгоритме. Вариант с дубликатами продолжает справа также при `arr[start] == arr[mid]` и `arr[mid] > arr[end]`.

Как и исходный код, функция возвращает позицию после строгого падения соседних значений, а если такого падения нет — `0`. Когда все элементы одинаковы, фактическое число выполненных поворотов по одному массиву определить нельзя.

### Код

{% raw %}
```go
package main

import "fmt"

func countRotations(arr []int) int {
	start, end := 0, len(arr)-1
	for start < end {
		mid := start + (end-start)/2
		if mid < end && arr[mid] > arr[mid+1] {
			return mid + 1
		}
		if mid > start && arr[mid-1] > arr[mid] {
			return mid
		}
		if arr[start] == arr[mid] && arr[end] == arr[mid] {
			if arr[start] > arr[start+1] {
				return start + 1
			}
			start++
			if arr[end-1] > arr[end] {
				return end
			}
			end--
		} else if arr[start] < arr[mid] || (arr[start] == arr[mid] && arr[mid] > arr[end]) {
			start = mid + 1
		} else {
			end = mid - 1
		}
	}
	return 0
}
func main() {
	fmt.Println("Количество поворотов:", countRotations([]int{3, 3, 7, 3}))
}
```
{% endraw %}

**Вывод:**

```text
Количество поворотов: 3
```

### Временная сложность

В оригинале указано, что обычно алгоритм работает за $$O(\log N)$$. В случае повторов он может исключать только два элемента за шаг, поэтому худшая временная сложность — $$O(N)$$.

### Пространственная сложность

Дополнительная память — $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
