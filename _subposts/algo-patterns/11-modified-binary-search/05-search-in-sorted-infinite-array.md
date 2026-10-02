---
title: Поиск в отсортированном бесконечном массиве
description: Расширение границ и бинарный поиск в массиве неизвестного размера.
pattern: modified-binary-search
permalink: /posts/algo-patterns-modified-binary-search/search-in-sorted-infinite-array/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан отсортированный бесконечный массив или массив неизвестного размера. Найдите индекс числа `key`, если оно присутствует, иначе верните `-1`.

Вместо прямого доступа к массиву предоставляется `ArrayReader`. Метод `get(index)` возвращает число по индексу. При выходе за границы конечного массива он возвращает служебное значение `Integer.MAX_VALUE` в исходной версии на Java.

**Пример 1:**

```text
Вход: [4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30], key = 16
Выход: 6
```

Число `16` находится по индексу `6`.

**Пример 2:**

```text
Вход: [4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30], key = 11
Выход: -1
```

Числа `11` в массиве нет.

**Пример 3:**

```text
Вход: [1, 3, 8, 10, 15], key = 15
Выход: 4
```

Число `15` находится по индексу `4`.

**Пример 4:**

```text
Вход: [1, 3, 8, 10, 15], key = 200
Выход: -1
```

Числа `200` в массиве нет.

## Решение

Применить бинарный поиск сразу нельзя: неизвестна правая граница массива. Сначала найдём диапазон, который может содержать `key`.

Начинаем с `start=0`, `end=1`. Пока значение по индексу `end` меньше `key`, сдвигаем диапазон вправо и удваиваем его размер:

1. Сохраняем начало нового диапазона: `newStart = end+1`.
2. Расширяем правую границу: `end += (end-start+1)*2`.
3. Устанавливаем `start = newStart`.

Для `key=16` проверяем диапазоны `[0, 1]`, `[2, 5]`, `[6, 13]`. Последний подходит: `get(13)=30`, что больше `16`. После этого выполняем обычный бинарный поиск в найденных границах.

[![Расширение диапазонов 0–1, 2–5 и 6–13 перед поиском числа 16](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/infinite-array-bounds.svg)](/assets/img/posts/2027-02-01-algo-patterns-modified-binary-search/infinite-array-bounds.svg)

## Код

В Go роль служебного значения играет `math.MaxInt`. Оно зарезервировано для выхода за границы: элементы массива и искомый ключ должны быть меньше него. Рост индекса `end` ограничиваем, чтобы вычисление новых границ не переполнило `int`.

`ArrayReader` в примере хранит обычный срез, но функция поиска обращается к нему только через `get` и не использует его длину.

{% raw %}
```go
package main

import (
	"fmt"
	"math"
)

type ArrayReader struct{ arr []int }

func (reader ArrayReader) get(index int) int {
	if index < 0 || index >= len(reader.arr) {
		return math.MaxInt
	}
	return reader.arr[index]
}
func search(reader ArrayReader, key int) int {
	// math.MaxInt — служебное значение, зарезервированное для выхода за границы.
	if key == math.MaxInt {
		return -1
	}
	start, end := 0, 1
	for reader.get(end) < key {
		newStart := end + 1
		windowSize := end - start + 1
		// Ограничиваем рост индекса, чтобы избежать переполнения int.
		if windowSize > (math.MaxInt-end)/2 {
			end = math.MaxInt
		} else {
			end += windowSize * 2
		}
		start = newStart
	}
	return binarySearch(reader, key, start, end)
}
func binarySearch(reader ArrayReader, key, start, end int) int {
	for start <= end {
		mid := start + (end-start)/2
		value := reader.get(mid)
		if key < value {
			end = mid - 1
		} else if key > value {
			start = mid + 1
		} else {
			return mid
		}
	}
	return -1
}
func main() {
	reader := ArrayReader{arr: []int{4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30}}
	fmt.Println("Индекс:", search(reader, 16))
	fmt.Println("Индекс:", search(reader, 11))
	reader = ArrayReader{arr: []int{1, 3, 8, 10, 15}}
	fmt.Println("Индекс:", search(reader, 15))
	fmt.Println("Индекс:", search(reader, 200))
}
```
{% endraw %}

**Вывод:**

```text
Индекс: 6
Индекс: -1
Индекс: 4
Индекс: -1
```

## Временная сложность

Алгоритм состоит из двух частей. Удвоение диапазона до подходящей границы занимает $$O(\log N)$$, если в конечном массиве максимум $$N$$ элементов. Затем бинарный поиск также занимает $$O(\log N)$$. Итого $$O(\log N+\log N)=O(\log N)$$.

## Пространственная сложность

Поиск использует постоянную дополнительную память — $$O(1)$$. Срез внутри демонстрационного `ArrayReader` представляет входные данные.

{% include algo-task-nav.html position="bottom" %}
