---
title: Целевая сумма знаками плюс и минус
description: Целевая сумма знаками плюс и минус — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: 0-1-knapsack
permalink: /posts/algo-patterns-0-1-knapsack/target-sum/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Каждому положительному числу присвойте знак `+` или `-`. Сколько способов получить целевую сумму `S`?

```text
[1, 1, 2, 3], S = 1 → 3
[1, 2, 7, 1], S = 9 → 2
```

Первый пример: `+1-1-2+3`, `-1+1-2+3`, `+1+1+2-3`. Второй: `+1+2+7-1`, `-1+2+7+1`.

## Решение

Положительные и отрицательные слагаемые образуют два подмножества с суммами `sum1` и `sum2`. Обозначим сумму всех чисел через `total`.

$$sum1-sum2=S$$

$$sum1+sum2=total$$

Складывая равенства, получаем:

$$sum1=\frac{S+total}{2}$$

Задача сводится к подсчёту подмножеств с этой суммой. Если модуль `S` больше `total` или `S+total` нечётно, решений нет. Далее используем таблицу количества подмножеств.

## Код

{% raw %}
```go
package main

import (
	"fmt"
)

func findTargetSubsets(num []int, s int) int {
	total := 0
	for _, n := range num {
		total += n
	}
	if s > total || s < -total || (s+total)%2 != 0 {
		return 0
	}
	return countSubsets(num, (s+total)/2)
}
func countSubsets(num []int, sum int) int {
	dp := make([][]int, len(num)+1)
	for i := range dp {
		dp[i] = make([]int, sum+1)
		dp[i][0] = 1
	}
	for i := 1; i <= len(num); i++ {
		for s := 1; s <= sum; s++ {
			dp[i][s] = dp[i-1][s]
			if num[i-1] <= s {
				dp[i][s] += dp[i-1][s-num[i-1]]
			}
		}
	}
	return dp[len(num)][sum]
}

func main() {
	fmt.Println(findTargetSubsets([]int{1, 1, 2, 3}, 1))
	fmt.Println(findTargetSubsets([]int{1, 2, 7, 1}, 9))
}
```
{% endraw %}

**Вывод:**

```text
3
2
```

## Временная сложность

$$O(NP)$$, где $$P=(S+total)/2$$ — сумма для таблицы. В исходнике оценка записана как $$O(NS)$$; размер DP определяется именно преобразованной суммой.

## Пространственная сложность

$$O(NP)$$.

## Оптимизация памяти

Заменяем двумерную таблицу одномерной, как в предыдущей задаче. Обновляем суммы по убыванию, чтобы каждое число участвовало в выборе один раз.

### Код

{% raw %}
```go
package main

import (
	"fmt"
)

func findTargetSubsets(num []int, s int) int {
	total := 0
	for _, n := range num {
		total += n
	}
	if s > total || s < -total || (s+total)%2 != 0 {
		return 0
	}
	return countSubsets(num, (s+total)/2)
}
func countSubsets(num []int, sum int) int {
	dp := make([]int, sum+1)
	dp[0] = 1
	for _, n := range num {
		for s := sum; s >= n; s-- {
			dp[s] += dp[s-n]
		}
	}
	return dp[sum]
}

func main() {
	fmt.Println(findTargetSubsets([]int{1, 1, 2, 3}, 1))
	fmt.Println(findTargetSubsets([]int{1, 2, 7, 1}, 9))
}
```
{% endraw %}

**Вывод:**

```text
3
2
```

### Временная сложность

$$O(NP)$$.

### Пространственная сложность

$$O(P)$$.

{% include algo-task-nav.html position="bottom" %}
