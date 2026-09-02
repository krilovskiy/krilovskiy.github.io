---
title: Сравнение строк с символами возврата
description: Сравнение двух строк с символами возврата без построения промежуточных строк.
pattern: two-pointers
permalink: /posts/algo-patterns-two-pointers/comparing-strings-with-backspaces/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны две строки, состоящие только из ASCII-символов. Символ `#` означает возврат с удалением предыдущего символа. Проверьте, равны ли строки после применения всех возвратов.

**Пример 1:**

```text
Вход: str1="xy#z", str2="xzz#"
Выход: true
Пояснение: обе строки превращаются в "xz".
```

**Пример 2:**

```text
Вход: str1="xy#z", str2="xyz#"
Выход: false
Пояснение: строки превращаются в "xz" и "xy".
```

**Пример 3:**

```text
Вход: str1="xp#", str2="xyz##"
Выход: true
Пояснение: обе строки превращаются в "x".
```

**Пример 4:**

```text
Вход: str1="xywrrmp", str2="xywrrmu#p"
Выход: true
Пояснение: обе строки превращаются в "xywrrmp".
```

## Решение

Идём с конца обеих строк. Для каждого указателя считаем встретившиеся `#` и пропускаем соответствующее число обычных символов, пока не получим следующий действующий символ.

Если действующие символы различаются или одна строка закончилась раньше другой, строки не равны. Если оба указателя одновременно вышли за начало строк, сравнение успешно. Промежуточные строки создавать не нужно.

## Код

```go
package main

import "fmt"

func nextValidCharacterIndex(value string, index int) int {
	backspaces := 0
	for index >= 0 {
		switch {
		case value[index] == '#':
			backspaces++
		case backspaces > 0:
			backspaces--
		default:
			return index
		}
		index--
	}
	return -1
}

func compareWithBackspaces(first, second string) bool {
	firstIndex, secondIndex := len(first)-1, len(second)-1

	for firstIndex >= 0 || secondIndex >= 0 {
		firstIndex = nextValidCharacterIndex(first, firstIndex)
		secondIndex = nextValidCharacterIndex(second, secondIndex)

		if firstIndex < 0 && secondIndex < 0 {
			return true
		}
		if firstIndex < 0 || secondIndex < 0 || first[firstIndex] != second[secondIndex] {
			return false
		}

		firstIndex--
		secondIndex--
	}

	return true
}

func main() {
	fmt.Println(compareWithBackspaces("xy#z", "xzz#"))
	fmt.Println(compareWithBackspaces("xy#z", "xyz#"))
	fmt.Println(compareWithBackspaces("xp#", "xyz##"))
	fmt.Println(compareWithBackspaces("xywrrmp", "xywrrmu#p"))
}
```

**Вывод:**

```text
true
false
true
true
```

## Временная сложность

Каждый символ обеих строк обрабатывается не более одного раза, поэтому временная сложность равна $$O(M+N)$$, где $$M$$ и $$N$$ — длины строк.

## Пространственная сложность

Алгоритм использует постоянный объём дополнительной памяти, поэтому пространственная сложность равна $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
