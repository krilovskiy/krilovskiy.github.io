---
title: Инопланетный словарь
description: Инопланетный словарь — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: topological-sort
permalink: /posts/algo-patterns-topological-sort/alien-dictionary/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Слова отсортированы лексикографически по правилам неизвестного алфавита. Восстановите допустимый порядок его символов.

```text
["ba", "bc", "ac", "cab"] → bac
["cab", "aaa", "aab"] → cab
["ywx", "wz", "xww", "xz", "zyy", "zwz"] → ywxz
```

## Решение

Сравниваем соседние слова до **первого** различающегося символа. Эта пара задаёт одно направленное ребро. Последующие символы уже не определяют порядок слов.

В первом примере `ba < bc` даёт `a → c`, а `bc < ac` — `b → a`; получается `bac`. Во втором имеем `c → a` и `a → b`. В третьем — `y → w`, `w → x`, `w → z`, `x → z` и повторное `y → w`.

Сначала регистрируем все символы, включая не участвующие в рёбрах, затем выполняем топологическую сортировку. Повторное правило учитывается и в списке смежности, и во входящей степени, поэтому баланс сохраняется. Для воспроизводимого выбора источников код хранит порядок первого появления символов.

При корректном словаре короткое слово стоит раньше своего продолжения. В коде отдельно отклоняется невозможный порядок вроде `["abc","ab"]`. Цикл также означает отсутствие допустимого алфавита.

## Код

{% raw %}
```go
package main

import (
	"fmt"
)

func findOrder(words []string) string {
	graph := map[rune][]rune{}
	inDegree := map[rune]int{}
	characters := []rune{}
	for _, word := range words {
		for _, c := range word {
			if _, ok := inDegree[c]; !ok {
				inDegree[c] = 0
				characters = append(characters, c)
			}
		}
	}
	for i := 0; i+1 < len(words); i++ {
		first, second := []rune(words[i]), []rune(words[i+1])
		j := 0
		for j < len(first) && j < len(second) && first[j] == second[j] {
			j++
		}
		if j == len(second) && len(first) > len(second) {
			return ""
		}
		if j < len(first) && j < len(second) {
			parent, child := first[j], second[j]
			graph[parent] = append(graph[parent], child)
			inDegree[child]++
		}
	}
	sources := []rune{}
	for _, c := range characters {
		if inDegree[c] == 0 {
			sources = append(sources, c)
		}
	}
	sortedOrder := []rune{}
	for head := 0; head < len(sources); head++ {
		vertex := sources[head]
		sortedOrder = append(sortedOrder, vertex)
		for _, child := range graph[vertex] {
			inDegree[child]--
			if inDegree[child] == 0 {
				sources = append(sources, child)
			}
		}
	}
	if len(sortedOrder) != len(inDegree) {
		return ""
	}
	return string(sortedOrder)
}

func main() {
	fmt.Println(findOrder([]string{"ba", "bc", "ac", "cab"}))
	fmt.Println(findOrder([]string{"cab", "aaa", "aab"}))
	fmt.Println(findOrder([]string{"ywx", "wz", "xww", "xz", "zyy", "zwz"}))
}
```
{% endraw %}

**Вывод:**

```text
bac
cab
ywxz
```

## Временная сложность

Сортировка графа — $$O(V+E)$$. Соседние слова дают не более $$N-1$$ правил, поэтому исходник оценивает эту фазу как $$O(V+N)$$. Полный алгоритм также читает символы: $$O(L+V+N)$$, где `L` — их суммарное количество.

## Пространственная сложность

Граф и очередь — $$O(V+N)$$. Преобразование двух текущих слов в `[]rune` дополнительно требует $$O(W)$$, где `W` — максимальная длина слова.

{% include algo-task-nav.html position="bottom" %}
