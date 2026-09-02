---
title: Конкатенация слов
description: Поиск начальных индексов подстрок, составленных из всех заданных слов ровно по одному разу.
pattern: sliding-window
permalink: /posts/algo-patterns-sliding-window/words-concatenation/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Даны строка из ASCII-символов и список ASCII-слов одинаковой длины. Найдите все начальные индексы подстрок, которые являются конкатенацией всех заданных слов, взятых ровно по одному разу и без перекрытий.

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

import "fmt"

func findWordConcatenation(text string, words []string) []int {
	result := []int{}
	if len(text) == 0 || len(words) == 0 {
		return result
	}

	wordLength := len(words[0])
	if wordLength == 0 {
		return result
	}

	wordsCount := len(words)
	concatenationLength := wordLength * wordsCount
	if concatenationLength > len(text) {
		return result
	}

	wordFrequencies := make(map[string]int)
	for _, word := range words {
		if len(word) != wordLength {
			return result
		}
		wordFrequencies[word]++
	}

	for start := 0; start <= len(text)-concatenationLength; start++ {
		seen := make(map[string]int)

		for wordIndex := 0; wordIndex < wordsCount; wordIndex++ {
			nextIndex := start + wordIndex*wordLength
			word := text[nextIndex : nextIndex+wordLength]
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

Две таблицы хранят не более $$M$$ слов. В худшем случае список результата содержит $$O(N)$$ индексов, поэтому общая пространственная сложность равна $$O(M+N)$$.

{% include algo-task-nav.html position="bottom" %}
