---
title: Перестановки регистра строки
description: Генерация вариантов строки с сохранением порядка символов и изменением регистра букв.
pattern: subsets
permalink: /posts/algo-patterns-subsets/letter-case-permutations/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дана строка. Найдите все её варианты, сохраняя последовательность символов, но меняя регистр букв.

**Пример 1:**

```text
Вход: "ad52"
Выход: "ad52", "Ad52", "aD52", "AD52"
```

**Пример 2:**

```text
Вход: "ab7c"
Выход: "ab7c", "Ab7c", "aB7c", "AB7c", "ab7C", "Ab7C", "aB7C", "AB7C"
```

## Решение

Задача следует паттерну «Подмножества» и похожа на генерацию перестановок. Поскольку порядок символов сохраняется, начнём с исходной строки и будем обрабатывать её символы по одному, переключая регистр текущей буквы во всех уже существующих вариантах.

Для `"ab7c"`:

1. Начинаем с `"ab7c"`.
2. Обрабатываем `a`: получаем `"ab7c"`, `"Ab7c"`.
3. Обрабатываем `b`: получаем `"ab7c"`, `"Ab7c"`, `"aB7c"`, `"AB7c"`.
4. Символ `7` — цифра, пропускаем его.
5. Обрабатываем `c`: к четырём существующим строкам добавляем `"ab7C"`, `"Ab7C"`, `"aB7C"`, `"AB7C"`.

При обработке `c` берём все варианты предыдущего шага и меняем в них регистр этой буквы, получая четыре новые строки.

[![Удвоение вариантов строки ab7c при изменении регистра каждой буквы](/assets/img/posts/2027-01-01-algo-patterns-subsets/letter-case-steps.svg)](/assets/img/posts/2027-01-01-algo-patterns-subsets/letter-case-steps.svg)

## Код

В Go строку преобразуем в срез рун, чтобы обращаться к символам по индексу. В примерах буквы имеют два варианта регистра.

{% raw %}
```go
package main

import (
	"fmt"
	"unicode"
)

func findLetterCaseStringPermutations(str string) []string {
	permutations := []string{str}
	for i, char := range []rune(str) {
		if !unicode.IsLetter(char) || unicode.ToUpper(char) == unicode.ToLower(char) {
			continue
		}
		n := len(permutations)
		for j := 0; j < n; j++ {
			chs := []rune(permutations[j])
			if unicode.IsUpper(chs[i]) {
				chs[i] = unicode.ToLower(chs[i])
			} else {
				chs[i] = unicode.ToUpper(chs[i])
			}
			permutations = append(permutations, string(chs))
		}
	}
	return permutations
}
func main() {
	fmt.Printf("Варианты регистра: %q\n", findLetterCaseStringPermutations("ad52"))
	fmt.Printf("Варианты регистра: %q\n", findLetterCaseStringPermutations("ab7c"))
}
```
{% endraw %}

**Вывод:**

```text
Варианты регистра: ["ad52" "Ad52" "aD52" "AD52"]
Варианты регистра: ["ab7c" "Ab7c" "aB7c" "AB7c" "ab7C" "Ab7C" "aB7C" "AB7C"]
```

## Временная сложность

Для строки длиной $$N$$ возможно не более $$2^N$$ вариантов. При обработке каждого варианта преобразование строки в срез символов и обратно занимает $$O(N)$$ времени. Общая временная сложность — $$O(N \cdot 2^N)$$.

## Пространственная сложность

Дополнительная память нужна для результата: до $$2^N$$ строк длиной $$N$$. Пространственная сложность — $$O(N \cdot 2^N)$$.

{% include algo-task-nav.html position="bottom" %}
