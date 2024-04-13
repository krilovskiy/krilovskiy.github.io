---
title: Алгосы от Влада, часть 1. Скользящее окно
date: 2023-12-21 20:21:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
---


* [Введение](/posts/algo-patterns/)
* <b>Скользящее окно</b>
* [Два указателя или итератор](/posts/algo-patterns-two-pointers/)
* [Быстрый и медленный указатель](/posts/algo-patterns-fast-slow-pointer)
* Мерж интервалов
* Циклическая сортировка
* Инвертирование связанного списка на месте
* Дерево BFS
* Дерево DFS
* Две кучи
* Подмножества
* Модифицированный бинарный поиск
* Побитовый XOR
* Лучшие элементы К (top K elements)
* k-образный алгоритм слияния (K-Way merge)
* 0 or 1 Knapsack (Динамическое программирование)
* Топологическая сортировки



Паттерн <b>Sliding Window</b> используется для выполнения необходимой операции над определенным размером окна 
заданного массива или связанного списка, например, для нахождения самого длинного подмассива, 
содержащего все 1. Скользящие окна начинаются с 1-го элемента и смещаются вправо на один элемент,
а длина окна изменяется в зависимости от решаемой задачи. В некоторых случаях размер окна остается 
постоянным, а в других - увеличивается или уменьшается.

![Desktop View](/assets/img/posts/2023-12-21-algo-patterns-sliding-window/sliding-window.svg){: width="700" height="400" }

Ниже перечислены способы, с помощью которых вы можете определить, что для решения данной проблемы может потребоваться скользящее окно:

В качестве исходных данных в задаче используется линейная структура данных, например связанный список, массив или строка.
Вас просят найти самую длинную/короткую подстроку, подмассив или желаемое значение.

Во многих задачах, связанных с массивом (или списком LinkedList), нас просят найти или вычислить что-то среди всех смежных подмассивов (или подсписков) заданного размера. Например, посмотрите на эту задачу:

```
Найдите среднее значение всех смежных подмассивов размера 'K' в заданном массиве
```

Давайте разберем эту проблему на реальных данных:

```
Array: [1, 3, 2, 6, -1, 4, 1, 8, 2], K=5
```

Здесь нас просят найти среднее значение всех смежных подмассивов размера '5' в заданном массиве. Давайте решим эту задачу:

* Для первых 5 чисел (подмассив с индексами 0-4) среднее равно: (1+3+2+6−1)/5=>2.2
* Среднее значение следующих 5 чисел (подмассив с индексами 1-5) равно: (3+2+6−1+4)/5=>2.8
* Для следующих 5 чисел (подмассив с индексами 2-6) среднее значение равно: (2+6−1+4+1)/5=>2.4

Вот окончательный результат, содержащий средние значения всех смежных подмассивов размера 5:
```
Output: [2.2, 2.8, 2.4, 3.6, 2.8]
```

Брутфорс-алгоритм заключается в вычислении суммы каждого 5-элементного смежного подмассива данного массива и 
делении суммы на '5' для нахождения среднего значения. Вот как будет выглядеть алгоритм:

```go
package main

import (
	"fmt"
)

// findAverages calculates the average of every subarray of size K in the array.
func findAverages(K int, arr []int) []float64 {
	result := make([]float64, len(arr)-K+1)
	for i := 0; i <= len(arr)-K; i++ {
		// Find sum of next 'K' elements
		sum := 0
		for j := i; j < i+K; j++ {
			sum += arr[j]
		}
		result[i] = float64(sum) / float64(K) // Calculate average
	}
	return result
}

func main() {
	result := findAverages(5, []int{1, 3, 2, 6, -1, 4, 1, 8, 2})
	fmt.Println("Averages of subarrays of size K:", result)
}
```

И мы получаем следующий вывод: 
```
Averages of subarrays of size K: [2.2, 2.8, 2.4, 3.6, 2.8]
```

<b>Временная сложность</b>: Поскольку для каждого элемента входного массива мы вычисляем сумму 
его следующих 'K' элементов, временная сложность приведенного выше алгоритма составит
<i>O(N∗K)</i> где 'N' - количество элементов во входном массиве.

