---
title: Разбиение на равные суммы
description: Разбиение на равные суммы — условие, разбор алгоритма и самостоятельное решение на Go.
pattern: 0-1-knapsack
permalink: /posts/algo-patterns-0-1-knapsack/equal-subset-sum-partition/
---

{% include algo-task-nav.html position="top" %}

## Условие задачи

Дан набор положительных чисел. Можно ли разделить его на два подмножества с одинаковыми суммами? Каждое вхождение относится ровно к одному подмножеству.

```text
[1, 2, 3, 4] → true: [1, 4] и [2, 3]
[1, 1, 3, 4, 7] → true: [1, 3, 4] и [1, 7]
[2, 3, 4, 6] → false
```

## Решение

Обозначим общую сумму через `S`. При нечётном `S` равное разбиение невозможно. Иначе достаточно найти подмножество с суммой `S/2`: оставшиеся числа автоматически дадут вторую половину.

Рекурсивно пробуем включить текущее число, если оно не превосходит оставшуюся сумму, либо пропустить. Сумма `0` означает успех, конец массива с ненулевым остатком — неудачу.

<details>
<summary>Пошаговые схемы из исходника</summary>
<div markdown="1">

![Проверка достижимости половины общей суммы, шаг 1](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/equal-partition-01.svg)

![Проверка достижимости половины общей суммы, шаг 2](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/equal-partition-02.svg)

![Проверка достижимости половины общей суммы, шаг 3](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/equal-partition-03.svg)

![Проверка достижимости половины общей суммы, шаг 4](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/equal-partition-04.svg)

![Проверка достижимости половины общей суммы, шаг 5](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/equal-partition-05.svg)

![Проверка достижимости половины общей суммы, шаг 6](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/equal-partition-06.svg)

![Проверка достижимости половины общей суммы, шаг 7](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/equal-partition-07.svg)

![Проверка достижимости половины общей суммы, шаг 8](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/equal-partition-08.svg)

![Проверка достижимости половины общей суммы, шаг 9](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/equal-partition-09.svg)

![Проверка достижимости половины общей суммы, шаг 10](/assets/img/posts/2027-06-01-algo-patterns-0-1-knapsack/equal-partition-10.svg)

</div>
</details>

## Код

{% raw %}
```go
package main

import (
	"fmt"
)

func canPartition(num []int) bool {
	sum := 0
	for _, n := range num {
		sum += n
	}
	if sum%2 != 0 {
		return false
	}
	sum /= 2
	return canPartitionRecursive(num, sum, 0)
}
func canPartitionRecursive(num []int, sum, currentIndex int) bool {
	if sum == 0 {
		return true
	}
	if currentIndex >= len(num) {
		return false
	}
	if num[currentIndex] <= sum && canPartitionRecursive(num, sum-num[currentIndex], currentIndex+1) {
		return true
	}
	return canPartitionRecursive(num, sum, currentIndex+1)
}

func main() {
	fmt.Println(canPartition([]int{1, 2, 3, 4}))
	fmt.Println(canPartition([]int{1, 1, 3, 4, 7}))
	fmt.Println(canPartition([]int{2, 3, 4, 6}))
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

$$O(2^N)$$.

## Пространственная сложность

$$O(N)$$ для стека.

## Мемоизация: сверху вниз

Состояние задают индекс и оставшаяся сумма. В таблице `-1` означает неизвестный результат, `0` — невозможность, `1` — достижимость. В отличие от булевой таблицы такое представление различает «ещё не вычислено» и «ответ false».

### Код

{% raw %}
```go
package main

import (
	"fmt"
)

func canPartition(num []int) bool {
	sum := 0
	for _, n := range num {
		sum += n
	}
	if sum%2 != 0 {
		return false
	}
	sum /= 2
	dp := make([][]int, len(num))
	for i := range dp {
		dp[i] = make([]int, sum+1)
		for s := range dp[i] {
			dp[i][s] = -1
		}
	}
	return canPartitionRecursive(dp, num, sum, 0)
}
func canPartitionRecursive(dp [][]int, num []int, sum, currentIndex int) bool {
	if sum == 0 {
		return true
	}
	if currentIndex >= len(num) {
		return false
	}
	if dp[currentIndex][sum] != -1 {
		return dp[currentIndex][sum] == 1
	}
	result := false
	if num[currentIndex] <= sum {
		result = canPartitionRecursive(dp, num, sum-num[currentIndex], currentIndex+1)
	}
	if !result {
		result = canPartitionRecursive(dp, num, sum, currentIndex+1)
	}
	dp[currentIndex][sum] = 0
	if result {
		dp[currentIndex][sum] = 1
	}
	return result
}

func main() {
	fmt.Println(canPartition([]int{1, 2, 3, 4}))
	fmt.Println(canPartition([]int{1, 1, 3, 4, 7}))
	fmt.Println(canPartition([]int{2, 3, 4, 6}))
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

$$O(NS)$$, где `S` — сумма всех чисел.

### Пространственная сложность

$$O(NS)$$ с учётом стека.

## Динамическое программирование: снизу вверх

`dp[i][s]` означает, что сумму `s` можно получить из первых `i` чисел. Сумма `0` достижима пустым набором. Для остальных сумм либо пропускаем число и берём `dp[i-1][s]`, либо включаем его и берём `dp[i-1][s-num[i-1]]`. Достаточно истинности одного из вариантов.

### Код

{% raw %}
```go
package main

import (
	"fmt"
)

func canPartition(num []int) bool {
	sum := 0
	for _, n := range num {
		sum += n
	}
	if sum%2 != 0 {
		return false
	}
	sum /= 2
	return subsetTable(num, sum)[len(num)][sum]
}
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
	fmt.Println(canPartition([]int{1, 2, 3, 4}))
	fmt.Println(canPartition([]int{1, 1, 3, 4, 7}))
	fmt.Println(canPartition([]int{2, 3, 4, 6}))
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

$$O(NS)$$.

{% include algo-task-nav.html position="bottom" %}
