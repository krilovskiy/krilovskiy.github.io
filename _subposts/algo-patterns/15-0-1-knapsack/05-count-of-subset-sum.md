---
title: Количество подмножеств с заданной суммой
description: Количество подмножеств с заданной суммой — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: 0-1-knapsack
permalink: /posts/algo-patterns-0-1-knapsack/count-of-subset-sum/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Посчитайте подмножества набора положительных чисел, сумма которых равна `S`. Одинаковые значения на разных позициях считаются разными элементами.

```text
[1, 1, 2, 3], S = 4 → 3
[1, 2, 7, 1, 5], S = 9 → 3
```

В первом примере это `[1,1,2]` и два варианта `[1,3]`, использующие разные единицы. Во втором — `[2,7]`, `[1,7,1]`, `[1,2,1,5]`.

## Решение

Как и в задаче существования подмножества, пробуем взять или пропустить элемент. Но вместо логического «или» складываем число решений двух ветвей. Остаток `0` даёт один способ, а конец массива при ненулевом остатке — ноль.

<details>
<summary>Пошаговые схемы из исходника</summary>
<div markdown="1">

![Подсчёт подмножеств по числу элементов и сумме, шаг 1](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/count-subsets-01.svg)

![Подсчёт подмножеств по числу элементов и сумме, шаг 2](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/count-subsets-02.svg)

![Подсчёт подмножеств по числу элементов и сумме, шаг 3](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/count-subsets-03.svg)

![Подсчёт подмножеств по числу элементов и сумме, шаг 4](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/count-subsets-04.svg)

![Подсчёт подмножеств по числу элементов и сумме, шаг 5](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/count-subsets-05.svg)

![Подсчёт подмножеств по числу элементов и сумме, шаг 6](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/count-subsets-06.svg)

![Подсчёт подмножеств по числу элементов и сумме, шаг 7](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/count-subsets-07.svg)

![Подсчёт подмножеств по числу элементов и сумме, шаг 8](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/count-subsets-08.svg)

![Подсчёт подмножеств по числу элементов и сумме, шаг 9](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/count-subsets-09.svg)

![Подсчёт подмножеств по числу элементов и сумме, шаг 10](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/count-subsets-10.svg)

![Подсчёт подмножеств по числу элементов и сумме, шаг 11](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/count-subsets-11.svg)

![Подсчёт подмножеств по числу элементов и сумме, шаг 12](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/count-subsets-12.svg)

</div>
</details>

## Код

{% raw %}
```go
package main

import (
	"fmt"
)

func countSubsets(num []int, sum int) int { return countSubsetsRecursive(num, sum, 0) }
func countSubsetsRecursive(num []int, sum, currentIndex int) int {
	if sum == 0 {
		return 1
	}
	if currentIndex >= len(num) {
		return 0
	}
	count1 := 0
	if num[currentIndex] <= sum {
		count1 = countSubsetsRecursive(num, sum-num[currentIndex], currentIndex+1)
	}
	count2 := countSubsetsRecursive(num, sum, currentIndex+1)
	return count1 + count2
}

func main() {
	fmt.Println(countSubsets([]int{1, 1, 2, 3}, 4))
	fmt.Println(countSubsets([]int{1, 2, 7, 1, 5}, 9))
}
```
{% endraw %}

**Вывод:**

```text
3
3
```

## Временная сложность

$$O(2^N)$$.

## Пространственная сложность

$$O(N)$$.

## Мемоизация: сверху вниз

Кешируем количество решений по индексу и оставшейся сумме. `-1` отделяет ещё не вычисленное состояние от правильного ответа `0`.

### Код

{% raw %}
```go
package main

import (
	"fmt"
)

func countSubsets(num []int, sum int) int {
	dp := make([][]int, len(num))
	for i := range dp {
		dp[i] = make([]int, sum+1)
		for s := range dp[i] {
			dp[i][s] = -1
		}
	}
	return countSubsetsRecursive(dp, num, sum, 0)
}
func countSubsetsRecursive(dp [][]int, num []int, sum, currentIndex int) int {
	if sum == 0 {
		return 1
	}
	if currentIndex >= len(num) {
		return 0
	}
	if dp[currentIndex][sum] != -1 {
		return dp[currentIndex][sum]
	}
	count1 := 0
	if num[currentIndex] <= sum {
		count1 = countSubsetsRecursive(dp, num, sum-num[currentIndex], currentIndex+1)
	}
	count2 := countSubsetsRecursive(dp, num, sum, currentIndex+1)
	dp[currentIndex][sum] = count1 + count2
	return dp[currentIndex][sum]
}

func main() {
	fmt.Println(countSubsets([]int{1, 1, 2, 3}, 4))
	fmt.Println(countSubsets([]int{1, 2, 7, 1, 5}, 9))
}
```
{% endraw %}

**Вывод:**

```text
3
3
```

### Временная сложность

$$O(NS)$$.

### Пространственная сложность

$$O(NS)$$.

## Динамическое программирование: снизу вверх

`dp[i][s]` — количество подмножеств первых `i` элементов с суммой `s`. Для нулевой суммы существует ровно одно пустое подмножество, поскольку числа положительны.

Число способов без текущего элемента — `dp[i-1][s]`, с ним — `dp[i-1][s-num[i-1]]`. Эти группы не пересекаются, поэтому складываем количества.

### Код

{% raw %}
```go
package main

import (
	"fmt"
)

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
	fmt.Println(countSubsets([]int{1, 1, 2, 3}, 4))
	fmt.Println(countSubsets([]int{1, 2, 7, 1, 5}, 9))
}
```
{% endraw %}

**Вывод:**

```text
3
3
```

### Временная сложность

$$O(NS)$$.

### Пространственная сложность

$$O(NS)$$.

## Оптимизация памяти

Один массив хранит число способов получить каждую сумму. Перебор сумм справа налево сохраняет значения предыдущей строки: `dp[s] += dp[s-num[i]]`. Предполагается, что количество способов помещается в `int`.

### Код

{% raw %}
```go
package main

import (
	"fmt"
)

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
	fmt.Println(countSubsets([]int{1, 1, 2, 3}, 4))
	fmt.Println(countSubsets([]int{1, 2, 7, 1, 5}, 9))
}
```
{% endraw %}

**Вывод:**

```text
3
3
```

### Временная сложность

$$O(NS)$$.

### Пространственная сложность

$$O(S)$$.

{% include algo-task-nav.html position="bottom" %}
