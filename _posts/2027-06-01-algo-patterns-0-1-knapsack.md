---
title: Алгосы от Влада, часть 15. Рюкзак 0/1
date: 2027-06-01 00:00:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
math: true
pattern: 0-1-knapsack
short_title: Рюкзак 0/1
primary_task_title: Рюкзак 0/1
primary_task_anchor: knapsack
---

* [Введение](/posts/algo-patterns/)
* [Скользящее окно](/posts/algo-patterns-sliding-window/)
* [Два указателя или итератор](/posts/algo-patterns-two-pointers/)
* [Быстрый и медленный указатель](/posts/algo-patterns-fast-slow-pointer/)
* [Мерж интервалов](/posts/algo-patterns-merge-intervals/)
* [Циклическая сортировка](/posts/algo-patterns-cyclic-sort/)
* [Инвертирование связанного списка на месте](/posts/algo-patterns-in-place-reversal-linked-list/)
* [Дерево BFS](/posts/algo-patterns-tree-breadth-first-search/)
* [Дерево DFS](/posts/algo-patterns-tree-depth-first-search/)
* [Две кучи](/posts/algo-patterns-two-heaps/)
* [Подмножества](/posts/algo-patterns-subsets/)
* [Модифицированный бинарный поиск](/posts/algo-patterns-modified-binary-search/)
* [Побитовый XOR](/posts/algo-patterns-bitwise-xor/)
* [Лучшие K элементов](/posts/algo-patterns-top-k-elements/)
* [K-way merge](/posts/algo-patterns-k-way-merge/)
* <b>Рюкзак 0/1</b>
* Топологическая сортировка

## Введение

Паттерн основан на классической задаче о рюкзаке: каждый предмет либо выбран один раз, либо пропущен. На её примере разберём динамическое программирование. Начнём с рекурсивного перебора и увидим повторяющиеся подзадачи. Затем сохраним их ответы с помощью мемоизации и перейдём к заполнению таблицы снизу вверх. В последующих задачах тот же выбор работает с суммами и количеством способов.

## Рюкзак 0/1 {#knapsack}

### Условие задачи

Даны веса и стоимости `N` предметов и вместимость рюкзака `C`. Выберите предметы с максимальной суммарной стоимостью так, чтобы их общий вес не превышал `C`. Каждый предмет можно взять один раз либо не брать.

Например, у Мэри есть фрукты:

| Предмет | Вес | Стоимость |
| --- | --- | --- |
| Яблоко | 2 | 4 |
| Апельсин | 3 | 5 |
| Банан | 1 | 3 |
| Дыня | 4 | 7 |

При вместимости `5` яблоко с апельсином дают стоимость `9`, яблоко с бананом — `7`, апельсин с бананом — `8`, банан с дыней — `10`. Последний вариант оптимален.

Для дальнейшего разбора используем также пример:

```text
Стоимости: [1, 6, 10, 16]
Веса:      [1, 2, 3, 5]
C = 7 → 22
C = 6 → 17
```

### Решение

Начнём с полного перебора. Для каждого предмета рассматриваем две ветви: включить его, если он помещается, либо пропустить. В обеих ветвях двигаемся к следующему индексу и выбираем большую стоимость. Когда предметы закончились или вместимость исчерпана, возвращаем `0`.

<details>
<summary>Пошаговые схемы из исходника</summary>
<div markdown="1">

![Дерево включения и исключения предметов рюкзака](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-tree-1.svg)

![Дерево включения и исключения предметов рюкзака](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-tree-2.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 1](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-01.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 2](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-02.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 3](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-03.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 4](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-04.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 5](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-05.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 6](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-06.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 7](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-07.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 8](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-08.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 9](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-09.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 10](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-10.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 11](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-11.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 12](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-12.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 13](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-13.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 14](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-14.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 15](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-15.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 16](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-16.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 17](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-17.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 18](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-18.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 19](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-19.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 20](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-20.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 21](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-21.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 22](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-22.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 23](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-23.svg)

