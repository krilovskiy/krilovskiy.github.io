---
title: Подмножество с заданной суммой
description: Подмножество с заданной суммой — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: 0-1-knapsack
permalink: /posts/algo-patterns-0-1-knapsack/subset-sum/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Для набора положительных чисел определите, существует ли подмножество с суммой `S`.

```text
[1, 2, 3, 7], S = 6 → true: [1, 2, 3]
[1, 2, 7, 1, 5], S = 10 → true: [1, 2, 7]
[1, 3, 4, 8], S = 6 → false
```

## Решение

Полный перебор аналогичен равному разбиению: включаем или пропускаем каждое число и проверяем остаток суммы. Его время — $$O(2^N)$$, стек — $$O(N)$$. В исходнике после этого сразу строится решение снизу вверх.

`dp[i][s]` хранит достижимость суммы `s` первыми `i` числами. Пустое подмножество даёт `0`. Число можно пропустить или, если оно не больше `s`, включить и проверить оставшуюся сумму в предыдущей строке.

<details>
<summary>Пошаговые схемы из исходника</summary>
<div markdown="1">

![Построение таблицы достижимых сумм, шаг 1](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/subset-sum-01.svg)

![Построение таблицы достижимых сумм, шаг 2](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/subset-sum-02.svg)

![Построение таблицы достижимых сумм, шаг 3](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/subset-sum-03.svg)

![Построение таблицы достижимых сумм, шаг 4](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/subset-sum-04.svg)

![Построение таблицы достижимых сумм, шаг 5](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/subset-sum-05.svg)

![Построение таблицы достижимых сумм, шаг 6](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/subset-sum-06.svg)

![Построение таблицы достижимых сумм, шаг 7](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/subset-sum-07.svg)

![Построение таблицы достижимых сумм, шаг 8](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/subset-sum-08.svg)

![Построение таблицы достижимых сумм, шаг 9](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/subset-sum-09.svg)

![Построение таблицы достижимых сумм, шаг 10](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/subset-sum-10.svg)

</div>
</details>

## Код

{% raw %}
```go
package main

import (
	"fmt"
)

func canPartition(num []int, sum int) bool { return subsetTable(num, sum)[len(num)][sum] }
func subsetTable(num []int, sum int) [][]bool {
	dp := make([][]bool, len(num)+1)
	for i := range dp {
		dp[i] = make([]bool, sum+1)
		dp[i][0] = true
	}
	for i := 1; i <= len(num); i++ {
		for s := 1; s <= sum; s++ {
			dp[i][s] = dp[i-1][s]
			if !dp[i][s] && num[i-1] <= s {
				dp[i][s] = dp[i-1][s-num[i-1]]
			}
		}
	}
	return dp
}

func main() {
	fmt.Println(canPartition([]int{1, 2, 3, 7}, 6))
	fmt.Println(canPartition([]int{1, 2, 7, 1, 5}, 10))
	fmt.Println(canPartition([]int{1, 3, 4, 8}, 6))
}
```
{% endraw %}

**Вывод:**

```text
true
true
false
```

## Временная сложность

$$O(NS)$$.

## Пространственная сложность

$$O(NS)$$.

## Оптимизация памяти

Оставляем один массив. Перебираем суммы от `S` вниз, чтобы значение `dp[s-num[i]]` ещё не учитывало текущий элемент. Это сохраняет ограничение «каждое вхождение используется один раз».

### Код

{% raw %}
```go
package main

import (
	"fmt"
)

func canPartition(num []int, sum int) bool {
	dp := make([]bool, sum+1)
	dp[0] = true
	for _, n := range num {
		for s := sum; s >= n; s-- {
			if !dp[s] {
				dp[s] = dp[s-n]
			}
		}
	}
	return dp[sum]
}

func main() {
	fmt.Println(canPartition([]int{1, 2, 3, 7}, 6))
	fmt.Println(canPartition([]int{1, 2, 7, 1, 5}, 10))
	fmt.Println(canPartition([]int{1, 3, 4, 8}, 6))
}
```
{% endraw %}

**Вывод:**

```text
true
true
false
```

### Временная сложность

$$O(NS)$$.

### Пространственная сложность

$$O(S)$$.

{% include algo-task-nav.html position="bottom" %}
