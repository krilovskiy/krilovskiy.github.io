---
title: Наименьшее окно, содержащее подстроку
description: Поиск наименьшей подстроки, содержащей все символы заданного шаблона с учётом повторений.
pattern: sliding-window
permalink: /posts/algo-patterns-sliding-window/smallest-window-containing-substring/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны строка и шаблон из ASCII-символов. Найдите наименьшую подстроку, которая содержит все символы шаблона.

**Пример 1:**

```text
Вход: строка="aabdec", шаблон="abc"
Выход: "abdec"
Пояснение: "abdec" — наименьшая подстрока, содержащая все символы шаблона.
```

**Пример 2:**

```text
Вход: строка="abdabca", шаблон="abc"
Выход: "abc"
```

**Пример 3:**

```text
Вход: строка="adcad", шаблон="abc"
Выход: ""
Пояснение: ни одна подстрока не содержит все символы шаблона.
```

## Решение

Как и в задаче о перестановке строки, сначала подсчитаем частоты символов шаблона. Однако искомая подстрока может содержать дополнительные символы и не обязана быть перестановкой шаблона.

Расширяя окно, считаем каждое совпавшее вхождение символа. Когда совпали все символы шаблона, сжимаем окно слева и запоминаем наименьшую длину. Лишние повторения можно удалить без уменьшения числа совпадений. Сжатие останавливается, когда из окна выходит требуемое вхождение символа.

## Код

```go
package main

import "fmt"

func smallestWindowContainingSubstring(text, pattern string) string {
	if len(text) == 0 || len(pattern) == 0 || len(pattern) > len(text) {
		return ""
	}

	frequencies := make(map[byte]int)
	for index := 0; index < len(pattern); index++ {
		character := pattern[index]
		frequencies[character]++
	}

	windowStart := 0
	matched := 0
	minLength := len(text) + 1
	resultStart := 0

	for windowEnd := 0; windowEnd < len(text); windowEnd++ {
		character := text[windowEnd]
		if _, ok := frequencies[character]; ok {
			frequencies[character]--
			if frequencies[character] >= 0 {
				matched++
			}
		}
		for matched == len(pattern) {
			windowLength := windowEnd - windowStart + 1
			if windowLength < minLength {
				minLength = windowLength
				resultStart = windowStart
			}

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

	if minLength == len(text)+1 {
		return ""
	}
	return text[resultStart : resultStart+minLength]
}

func main() {
	fmt.Println(smallestWindowContainingSubstring("aabdec", "abc"))
	fmt.Println(smallestWindowContainingSubstring("abdabca", "abc"))
	fmt.Printf("%q\n", smallestWindowContainingSubstring("adcad", "abc"))
}
```

**Вывод:**

```text
abdec
abc
""
```

## Временная сложность

Построение таблицы занимает $$O(M)$$, а каждый символ строки входит в окно и выходит из него не более одного раза. Общая временная сложность равна $$O(N+M)$$.

## Пространственная сложность

Таблица частот занимает $$O(M)$$ памяти. Результирующая подстрока является срезом исходной строки и не требует копирования её символов.

{% include algo-task-nav.html position="bottom" %}
