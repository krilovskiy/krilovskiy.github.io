---
title: Самая длинная подстрока с k различными символами
description: Поиск длины самой длинной подстроки, содержащей не более k различных символов.
pattern: sliding-window
permalink: /posts/algo-patterns-sliding-window/longest-substring-k-distinct/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дана строка. Найдите длину самой длинной подстроки, содержащей не более `k` различных символов.

**Пример 1:**

```text
Вход: строка="araaci", k=2
Выход: 4
Пояснение: самая длинная подходящая подстрока — "araa".
```

**Пример 2:**

```text
Вход: строка="araaci", k=1
Выход: 2
Пояснение: самая длинная подходящая подстрока — "aa".
```

**Пример 3:**

```text
Вход: строка="cbbebi", k=3
Выход: 5
Пояснение: самые длинные подходящие подстроки — "cbbeb" и "bbebi".
```

## Решение

Будем хранить в частотной таблице количество каждого символа текущего окна:

1. Добавляем очередной символ к правой границе окна и увеличиваем его частоту.
2. Если в таблице стало больше `k` различных символов, сдвигаем левую границу. Уменьшаем частоту выходящего символа и удаляем его из таблицы, когда частота становится равной нулю.
3. После сжатия сравниваем длину текущего окна с максимальной найденной длиной.

## Код

```go
package main

import "fmt"

func longestSubstringWithKDistinct(text string, k int) int {
	if k <= 0 {
		return 0
	}

	characters := []rune(text)
	frequencies := make(map[rune]int)
	windowStart := 0
	maxLength := 0

	for windowEnd, character := range characters {
		frequencies[character]++

		for len(frequencies) > k {
			leftCharacter := characters[windowStart]
			frequencies[leftCharacter]--
			if frequencies[leftCharacter] == 0 {
				delete(frequencies, leftCharacter)
			}
			windowStart++
		}

		windowLength := windowEnd - windowStart + 1
		if windowLength > maxLength {
			maxLength = windowLength
		}
	}

	return maxLength
}

func main() {
	fmt.Println("Длина самой длинной подстроки:", longestSubstringWithKDistinct("araaci", 2))
	fmt.Println("Длина самой длинной подстроки:", longestSubstringWithKDistinct("araaci", 1))
	fmt.Println("Длина самой длинной подстроки:", longestSubstringWithKDistinct("cbbebi", 3))
}
```

**Вывод:**

```text
Длина самой длинной подстроки: 4
Длина самой длинной подстроки: 2
Длина самой длинной подстроки: 5
```

## Временная сложность

Каждый символ добавляется в окно и удаляется из него не более одного раза, поэтому временная сложность равна $$O(N)$$.

## Пространственная сложность

Срез `characters` хранит $$N$$ рун, а частотная таблица — не более `min(N, k+1)` символов. Поэтому пространственная сложность Go-реализации равна $$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