![Дерево выбора предметов и заполнение таблицы рюкзака, шаг 24](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/knapsack-24.svg)

</div>
</details>

### Код

{% raw %}
```go
package main

import (
	"fmt"
)

func solveKnapsack(profits, weights []int, capacity int) int {
	if capacity <= 0 || len(profits) == 0 || len(profits) != len(weights) {
		return 0
	}
	return knapsackRecursive(profits, weights, capacity, 0)
}
func knapsackRecursive(profits, weights []int, capacity, currentIndex int) int {
	if capacity <= 0 || currentIndex >= len(profits) {
		return 0
	}
	profit1 := 0
	if weights[currentIndex] <= capacity {
		profit1 = profits[currentIndex] + knapsackRecursive(profits, weights, capacity-weights[currentIndex], currentIndex+1)
	}
	profit2 := knapsackRecursive(profits, weights, capacity, currentIndex+1)
	if profit1 > profit2 {
		return profit1
	}
	return profit2
}

func main() {
	profits, weights := []int{1, 6, 10, 16}, []int{1, 2, 3, 5}
	fmt.Println(solveKnapsack(profits, weights, 7))
	fmt.Println(solveKnapsack(profits, weights, 6))
	fmt.Println(solveKnapsack([]int{4, 5, 3, 7}, []int{2, 3, 1, 4}, 5))
}
```
{% endraw %}

**Вывод:**

```text
22
17
10
```

### Временная сложность

$$O(2^N)$$: дерево выбора имеет до двух ветвей на предмет.

### Пространственная сложность

$$O(N)$$ для стека рекурсии.

### Мемоизация: сверху вниз

Рекурсивная подзадача определяется `currentIndex` и оставшейся `capacity`. Например, состояние `c=4, i=3` достигается разными путями. Сохраняем ответ в `dp[i][c]`, чтобы не вычислять его повторно. Значение `-1` означает, что состояние ещё не решено.

#### Код

{% raw %}
```go
package main

import (
	"fmt"
)

func solveKnapsack(profits, weights []int, capacity int) int {
	if capacity <= 0 || len(profits) == 0 || len(profits) != len(weights) {
		return 0
	}
	dp := make([][]int, len(profits))
	for i := range dp {
		dp[i] = make([]int, capacity+1)
		for c := range dp[i] {
			dp[i][c] = -1
		}
	}
	return knapsackRecursive(dp, profits, weights, capacity, 0)
}
func knapsackRecursive(dp [][]int, profits, weights []int, capacity, currentIndex int) int {
	if capacity <= 0 || currentIndex >= len(profits) {
		return 0
	}
	if dp[currentIndex][capacity] != -1 {
		return dp[currentIndex][capacity]
	}
	profit1 := 0
	if weights[currentIndex] <= capacity {
		profit1 = profits[currentIndex] + knapsackRecursive(dp, profits, weights, capacity-weights[currentIndex], currentIndex+1)
	}
	profit2 := knapsackRecursive(dp, profits, weights, capacity, currentIndex+1)
	dp[currentIndex][capacity] = profit2
	if profit1 > profit2 {
		dp[currentIndex][capacity] = profit1
	}
	return dp[currentIndex][capacity]
}

func main() {
	profits, weights := []int{1, 6, 10, 16}, []int{1, 2, 3, 5}
	fmt.Println(solveKnapsack(profits, weights, 7))
	fmt.Println(solveKnapsack(profits, weights, 6))
	fmt.Println(solveKnapsack([]int{4, 5, 3, 7}, []int{2, 3, 1, 4}, 5))
}
```
{% endraw %}

**Вывод:**

```text
22
17
10
```

#### Временная сложность

$$O(NC)$$: по одному вычислению на состояние.

#### Пространственная сложность

$$O(NC+N)=O(NC)$$ для таблицы и стека.

### Динамическое программирование: снизу вверх

