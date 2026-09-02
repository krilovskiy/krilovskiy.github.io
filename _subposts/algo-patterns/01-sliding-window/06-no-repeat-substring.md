---
title: Самая длинная подстрока без повторяющихся символов
description: Поиск длины самой длинной подстроки, в которой ни один символ не повторяется.
pattern: sliding-window
permalink: /posts/algo-patterns-sliding-window/no-repeat-substring/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дана строка. Найдите длину самой длинной подстроки без повторяющихся символов.

**Пример 1:**

```text
Вход: "aabccbb"
Выход: 3
Пояснение: самая длинная подстрока без повторений — "abc".
```

**Пример 2:**

```text
Вход: "abbbb"
Выход: 2
Пояснение: самая длинная подстрока без повторений — "ab".
```

**Пример 3:**

```text
Вход: "abccde"
Выход: 3
Пояснение: самые длинные подстроки без повторений — "abc" и "cde".
```

## Решение

В таблице будем хранить последний индекс каждого обработанного символа. При повторении символа сдвигаем левую границу окна сразу за его предыдущее вхождение. Граница может двигаться только вправо: предыдущее вхождение могло уже остаться за пределами текущего окна.

После добавления каждого символа сравниваем длину окна с максимальной найденной длиной.

## Код

```go
package main

import "fmt"

func noRepeatSubstring(text string) int {
	characters := []rune(text)
	lastIndex := make(map[rune]int)
	windowStart := 0
	maxLength := 0

	for windowEnd, character := range characters {
		if previousIndex, ok := lastIndex[character]; ok && previousIndex >= windowStart {
			windowStart = previousIndex + 1
		}
		lastIndex[character] = windowEnd

		windowLength := windowEnd - windowStart + 1
		if windowLength > maxLength {
			maxLength = windowLength
		}
	}

	return maxLength
}

func main() {
	fmt.Println("Длина самой длинной подстроки:", noRepeatSubstring("aabccbb"))
	fmt.Println("Длина самой длинной подстроки:", noRepeatSubstring("abbbb"))
	fmt.Println("Длина самой длинной подстроки:", noRepeatSubstring("abccde"))
}
```

**Вывод:**

```text
Длина самой длинной подстроки: 3
Длина самой длинной подстроки: 2
Длина самой длинной подстроки: 3
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — количество символов строки.

## Пространственная сложность

Срез `characters` занимает $$O(N)$$ памяти, а таблица последних индексов — $$O(K)$$, где $$K$$ — количество различных символов. Поскольку $$K \le N$$, общая пространственная сложность Go-реализации равна $$O(N)$$.

{% include algo-task-nav.html position="bottom" %}
