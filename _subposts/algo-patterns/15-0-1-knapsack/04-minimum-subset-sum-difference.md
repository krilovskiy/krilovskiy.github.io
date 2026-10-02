---
title: Минимальная разность сумм
description: Минимальная разность сумм — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: 0-1-knapsack
permalink: /posts/algo-patterns-0-1-knapsack/minimum-subset-sum-difference/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Разделите положительные числа на два подмножества с минимальной абсолютной разностью сумм.

```text
[1, 2, 3, 9] → 3: [1, 2, 3] и [9]
[1, 2, 7, 1, 5] → 0: [1, 2, 5] и [7, 1]
[1, 3, 100, 4] → 92: [1, 3, 4] и [100]
```

## Решение

Рекурсивно помещаем каждый элемент либо в первое, либо во второе подмножество. Когда элементы закончились, возвращаем абсолютную разность сумм. Из двух ветвей выбираем меньшую.

<details>
<summary>Пошаговые схемы из исходника</summary>
<div markdown="1">

![Выбор достижимой суммы, ближайшей к половине общей, шаг 1](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/minimum-difference-01.svg)

![Выбор достижимой суммы, ближайшей к половине общей, шаг 2](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/minimum-difference-02.svg)

![Выбор достижимой суммы, ближайшей к половине общей, шаг 3](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/minimum-difference-03.svg)

![Выбор достижимой суммы, ближайшей к половине общей, шаг 4](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/minimum-difference-04.svg)

![Выбор достижимой суммы, ближайшей к половине общей, шаг 5](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/minimum-difference-05.svg)

![Выбор достижимой суммы, ближайшей к половине общей, шаг 6](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/minimum-difference-06.svg)

![Выбор достижимой суммы, ближайшей к половине общей, шаг 7](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/minimum-difference-07.svg)

![Выбор достижимой суммы, ближайшей к половине общей, шаг 8](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/minimum-difference-08.svg)

![Выбор достижимой суммы, ближайшей к половине общей, шаг 9](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/minimum-difference-09.svg)

![Выбор достижимой суммы, ближайшей к половине общей, шаг 10](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/minimum-difference-10.svg)

![Выбор достижимой суммы, ближайшей к половине общей, шаг 11](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/minimum-difference-11.svg)

</div>
</details>

## Код

{% raw %}
```go
package main

import (
	"fmt"
)

func canPartition(num []int) int { return canPartitionRecursive(num, 0, 0, 0) }
func canPartitionRecursive(num []int, currentIndex, sum1, sum2 int) int {
	if currentIndex == len(num) {
		d := sum1 - sum2
		if d < 0 {
			return -d
		}
		return d
	}
	diff1 := canPartitionRecursive(num, currentIndex+1, sum1+num[currentIndex], sum2)
	diff2 := canPartitionRecursive(num, currentIndex+1, sum1, sum2+num[currentIndex])
	if diff1 < diff2 {
		return diff1
	}
	return diff2
}

func main() {
	fmt.Println(canPartition([]int{1, 2, 3, 9}))
	fmt.Println(canPartition([]int{1, 2, 7, 1, 5}))
	fmt.Println(canPartition([]int{1, 3, 100, 4}))
}
```
{% endraw %}

**Вывод:**

```text
3
0
92
```

## Временная сложность

$$O(2^N)$$.

## Пространственная сложность

$$O(N)$$ для стека.

## Мемоизация: сверху вниз

Достаточно индекса и `sum1`: сумма уже обработанного префикса фиксирована, поэтому `sum2` определяется через неё и `sum1`. Сохраняем минимальную разность для этой пары параметров.

### Код

{% raw %}
```go
package main

import (
	"fmt"
)

func canPartition(num []int) int {
	sum := 0
	for _, n := range num {
		sum += n
	}
	dp := make([][]int, len(num))
	for i := range dp {
		dp[i] = make([]int, sum+1)
		for s := range dp[i] {
			dp[i][s] = -1
		}
	}
	return canPartitionRecursive(dp, num, 0, 0, 0)
}
func canPartitionRecursive(dp [][]int, num []int, currentIndex, sum1, sum2 int) int {
	if currentIndex == len(num) {
		d := sum1 - sum2
		if d < 0 {
			return -d
		}
		return d
	}
	if dp[currentIndex][sum1] != -1 {
		return dp[currentIndex][sum1]
	}
	diff1 := canPartitionRecursive(dp, num, currentIndex+1, sum1+num[currentIndex], sum2)
	diff2 := canPartitionRecursive(dp, num, currentIndex+1, sum1, sum2+num[currentIndex])
	dp[currentIndex][sum1] = diff2
	if diff1 < diff2 {
		dp[currentIndex][sum1] = diff1
	}
	return dp[currentIndex][sum1]
}

func main() {
	fmt.Println(canPartition([]int{1, 2, 3, 9}))
	fmt.Println(canPartition([]int{1, 2, 7, 1, 5}))
	fmt.Println(canPartition([]int{1, 3, 100, 4}))
}
```
{% endraw %}

**Вывод:**

```text
3
0
92
```

### Временная сложность

$$O(NS)$$, где `S` — общая сумма.

### Пространственная сложность

$$O(NS)$$.

## Динамическое программирование: снизу вверх

Ищем достижимую сумму, максимально близкую к `S/2` снизу. Строим булеву таблицу сумм до `S/2` тем же переходом, что в Subset Sum. В последней строке идём от `S/2` назад до первого `true`. Если это `sum1`, то вторая сумма `S-sum1`, а разность — `S-2*sum1`.

В примере `[1,2,3,9]` сумма равна `15`. Сумма `7` недостижима, ближайшая — `6`. Получаем `9-6=3`.

### Код

{% raw %}
```go
package main

import (
	"fmt"
)

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
func canPartition(num []int) int {
	sum := 0
	for _, n := range num {
		sum += n
	}
	dp := subsetTable(num, sum/2)
	sum1 := sum / 2
	for !dp[len(num)][sum1] {
		sum1--
	}
	sum2 := sum - sum1
	return sum2 - sum1
}

func main() {
	fmt.Println(canPartition([]int{1, 2, 3, 9}))
	fmt.Println(canPartition([]int{1, 2, 7, 1, 5}))
	fmt.Println(canPartition([]int{1, 3, 100, 4}))
}
```
{% endraw %}

**Вывод:**

```text
3
0
92
```

### Временная сложность

$$O(NS)$$.

### Пространственная сложность

$$O(NS)$$.

{% include algo-task-nav.html position="bottom" %}