Таблица `dp[i][c]` хранит максимальную стоимость для первых `i` предметов и вместимости `c`. Нулевая строка соответствует отсутствию предметов.

Предмет можно пропустить: `dp[i-1][c]`. Если он помещается, можно взять его: `profits[i-1]+dp[i-1][c-weights[i-1]]`. Записываем максимум. Обе зависимости находятся в предыдущей строке, поэтому каждый предмет используется не более одного раза.

#### Код

{% raw %}
```go
package main

import (
	"fmt"
)

func knapsackTable(profits, weights []int, capacity int) [][]int {
	n := len(profits)
	dp := make([][]int, n+1)
	for i := range dp {
		dp[i] = make([]int, capacity+1)
	}
	for i := 1; i <= n; i++ {
		for c := 0; c <= capacity; c++ {
			dp[i][c] = dp[i-1][c]
			if weights[i-1] <= c {
				profit := profits[i-1] + dp[i-1][c-weights[i-1]]
				if profit > dp[i][c] {
					dp[i][c] = profit
				}
			}
		}
	}
	return dp
}
func solveKnapsack(profits, weights []int, capacity int) int {
	if capacity <= 0 || len(profits) == 0 || len(profits) != len(weights) {
		return 0
	}
	return knapsackTable(profits, weights, capacity)[len(profits)][capacity]
}

func main() {
	profits, weights := []int{1, 6, 10, 16}, []int{1, 2, 3, 5}
	fmt.Println(solveKnapsack(profits, weights, 7))
	fmt.Println(solveKnapsack(profits, weights, 6))
	fmt.Println(solveKnapsack([]int{4, 5, 3, 7}, []int{2, 3, 1, 4}, 5))
}
```
{% endraw %}

**Вывод:**

```text
22
17
10
```

#### Временная сложность

$$O(NC)$$.

#### Пространственная сложность

$$O(NC)$$.

### Восстановление выбранных предметов

Начинаем из правого нижнего угла. Если значение равно ячейке сверху, пропускаем предмет. Иначе берём его и уменьшаем текущую вместимость на его вес. В обоих случаях переходим к предыдущей строке.

Для стоимости `22` берём предмет `D` с весом `5` и стоимостью `16`, затем `B` с весом `2` и стоимостью `6`. Код возвращает индексы `[3, 1]` в обратном порядке.

#### Код

{% raw %}
```go
package main

import (
	"fmt"
)

func knapsackTable(profits, weights []int, capacity int) [][]int {
	n := len(profits)
	dp := make([][]int, n+1)
	for i := range dp {
		dp[i] = make([]int, capacity+1)
	}
	for i := 1; i <= n; i++ {
		for c := 0; c <= capacity; c++ {
			dp[i][c] = dp[i-1][c]
			if weights[i-1] <= c {
				profit := profits[i-1] + dp[i-1][c-weights[i-1]]
				if profit > dp[i][c] {
					dp[i][c] = profit
				}
			}
		}
	}
	return dp
}
func solveKnapsack(profits, weights []int, capacity int) int {
	if capacity <= 0 || len(profits) == 0 || len(profits) != len(weights) {
		return 0
	}
	return knapsackTable(profits, weights, capacity)[len(profits)][capacity]
}
func selectedItems(profits, weights []int, capacity int) []int {
	dp := knapsackTable(profits, weights, capacity)
	result := []int{}
	for i := len(profits); i > 0; i-- {
		if dp[i][capacity] != dp[i-1][capacity] {
			result = append(result, i-1)
			capacity -= weights[i-1]
		}
	}
	return result
}

func main() {
	profits, weights := []int{1, 6, 10, 16}, []int{1, 2, 3, 5}
	fmt.Println(solveKnapsack(profits, weights, 7))
	fmt.Println(selectedItems(profits, weights, 7))
}
```
{% endraw %}

**Вывод:**

```text
22
[3 1]
```

#### Временная сложность

Построение таблицы — $$O(NC)$$, восстановление — $$O(N)$$.

