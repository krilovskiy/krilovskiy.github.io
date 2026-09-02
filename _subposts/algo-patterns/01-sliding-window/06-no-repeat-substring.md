---
title: Самая длинная подстрока без повторяющихся символов
description: Поиск длины самой длинной подстроки, в которой ни один символ не повторяется.
pattern: sliding-window
permalink: /posts/algo-patterns-sliding-window/no-repeat-substring/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дана строка из ASCII-символов. Найдите длину самой длинной подстроки без повторяющихся символов.

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
	lastIndex := make(map[byte]int)
	windowStart := 0
	maxLength := 0

	for windowEnd := 0; windowEnd < len(text); windowEnd++ {
		character := text[windowEnd]
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

Пространственная сложность равна $$O(K)$$, где $$K$$ — количество различных символов во входной строке. Если алфавит имеет фиксированный размер, эту сложность можно считать равной $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
