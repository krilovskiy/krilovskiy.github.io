---
title: Перестановка строки
description: Проверка наличия в строке подстроки, являющейся перестановкой заданного шаблона.
pattern: sliding-window
permalink: /posts/algo-patterns-sliding-window/permutation-in-string/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны строка и шаблон из ASCII-символов. Определите, содержит ли строка какую-либо перестановку символов шаблона.

Перестановка получается изменением порядка символов. Например, у строки `abc` есть шесть перестановок: `abc`, `acb`, `bac`, `bca`, `cab` и `cba`.

**Пример 1:**

```text
Вход: строка="oidbcaf", шаблон="abc"
Выход: true
Пояснение: строка содержит "bca" — перестановку шаблона.
```

**Пример 2:**

```text
Вход: строка="odicf", шаблон="dc"
Выход: false
Пояснение: строка не содержит перестановку шаблона.
```

**Пример 3:**

```text
Вход: строка="bcdxabcdy", шаблон="bcdyabcdx"
Выход: true
Пояснение: строка и шаблон являются перестановками друг друга.
```

**Пример 4:**

```text
Вход: строка="aaacb", шаблон="abc"
Выход: true
Пояснение: строка содержит перестановку "acb".
```

## Решение

Сначала подсчитаем частоты всех символов шаблона. Затем будем перемещать по строке окно длиной, равной длине шаблона:

1. Если входящий символ есть в таблице, уменьшаем его частоту. Нулевая частота означает, что все вхождения этого символа совпали.
2. Когда совпали все различные символы шаблона, окно содержит искомую перестановку.
3. Достигнув нужного размера окна, удаляем его левый символ. Если этот символ относится к шаблону, восстанавливаем его частоту и при необходимости уменьшаем число полных совпадений.

## Код

```go
package main

import "fmt"

func containsPermutation(text, pattern string) bool {
	if len(pattern) == 0 || len(pattern) > len(text) {
		return false
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
			return true
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

	return false
}

func main() {
	fmt.Println("Перестановка существует:", containsPermutation("oidbcaf", "abc"))
	fmt.Println("Перестановка существует:", containsPermutation("odicf", "dc"))
	fmt.Println("Перестановка существует:", containsPermutation("bcdxabcdy", "bcdyabcdx"))
	fmt.Println("Перестановка существует:", containsPermutation("aaacb", "abc"))
}
```

**Вывод:**

```text
Перестановка существует: true
Перестановка существует: false
Перестановка существует: true
Перестановка существует: true
```

## Временная сложность

Построение таблицы занимает $$O(M)$$, а проход по строке — $$O(N)$$. Общая временная сложность равна $$O(N+M)$$.

## Пространственная сложность

В худшем случае все символы шаблона различны, поэтому пространственная сложность равна $$O(M)$$.

{% include algo-task-nav.html position="bottom" %}
