---
title: Перестановки
description: Генерация всех перестановок различных чисел с помощью BFS и рекурсии.
pattern: subsets
permalink: /posts/algo-patterns-subsets/permutations/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан набор различных чисел. Найдите все его перестановки.

Перестановка — это изменение порядка элементов набора. Например, у `{1, 2, 3}` есть шесть перестановок: `{1, 2, 3}`, `{1, 3, 2}`, `{2, 1, 3}`, `{2, 3, 1}`, `{3, 1, 2}` и `{3, 2, 1}`. У набора из $$N$$ различных элементов всего $$N!$$ перестановок.

**Пример:**

```text
Вход: [1, 3, 5]
Выход: [1, 3, 5], [1, 5, 3], [3, 1, 5], [3, 5, 1], [5, 1, 3], [5, 3, 1]
```

## Решение

Применим подход BFS из паттерна «Подмножества». Каждая перестановка должна содержать все числа, поэтому очередное число вставляем во все возможные позиции каждой перестановки предыдущего уровня.

Для `[1, 3, 5]` получим:

1. Начинаем с одной пустой перестановки: `[[]]`.
2. После `1` получаем `[[1]]`.
3. Вставляем `3` до и после `1`: `[[3, 1], [1, 3]]`.
4. В каждую из этих перестановок вставляем `5` во все три позиции: `[[5, 3, 1], [3, 5, 1], [3, 1, 5], [5, 1, 3], [1, 5, 3], [1, 3, 5]]`.

Например, для `[3, 1]` вставка `5` перед `3` даёт `[5, 3, 1]`, между `3` и `1` — `[3, 5, 1]`, после `1` — `[3, 1, 5]`.

[![Вставка чисел 1, 3 и 5 во все позиции для получения шести перестановок](/assets/img/posts/2027-01-01-algo-patterns-subsets/permutations-steps.svg)](/assets/img/posts/2027-01-01-algo-patterns-subsets/permutations-steps.svg)

Промежуточные перестановки храним в очереди `permutations`. Когда длина новой перестановки равна длине исходного набора, добавляем её в `result`.

## Код

{% raw %}
```go
package main

import "fmt"

func findPermutations(nums []int) [][]int {
	numsLength := len(nums)
	if numsLength == 0 {
		return [][]int{{}}
	}
	result := [][]int{}
	permutations := [][]int{{}}
	for _, currentNumber := range nums {
		n := len(permutations)
		for i := 0; i < n; i++ {
			oldPermutation := permutations[0]
			permutations[0] = nil
			permutations = permutations[1:]
			for j := 0; j <= len(oldPermutation); j++ {
				newPermutation := make([]int, len(oldPermutation)+1)
				copy(newPermutation, oldPermutation[:j])
				newPermutation[j] = currentNumber
				copy(newPermutation[j+1:], oldPermutation[j:])
				if len(newPermutation) == numsLength {
					result = append(result, newPermutation)
				} else {
					permutations = append(permutations, newPermutation)
				}
			}
		}
	}
	return result
}
func main() {
	fmt.Println("Перестановки:", findPermutations([]int{1, 3, 5}))
}
```
{% endraw %}

**Вывод:**

```text
Перестановки: [[5 3 1] [3 5 1] [3 1 5] [5 1 3] [1 5 3] [1 3 5]]
```

## Временная сложность

Всего создаётся $$N!$$ перестановок. Вставка числа с копированием перестановки занимает $$O(N)$$ времени. Общая временная сложность — $$O(N \cdot N!)$$.

## Пространственная сложность

Результат и очередь промежуточных перестановок вместе содержат не более $$N!$$ перестановок, каждая длиной до $$N$$. Пространственная сложность — $$O(N \cdot N!)$$.

## Рекурсивное решение

В оригинале приведён и рекурсивный вариант того же подхода. На каждом вызове вставляем очередное число во все позиции текущей перестановки и рекурсивно обрабатываем следующий элемент. Когда все числа использованы, сохраняем перестановку.

{% raw %}
```go
package main

import "fmt"

func generatePermutations(nums []int) [][]int {
	result := [][]int{}
	generatePermutationsRecursive(nums, 0, []int{}, &result)
	return result
}
func generatePermutationsRecursive(nums []int, index int, currentPermutation []int, result *[][]int) {
	if index == len(nums) {
		*result = append(*result, currentPermutation)
		return
	}
	for i := 0; i <= len(currentPermutation); i++ {
		newPermutation := make([]int, len(currentPermutation)+1)
		copy(newPermutation, currentPermutation[:i])
		newPermutation[i] = nums[index]
		copy(newPermutation[i+1:], currentPermutation[i:])
		generatePermutationsRecursive(nums, index+1, newPermutation, result)
	}
}
func main() {
	fmt.Println("Перестановки:", generatePermutations([]int{1, 3, 5}))
}
```
{% endraw %}

**Вывод:**

```text
Перестановки: [[5 3 1] [3 5 1] [3 1 5] [5 1 3] [1 5 3] [1 3 5]]
```

{% include algo-task-nav.html position="bottom" %}