#### Пространственная сложность

$$O(NC)$$ для таблицы и до $$O(N)$$ для выбранных индексов.

### Оптимизация памяти: две строки

Для текущей строки нужна только предыдущая. Храним две строки и чередуем их через `i%2` и `(i-1)%2`. Перед вычислением новой строки её прежние значения полностью перезаписываются.

#### Код

{% raw %}
```go
package main

import (
	"fmt"
)

func solveKnapsack(profits, weights []int, capacity int) int {
	if capacity <= 0 || len(profits) == 0 || len(profits) != len(weights) {
		return 0
	}
	dp := [2][]int{make([]int, capacity+1), make([]int, capacity+1)}
	for i := 1; i <= len(profits); i++ {
		for c := 0; c <= capacity; c++ {
			dp[i%2][c] = dp[(i-1)%2][c]
			if weights[i-1] <= c {
				profit := profits[i-1] + dp[(i-1)%2][c-weights[i-1]]
				if profit > dp[i%2][c] {
					dp[i%2][c] = profit
				}
			}
		}
	}
	return dp[len(profits)%2][capacity]
}

func main() {
	profits, weights := []int{1, 6, 10, 16}, []int{1, 2, 3, 5}
	fmt.Println(solveKnapsack(profits, weights, 7))
	fmt.Println(solveKnapsack(profits, weights, 6))
	fmt.Println(solveKnapsack([]int{4, 5, 3, 7}, []int{2, 3, 1, 4}, 5))
}
```
{% endraw %}

**Вывод:**

```text
22
17
10
```

#### Временная сложность

$$O(NC)$$.

#### Пространственная сложность

$$O(2C)=O(C)$$.

### Оптимизация памяти: одна строка

Можно хранить обе строки в одном массиве, если перебирать вместимость **от большей к меньшей**. Тогда `dp[c-weights[i]]` ещё относится к предыдущему набору предметов. Прямой обход позволил бы повторно взять текущий предмет и изменил бы задачу.

#### Код

{% raw %}
```go
package main

import (
	"fmt"
)

func solveKnapsack(profits, weights []int, capacity int) int {
	if capacity <= 0 || len(profits) == 0 || len(profits) != len(weights) {
		return 0
	}
	dp := make([]int, capacity+1)
	for i := range profits {
		for c := capacity; c >= weights[i]; c-- {
			profit := profits[i] + dp[c-weights[i]]
			if profit > dp[c] {
				dp[c] = profit
			}
		}
	}
	return dp[capacity]
}

func main() {
	profits, weights := []int{1, 6, 10, 16}, []int{1, 2, 3, 5}
	fmt.Println(solveKnapsack(profits, weights, 7))
	fmt.Println(solveKnapsack(profits, weights, 6))
	fmt.Println(solveKnapsack([]int{4, 5, 3, 7}, []int{2, 3, 1, 4}, 5))
}
```
{% endraw %}

**Вывод:**

```text
22
17
10
```

#### Временная сложность

$$O(NC)$$.

#### Пространственная сложность

$$O(C)$$.

## Задачи главы

1. [Рюкзак 0/1](#knapsack)
2. [Разбиение на равные суммы](/posts/algo-patterns-0-1-knapsack/equal-subset-sum-partition/)
3. [Подмножество с заданной суммой](/posts/algo-patterns-0-1-knapsack/subset-sum/)
4. [Минимальная разность сумм](/posts/algo-patterns-0-1-knapsack/minimum-subset-sum-difference/)
5. [Количество подмножеств с заданной суммой](/posts/algo-patterns-0-1-knapsack/count-of-subset-sum/)
6. [Целевая сумма знаками плюс и минус](/posts/algo-patterns-0-1-knapsack/target-sum/)

## Похожие задания

1. Partition Equal Subset Sum [Leetcode](https://leetcode.com/problems/partition-equal-subset-sum/)
2. Target Sum [Leetcode](https://leetcode.com/problems/target-sum/)
