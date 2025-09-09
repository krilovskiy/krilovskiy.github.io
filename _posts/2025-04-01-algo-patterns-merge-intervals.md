---
title: Алгосы от Влада, часть 4. Мерж интервалов
date: 2025-04-01 20:21:00 +0500
categories: [Programming, Interview]
tags: [algovlad, golang, leetcode, coding]
math: true
---


* [Введение](/posts/algo-patterns/)
* [Скользящее окно](/posts/algo-patterns-sliding-window/)
* [Два указателя или итератор](/posts/algo-patterns-two-pointers/)
* [Быстрый и медленный указатель](/posts/algo-patterns-fast-slow-pointer/)
* <b>Мерж интервалов</b>
* [Циклическая сортировка](/posts/algo-patterns-cyclic-sort/)
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


## Введение

Этот шаблон описывает эффективный способ работы с перекрывающимися интервалами

Во многих задачах, связанных с интервалами, нам нужно либо найти перекрывающиеся интервалы, либо объединить интервалы, если они перекрываются.

Даны два интервала (`a` и `b`), между ними возможно шесть различных способов взаимного расположения:

![Desktop View](/assets/img/posts/2024-04-01-algo-patterns-merge-intervals/merge-intervals-1.svg){: width="700" height="400" }

1. Интервал `a` полностью находится до интервала `b`.
2. Интервал `a` частично перекрывает начало интервала `b`.
3. Интервал `a` полностью содержит интервал `b`.
4. Интервал `b` полностью содержит интервал `a`.
5. Интервал `a` частично перекрывает конец интервала `b`.
6. Интервал `a` полностью находится после интервала `b`.

Понимание этих шести случаев поможет нам решить любые задачи, связанные с интервалами. 
Давайте разберем нашу первую задачу, чтобы понять шаблон объединения интервалов.


## Объединение интервалов (средний уровень сложности)

### Условие задачи
Дан список интервалов. Необходимо объединить все перекрывающиеся интервалы, чтобы получить список, содержащий только взаимно эксклюзивные интервалы.

### Примеры

**Пример данных 1:**

- Входные данные: `[[1,4], [2,5], [7,9]]`
- Выходные данные: `[[1,5], [7,9]]`
- **Объяснение:** Поскольку первые два интервала `[1,4]` и `[2,5]` перекрываются, мы объединили их в один `[1,5]`.

![Desktop View](/assets/img/posts/2024-04-01-algo-patterns-merge-intervals/merge-intervals-2.svg){: width="700" height="400" }


**Пример данных 2:**

- Входные данные: `[[6,7], [2,4], [5,9]]`
- Выходные данные: `[[2,4], [5,9]]`
- **Объяснение:** Поскольку интервалы `[6,7]` и `[5,9]` перекрываются, мы объединили их в один `[5,9]`.


**Пример данных 3:**

- Входные данные: `[[1,4], [2,6], [3,5]]`
- Выходные данные: `[[1,6]]`
- **Объяснение:** Поскольку все указанные интервалы перекрываются, мы объединили их в один `[1,6]`.

### Решение

Возьмем пример двух интервалов (`a` и `b`), где `a.start <= b.start`. Возможны четыре сценария их взаимодействия:

![Desktop View](/assets/img/posts/2024-04-01-algo-patterns-merge-intervals/merge-intervals-3.svg){: width="700" height="400" }

Наша цель — объединить интервалы, если они перекрываются. Для трех сценариев перекрытия (2, 3 и 4) объединение будет следующим:

![Desktop View](/assets/img/posts/2024-04-01-algo-patterns-merge-intervals/merge-intervals-4.svg){: width="700" height="400" }

Диаграмма выше ясно показывает подход к объединению интервалов. Наш алгоритм будет выглядеть следующим образом:

1. Отсортируйте интервалы по их начальным точкам, чтобы гарантировать, что `a.start <= b.start`.
2. Если интервал `a` перекрывается с интервалом `b` (т.е. `b.start <= a.end`), объедините их в новый интервал `c`, такой что:
  - `c.start = a.start`
  - `c.end = max(a.end, b.end)`
