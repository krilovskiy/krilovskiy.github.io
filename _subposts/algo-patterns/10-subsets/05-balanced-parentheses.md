---
title: Сбалансированные скобки
description: Генерация всех сбалансированных последовательностей из N пар скобок.
pattern: subsets
permalink: /posts/algo-patterns-subsets/balanced-parentheses/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Для заданного числа $$N$$ напишите функцию, которая генерирует все комбинации из $$N$$ пар сбалансированных круглых скобок.

**Пример 1:**

```text
Вход: N = 2
Выход: (()), ()()
```

**Пример 2:**

```text
Вход: N = 3
Выход: ((())), (()()), (())(), ()(()), ()()()
```

В четвёртом варианте примера исправлена опечатка исходника: правильная последовательность — `()(())`. Именно её строит исходное решение.

## Решение

Задача следует паттерну «Подмножества» и похожа на генерацию перестановок. Применим BFS, добавляя на каждом шаге открывающую `(` или закрывающую `)` скобку.

Соблюдаем два правила:

1. Нельзя добавить больше $$N$$ открывающих скобок.
2. Закрывающую скобку можно добавить, только если открывающих скобок уже больше, чем закрывающих.

Вместе с каждой строкой храним счётчики `openCount` и `closeCount`. Для $$N=3$$ уровни будут такими:

1. Начинаем с пустой строки `""`.
2. Можно добавить только `(`: открывающих меньше трёх, а для `)` ещё нет пары.
3. Из `(` получаем `((` и `()`.
4. Из `((` получаем `(((` и `(()`, а из `()` — только `()(`. Закрывающую скобку к `()` добавить нельзя.
5. Следующий уровень: `((()`, `(()(`, `(())`, `()((`, `()()`.
6. Затем: `((())`, `(()()`, `(())(`, `()(()`, `()()(`.
7. Наконец: `((()))`, `(()())`, `(())()`, `()(())`, `()()()`.

У всех последних строк использованы три открывающие и три закрывающие скобки, поэтому добавляем их в результат.

[![Дерево допустимых префиксов для трёх пар сбалансированных скобок](/assets/img/posts/2027-01-01-algo-patterns-subsets/balanced-parentheses-steps.svg)](/assets/img/posts/2027-01-01-algo-patterns-subsets/balanced-parentheses-steps.svg)

## Код

{% raw %}
```go
package main

import "fmt"

type ParenthesesString struct {
	str        string
	openCount  int
	closeCount int
}

func generateValidParentheses(num int) []string {
	result := []string{}
	queue := []ParenthesesString{{}}
	for len(queue) > 0 {
		ps := queue[0]
		queue[0] = ParenthesesString{}
		queue = queue[1:]
		if ps.openCount == num && ps.closeCount == num {
			result = append(result, ps.str)
		} else {
			if ps.openCount < num {
				queue = append(queue, ParenthesesString{ps.str + "(", ps.openCount + 1, ps.closeCount})
			}
			if ps.openCount > ps.closeCount {
				queue = append(queue, ParenthesesString{ps.str + ")", ps.openCount, ps.closeCount + 1})
			}
		}
	}
	return result
}
func main() {
	fmt.Printf("Скобочные последовательности: %q\n", generateValidParentheses(2))
	fmt.Printf("Скобочные последовательности: %q\n", generateValidParentheses(3))
}
```
{% endraw %}

**Вывод:**

```text
Скобочные последовательности: ["(())" "()()"]
Скобочные последовательности: ["((()))" "(()())" "(())()" "()(())" "()()()"]
```

## Временная сложность

В оригинале предлагается приблизительная оценка $$O(N \cdot 2^N)$$: дерево вариантов сравнивается с двоичным деревом, а добавление скобки к строке требует $$O(N)$$ времени. Эта оценка не является корректной верхней границей, если $$N$$ обозначает число пар: в последовательности $$2N$$ позиций.

Там же приводится более точная оценка $$O(4^N / \sqrt{N})$$, связанная с числами Каталана. Она учитывает количество сбалансированных последовательностей и длину строк. Для приведённой реализации используем эту оценку.

## Пространственная сложность

В оригинале память приближённо оценивается как $$O(N \cdot 2^N)$$. С учётом числа пар и хранения строк в результате и очереди корректная оценка для показанного BFS-кода — $$O(4^N / \sqrt{N})$$.

## Рекурсивное решение

Оригинал также содержит рекурсивный вариант с теми же двумя правилами. Вместо очереди используем массив символов длиной $$2N$$. В допустимую позицию записываем `(` или `)` и переходим к следующему индексу. Готовую последовательность копируем в результат.

{% raw %}
```go
package main

import "fmt"

func generateValidParentheses(num int) []string {
	result := []string{}
	parenthesesString := make([]byte, 2*num)
	generateValidParenthesesRec(num, 0, 0, parenthesesString, 0, &result)
	return result
}
func generateValidParenthesesRec(num, openCount, closeCount int, parenthesesString []byte, index int, result *[]string) {
	if openCount == num && closeCount == num {
		*result = append(*result, string(parenthesesString))
		return
	}
	if openCount < num {
		parenthesesString[index] = '('
		generateValidParenthesesRec(num, openCount+1, closeCount, parenthesesString, index+1, result)
	}
	if openCount > closeCount {
		parenthesesString[index] = ')'
		generateValidParenthesesRec(num, openCount, closeCount+1, parenthesesString, index+1, result)
	}
}
func main() {
	fmt.Printf("Скобочные последовательности: %q\n", generateValidParentheses(2))
	fmt.Printf("Скобочные последовательности: %q\n", generateValidParentheses(3))
}
```
{% endraw %}

**Вывод:**

```text
Скобочные последовательности: ["(())" "()()"]
Скобочные последовательности: ["((()))" "(()())" "(())()" "()(())" "()()()"]
```

{% include algo-task-nav.html position="bottom" %}
