---
title: Самая длинная подстрока из одинаковых букв после замен
description: Поиск самой длинной подстроки, которую можно сделать однородной не более чем k заменами букв.
pattern: sliding-window
permalink: /posts/algo-patterns-sliding-window/longest-substring-same-letters-replacement/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дана строка, содержащая только строчные латинские ASCII-буквы. Разрешается заменить не более `k` букв на любые другие. Найдите длину самой длинной подстроки, которую после таких замен можно составить из одинаковых букв.

**Пример 1:**

```text
Вход: строка="aabccbb", k=2
Выход: 5
Пояснение: заменим две буквы 'c' на 'b' и получим "bbbbb".
```

**Пример 2:**

```text
Вход: строка="abbcb", k=1
Выход: 4
Пояснение: заменим 'c' на 'b' и получим "bbbb".
```

**Пример 3:**

```text
Вход: строка="abccde", k=1
Выход: 3
Пояснение: заменим 'b' или 'd' на 'c' и получим "ccc".
```

## Решение

Для текущего окна будем хранить частоты букв и максимальную частоту одной буквы — `maxRepeatLetterCount`. Остальные символы окна нужно заменить. Их количество равно:

```text
длина окна - maxRepeatLetterCount
```

Если это значение больше `k`, сдвигаем левую границу окна вправо. После каждого шага обновляем максимальную допустимую длину.

## Код

```go
package main

import "fmt"

func longestSubstringAfterReplacement(text string, k int) int {
	frequencies := [26]int{}
	windowStart := 0
	maxRepeatLetterCount := 0
	maxLength := 0

	for windowEnd := 0; windowEnd < len(text); windowEnd++ {
		index := text[windowEnd] - 'a'
		frequencies[index]++
		if frequencies[index] > maxRepeatLetterCount {
			maxRepeatLetterCount = frequencies[index]
		}

		if windowEnd-windowStart+1-maxRepeatLetterCount > k {
			leftIndex := text[windowStart] - 'a'
			frequencies[leftIndex]--
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
	fmt.Println(longestSubstringAfterReplacement("aabccbb", 2))
	fmt.Println(longestSubstringAfterReplacement("abbcb", 1))
	fmt.Println(longestSubstringAfterReplacement("abccde", 1))
}
```

**Вывод:**

```text
5
4
3
```

## Временная сложность

Временная сложность алгоритма равна $$O(N)$$, где $$N$$ — количество букв во входной строке.

## Пространственная сложность

Для частот строчных латинских букв используется массив фиксированного размера 26, поэтому пространственная сложность равна $$O(1)$$.

{% include algo-task-nav.html position="bottom" %}