3. Продолжайте повторять два вышеуказанных шага, чтобы объединить интервал `c` со следующим, если он перекрывается с `c`.

```go
package main

import (
  "fmt"
  "sort"
)

// Interval структура для хранения интервала
type Interval struct {
  start int
  end   int
}

// PrintInterval метод для вывода интервала
func (i Interval) PrintInterval() {
  fmt.Printf("[%d, %d]", i.start, i.end)
}

// Merge функция для объединения интервалов
func Merge(intervals []Interval) []Interval {
  if len(intervals) < 2 {
    return intervals
  }

  // Сортируем интервалы по их начальной точке
  sort.Slice(intervals, func(i, j int) bool {
    return intervals[i].start < intervals[j].start
  })

  mergedIntervals := []Interval{}
  start := intervals[0].start
  end := intervals[0].end

  for i := 1; i < len(intervals); i++ {
    interval := intervals[i]
    if interval.start <= end { // перекрывающиеся интервалы, корректируем конец
      end = max(end, interval.end)
    } else { // не перекрывающийся интервал, добавляем предыдущий и обновляем текущий
      mergedIntervals = append(mergedIntervals, Interval{start, end})
      start = interval.start
      end = interval.end
    }
  }

  // Добавляем последний интервал
  mergedIntervals = append(mergedIntervals, Interval{start, end})
  return mergedIntervals
}

// Вспомогательная функция для вычисления максимума
func max(a, b int) int {
  if a > b {
    return a
  }
  return b
}

func main() {
  fmt.Print("Merged intervals: ")
  result := Merge([]Interval{ {1, 4}, {2, 5}, {7, 9} })
  for _, interval := range result {
    interval.PrintInterval()
  }
  fmt.Println()

  fmt.Print("Merged intervals: ")
  result = Merge([]Interval{ {6, 7}, {2, 4}, {5, 9} })
  for _, interval := range result {
    interval.PrintInterval()
  }
  fmt.Println()

  fmt.Print("Merged intervals: ")
  result = Merge([]Interval{ {1, 4}, {2, 6}, {3, 5} })
  for _, interval := range result {
    interval.PrintInterval()
  }
  fmt.Println()
}
```

**Вывод** 
```sh

2.360s
Merged intervals: [1, 5][7, 9]
Merged intervals: [2, 4][5, 9]
Merged intervals: [1, 6]
```

### Временная сложность

Временная сложность приведенного алгоритма составляет
$$O(N * logN)$$, где $$N$$ — общее количество интервалов.

- Сначала мы сортируем интервалы, что занимает $$O(N * logN)$$.
- Затем мы проходим по всем интервалам один раз, что занимает $$O(N)$$.

Таким образом, общая временная сложность алгоритма составляет $$O(N * logN)$$.

---

### Пространственная сложность

Пространственная сложность алгоритма равна $$O(N)$$, так как:

- Нам нужно вернуть список, содержащий все объединенные интервалы, что занимает $$O(N)$$.
- Также для сортировки требуется $$O(N)$$ дополнительного пространства.

Например, в Java (в зависимости от версии) метод `Collection.sort()` использует либо Merge sort, либо Timsort, оба из которых требуют $$O(N)$$ пространства.

Итоговая пространственная сложность алгоритма составляет $$O(N)$$.

# Похожие задания
### 4. Pattern: Merge Intervals

1. Merge Intervals (medium) [Leetcode](https://leetcode.com/problems/merge-intervals/)
2. Insert Interval (medium) [Leetcode](https://leetcode.com/problems/insert-interval/)
3. Interval List Intersections (medium) [Leetcode](https://leetcode.com/problems/interval-list-intersections/)
4. Meeting Rooms II (medium) [Leetcode](https://leetcode.com/problems/meeting-rooms-ii/)
5. Employee Free Time (hard) [Leetcode](https://leetcode.com/problems/employee-free-time/)
