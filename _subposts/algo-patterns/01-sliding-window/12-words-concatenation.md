---
title: Конкатенация слов
description: Поиск начальных индексов подстрок, составленных из всех заданных слов ровно по одному разу.
pattern: sliding-window
permalink: /posts/algo-patterns-sliding-window/words-concatenation/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны строка и список слов одинаковой длины. Найдите все начальные индексы подстрок, которые являются конкатенацией всех заданных слов, взятых ровно по одному разу и без перекрытий.

**Пример 1:**

```text
Вход: строка="catfoxcat", слова=["cat", "fox"]
Выход: [0, 3]
Пояснение: подходят подстроки "catfox" и "foxcat".
```

**Пример 2:**

```text
Вход: строка="catcatfoxfox", слова=["cat", "fox"]
Выход: [3]
Пояснение: подходит только подстрока "catfox".
```

## Решение

Сохраним частоту каждого слова в таблице. Затем, начиная с каждого допустимого индекса строки, будем читать слова фиксированной длины:

1. Для текущего начального индекса заведём отдельную таблицу уже встреченных слов.
2. Если очередного слова нет в исходной таблице или оно встретилось чаще, чем требуется, перейдём к следующему начальному индексу.
3. Если удалось сопоставить все слова, добавим начальный индекс в результат.

## Код

```go
package main

import (
	"fmt"
	"unicode/utf8"
)

func findWordConcatenation(text string, words []string) []int {
	result := []int{}
	if len(text) == 0 || len(words) == 0 {
		return result
	}

	characters := []rune(text)
	wordLength := utf8.RuneCountInString(words[0])
	if wordLength == 0 {
		return result
	}

	wordsCount := len(words)
	concatenationLength := wordLength * wordsCount
	if concatenationLength > len(characters) {
		return result
	}

	wordFrequencies := make(map[string]int)
	for _, word := range words {
		if utf8.RuneCountInString(word) != wordLength {
			return result
		}
		wordFrequencies[word]++
	}

	for start := 0; start <= len(characters)-concatenationLength; start++ {
		seen := make(map[string]int)

		for wordIndex := 0; wordIndex < wordsCount; wordIndex++ {
			nextIndex := start + wordIndex*wordLength
			word := string(characters[nextIndex : nextIndex+wordLength])
			requiredCount, ok := wordFrequencies[word]
			if !ok {
				break
			}

			seen[word]++
			if seen[word] > requiredCount {
				break
			}

			if wordIndex == wordsCount-1 {
				result = append(result, start)
			}
		}
	}

	return result
}

func main() {
	fmt.Println(findWordConcatenation("catfoxcat", []string{"cat", "fox"}))
	fmt.Println(findWordConcatenation("catcatfoxfox", []string{"cat", "fox"}))
}
```

**Вывод:**

```text
[0 3]
[3]
```

## Временная сложность

Пусть $$N$$ — длина строки, $$M$$ — количество слов, а $$L$$ — длина одного слова. Алгоритм проверяет до $$M$$ слов длины $$L$$ для каждого начального индекса, поэтому временная сложность равна $$O(N \cdot M \cdot L)$$.

## Пространственная сложность

Срез рун и список результата занимают до $$O(N)$$ памяти, а две таблицы хранят не более $$M$$ слов. Поэтому общая пространственная сложность равна $$O(N+M)$$.

{% include algo-task-nav.html position="bottom" %}
