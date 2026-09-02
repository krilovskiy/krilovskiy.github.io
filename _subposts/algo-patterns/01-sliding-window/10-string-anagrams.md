---
title: Анаграммы строки
description: Поиск начальных индексов всех подстрок, являющихся анаграммами заданного шаблона.
pattern: sliding-window
permalink: /posts/algo-patterns-sliding-window/string-anagrams/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны строка и шаблон из ASCII-символов. Найдите в строке все анаграммы шаблона и верните список их начальных индексов.

Анаграмма — это перестановка символов строки. Например, анаграммами `abc` являются `abc`, `acb`, `bac`, `bca`, `cab` и `cba`.

**Пример 1:**

```text
Вход: строка="ppqp", шаблон="pq"
Выход: [1, 2]
Пояснение: анаграммы шаблона — "pq" и "qp".
```

**Пример 2:**

```text
Вход: строка="abbcabc", шаблон="abc"
Выход: [2, 3, 4]
Пояснение: анаграммы шаблона — "bca", "cab" и "abc".
```

## Решение

Алгоритм почти совпадает с проверкой наличия перестановки строки. Храним частоты символов шаблона и двигаем окно его длины. Когда частоты всех различных символов совпали, добавляем левую границу текущего окна в результат. Затем удаляем левый символ и продолжаем поиск, чтобы найти все вхождения.

## Код

```go
package main

import "fmt"

func findStringAnagrams(text, pattern string) []int {
	result := []int{}
	if len(pattern) == 0 || len(pattern) > len(text) {
		return result
	}

	frequencies := make(map[byte]int)
	for index := 0; index < len(pattern); index++ {
		character := pattern[index]
		frequencies[character]++
	}

	windowStart := 0
	matched := 0

	for windowEnd := 0; windowEnd < len(text); windowEnd++ {
		character := text[windowEnd]
		if _, ok := frequencies[character]; ok {
			frequencies[character]--
			if frequencies[character] == 0 {
				matched++
			}
		}
		if matched == len(frequencies) {
			result = append(result, windowStart)
		}

		if windowEnd >= len(pattern)-1 {
			leftCharacter := text[windowStart]
			windowStart++
			if _, ok := frequencies[leftCharacter]; ok {
				if frequencies[leftCharacter] == 0 {
					matched--
				}
				frequencies[leftCharacter]++
			}
		}
	}

	return result
}

func main() {
	fmt.Println(findStringAnagrams("ppqp", "pq"))
	fmt.Println(findStringAnagrams("abbcabc", "abc"))
}
```

**Вывод:**

```text
[1 2]
[2 3 4]
```

## Временная сложность

Построение таблицы занимает $$O(M)$$, а проход по строке — $$O(N)$$. Общая временная сложность равна $$O(N+M)$$.

## Пространственная сложность

Таблица частот занимает $$O(M)$$ памяти. В худшем случае список результата содержит $$O(N)$$ индексов, поэтому с учётом результата требуется $$O(M+N)$$ памяти.

{% include algo-task-nav.html position="bottom" %}