Можно ли найти лучшее решение? Видите ли вы какую-нибудь неэффективность в приведенном выше подходе?

Неэффективность заключается в том, что для любых двух последовательных подмассивов размера '5' перекрывающаяся 
часть (которая будет содержать четыре элемента) будет оцениваться дважды. 
Например, возьмем вышеупомянутый входной сигнал:

![Desktop View](/assets/img/posts/2023-12-21-algo-patterns-sliding-window/sub-array.svg){: width="700" height="400" }

Как видите, между подмассивом (с индексами 0-4) и подмассивом (с индексами 1-5) есть четыре пересекающихся элемента. Можем ли мы как-то повторно использовать сумму, вычисленную для перекрывающихся элементов?

Эффективным способом решения этой проблемы будет визуализация каждого смежного подмассива 
как скользящего окна из '5' элементов. Это означает, что при переходе к следующему подмассиву мы будем сдвигать окно 
на один элемент. Поэтому, чтобы повторно использовать сумму из предыдущего подмассива, мы вычтем элемент, выходящий 
из окна, и прибавим элемент, который теперь входит в скользящее окно. Это избавит нас от необходимости перебирать 
весь подмассив для нахождения суммы, и, как следствие, сложность алгоритма снизится до <i>O(N)</i>

Вот оно, наше скользящее окно.
![Desktop View](/assets/img/posts/2023-12-21-algo-patterns-sliding-window/sliding-window.svg){: width="700" height="400" }

А вот и его алгоритм: 
```go
package main

import (
	"fmt"
)

// findAverages вычисляет среднее значение каждого подмассива размера K в массиве.
func findAverages(K int, arr []int) []float64 {
	result := make([]float64, len(arr)-K+1)
	windowSum := 0
	windowStart := 0

	for windowEnd := 0; windowEnd < len(arr); windowEnd++ {
		windowSum += arr[windowEnd] // добавляем следующий элемент

		// скользим окном, не нужно скользить, если мы не достигли необходимого размера окна 'K'
		if windowEnd >= K-1 {
			result[windowStart] = float64(windowSum) / float64(K) // вычисляем среднее
			windowSum -= arr[windowStart]                           // вычитаем элемент, выходящий за окно
			windowStart++                                           // двигаем окно вперёд
		}
	}

	return result
}

func main() {
	result := findAverages(5, []int{1, 3, 2, 6, -1, 4, 1, 8, 2})
	fmt.Println("Averages of subarrays of size K:", result)
}
```

И мы получаем следующий вывод:
```
Averages of subarrays of size K: [2.2, 2.8, 2.4, 3.6, 2.8]
```


Примеры проблем, для решения которых используется модель скользящего окна:

* Maximum Sum Subarray of Size K (easy)
* Smallest Subarray with a given sum (easy) [Educative.io](https://www.educative.io/courses/grokking-the-coding-interview/7XMlMEQPnnQ)
* Longest Substring with K Distinct Characters (medium) [Educative.io](https://www.educative.io/courses/grokking-the-coding-interview/YQQwQMWLx80)
* Fruits into Baskets (medium) [LeetCode](https://leetcode.com/problems/fruit-into-baskets/)
* No-repeat Substring (hard) [LeetCode](https://leetcode.com/problems/longest-substring-without-repeating-characters/)
* Longest Substring with Same Letters after Replacement (hard) [LeetCode](https://leetcode.com/problems/longest-repeating-character-replacement/)
* Longest Subarray with Ones after Replacement (hard) [LeetCode](https://leetcode.com/problems/max-consecutive-ones-iii/)
* Problem Challenge 1 - Permutation in a String (hard) [Leetcode](https://leetcode.com/problems/permutation-in-string/)
* Problem Challenge 2 - String Anagrams (hard) [Leetcode](https://leetcode.com/problems/find-all-anagrams-in-a-string/)
* Problem Challenge 3 - Smallest Window containing Substring (hard) [Leetcode](https://leetcode.com/problems/minimum-window-substring/)
* Problem Challenge 4 - Words Concatenation (hard) [Leetcode](https://leetcode.com/problems/substring-with-concatenation-of-all-words/)

