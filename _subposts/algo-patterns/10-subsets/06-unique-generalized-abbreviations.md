---
title: Уникальные обобщённые сокращения
description: Генерация сокращений слова заменой последовательностей букв их длиной.
pattern: subsets
permalink: /posts/algo-patterns-subsets/unique-generalized-abbreviations/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дано слово. Напишите функцию, которая генерирует все его уникальные обобщённые сокращения.

Обобщённое сокращение получается заменой подстрок количеством символов в них. Например, у `"ab"` можно заменить пустую подстроку, `"a"`, `"b"` или `"ab"`. Получим `"ab"`, `"1b"`, `"a1"` и `"2"`.

**Пример 1:**

```text
Вход: "BAT"
Выход: "BAT", "BA1", "B1T", "B2", "1AT", "1A1", "2T", "3"
```

**Пример 2:**

```text
Вход: "code"
Выход: "code", "cod1", "co1e", "co2", "c1de", "c1d1", "c2e", "c3",
       "1ode", "1od1", "1o1e", "1o2", "2de", "2d1", "3e", "4"
```

## Решение

Задача следует паттерну «Подмножества» и похожа на задачу со сбалансированными скобками. Используем BFS: для каждого очередного символа выбираем один из двух вариантов:

1. Сократить символ, увеличив счётчик текущей сокращаемой последовательности.
2. Сохранить символ, записав перед ним накопленный счётчик, если он ненулевой.

Для `BAT`:

1. Начинаем с пустого слова.
2. После `B` получаем `_` и `B`, где `_` обозначает сокращённый символ, ещё не записанный числом.
3. После `A` из `_` получаем `__` и `1A`, а из `B` — `B_` и `BA`.
4. После `T` получаем `___`, `2T`, `1A_`, `1AT`, `B__`, `B1T`, `BA_`, `BAT`.
5. Записываем оставшиеся счётчики: `3`, `2T`, `1A1`, `1AT`, `B2`, `B1T`, `BA1`, `BAT`.

[![Два выбора для каждой буквы BAT: сократить её или оставить в слове](/assets/img/posts/2027-01-01-algo-patterns-subsets/generalized-abbreviations-steps.svg)](/assets/img/posts/2027-01-01-algo-patterns-subsets/generalized-abbreviations-steps.svg)

В очереди храним `AbbreviatedWord`: построенную часть `str`, индекс следующего символа `start` и количество подряд сокращённых символов `count`. При сохранении буквы счётчик сбрасываем в ноль; при завершении слова добавляем его в строку, если он остался ненулевым.

## Код

{% raw %}
```go
package main

import (
	"fmt"
	"strconv"
)

type AbbreviatedWord struct {
	str   string
	start int
	count int
}

func generateGeneralizedAbbreviation(word string) []string {
	chars := []rune(word)
	wordLen := len(chars)
	result := []string{}
	queue := []AbbreviatedWord{{}}
	for len(queue) > 0 {
		abWord := queue[0]
		queue[0] = AbbreviatedWord{}
		queue = queue[1:]
		if abWord.start == wordLen {
			if abWord.count != 0 {
				abWord.str += strconv.Itoa(abWord.count)
			}
			result = append(result, abWord.str)
		} else {
			queue = append(queue, AbbreviatedWord{abWord.str, abWord.start + 1, abWord.count + 1})
			if abWord.count != 0 {
				abWord.str += strconv.Itoa(abWord.count)
			}
			newWord := abWord.str + string(chars[abWord.start])
			queue = append(queue, AbbreviatedWord{newWord, abWord.start + 1, 0})
		}
	}
	return result
}
func main() {
	fmt.Printf("Сокращения: %q\n", generateGeneralizedAbbreviation("BAT"))
	fmt.Printf("Сокращения: %q\n", generateGeneralizedAbbreviation("code"))
}
```
{% endraw %}

**Вывод:**

```text
Сокращения: ["3" "2T" "1A1" "1AT" "B2" "B1T" "BA1" "BAT"]
Сокращения: ["4" "3e" "2d1" "2de" "1o2" "1o1e" "1od1" "1ode" "c3" "c2e" "c1d1" "c1de" "co2" "co1e" "cod1" "code"]
```

## Временная сложность

Для каждого из $$N$$ символов есть два варианта, поэтому всего получится $$2^N$$ сокращений. Дерево вариантов содержит $$2^N$$ листьев и $$2^N-1$$ промежуточных узлов, то есть обрабатывается $$O(2^N)$$ состояний.

При обработке состояния приходится строить строку длиной до $$N$$. Общая временная сложность — $$O(N \cdot 2^N)$$.

## Пространственная сложность

Результат содержит $$2^N$$ строк длиной до $$N$$. Пространственная сложность — $$O(N \cdot 2^N)$$.

## Рекурсивное решение

В оригинале есть и рекурсивный вариант. Вместо помещения двух состояний в очередь выполняем два рекурсивных вызова: продолжаем сокращать или сохраняем текущую букву. Правила записи и сброса `count` остаются теми же.

{% raw %}
```go
package main

import (
	"fmt"
	"strconv"
)

func generateGeneralizedAbbreviation(word string) []string {
	result := []string{}
	generateAbbreviationRecursive([]rune(word), "", 0, 0, &result)
	return result
}
func generateAbbreviationRecursive(word []rune, abWord string, start, count int, result *[]string) {
	if start == len(word) {
		if count != 0 {
			abWord += strconv.Itoa(count)
		}
		*result = append(*result, abWord)
		return
	}
	generateAbbreviationRecursive(word, abWord, start+1, count+1, result)
	if count != 0 {
		abWord += strconv.Itoa(count)
	}
	newWord := abWord + string(word[start])
	generateAbbreviationRecursive(word, newWord, start+1, 0, result)
}
func main() {
	fmt.Printf("Сокращения: %q\n", generateGeneralizedAbbreviation("BAT"))
	fmt.Printf("Сокращения: %q\n", generateGeneralizedAbbreviation("code"))
}
```
{% endraw %}

**Вывод:**

```text
Сокращения: ["3" "2T" "1A1" "1AT" "B2" "B1T" "BA1" "BAT"]
Сокращения: ["4" "3e" "2d1" "2de" "1o2" "1o1e" "1od1" "1ode" "c3" "c2e" "c1d1" "c1de" "co2" "co1e" "cod1" "code"]
```

{% include algo-task-nav.html position="bottom" %}
