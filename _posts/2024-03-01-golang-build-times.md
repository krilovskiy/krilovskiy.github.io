---
title: Анализ времени сборки приложений Go
date: 2024-02-01 20:21:00 +0500
categories: [Programming]
tags: [golang, build, tests, ci/cd]
---

Go часто хвалят за быстрое время сборки. Хотя сборка довольно быстрая, все же она достаточно медленная, 
чтобы я тратил много времени на их ожидание. Это побудило меня спуститься в кроличью нору 
и тщательно проанализировать, что же там происходит на самом деле. 
В этой статье мы рассмотрим все аспекты того, что делает сборку Go быстрым или медленным.

На протяжении всего этого поста мы будем использовать [Istio](https://github.com/istio/istio) 
в качестве примера реальной кодовой базы.

Для справки о ее размере:

```sh
$ tokei -t=Go
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Language            Files        Lines         Code     Comments       Blanks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Go                   1814       453735       358883        54151        40701
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Total                1814       453735       358883        54151        40701
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Около 350 тысяч строк кода.

Все тесты будут выполняться на `n2d-standard-48` GCE VM (vCPU: 48, RAM: 192 GB, Disk: 2TB PD_SSD).

Все тесты будут выполняться в docker, т.к. это позволяет избежать случайного шеринга кэша и в docker 
легко управлять количеством доступных CPU.


## Ключевые моменты

Пост получился очень длинным, основные тезисы:
* [Кэширование](#кэширование) сборки в Go очень эффективно и не вызывает особых сюрпризов. 
Просто убедитесь, что ваш CI/CD действительно использует его!
* Go предоставляет ряд инструментов (в основном скрытых) для тщательного анализа времени сборки.
* Если вы собираете в контейнерах (или иным образом ограничиваете использование процессора), обязательно установите GOMAXPROCS.
* Опасайтесь использования `-p 1` для ограничения параллельного выполнения тестов.
* По возможности используйте -vet=off для выполнения тестов, если вы уже запускаете vet в других контекстах.
* Если вы просто проверяете, компилируется ли код, пропустите шаг компоновки. 
Это особенно полезно при проверке компиляции тестов.
* Используйте одну команду `go build`, если вам нужно собрать несколько двоичных файлов.

## Модули Go
Прежде чем начать сборку, нам нужно собрать все наши зависимости:
```sh
$ docker run --rm -v $PWD:$PWD -w $PWD -it --init golang:1.20 bash -c '
time go mod download
du -sh `go env GOMODCACHE`
'
real    0m5.585s
user    0m17.749s
sys     0m9.369s
1.1G    /go/pkg/mod
```
Это <i>быстро</i>. В моей домашней сети это заняло 50 секунд.

Однако это, по сути, тест скорости сети, что не очень интересно. 
Кроме того, это самый простой аспект сборки Go, который можно кэшировать, 
поэтому с этого момента мы будем игнорировать его и всегда использовать кэширование. Мы также сделаем простой помощник:
```sh
function run() {
  docker run --rm -v $PWD:$PWD -w $PWD -e 'GOFLAGS=-buildvcs=false' -v `go env GOMODCACHE`:/go/pkg/mod -it --init golang:1.20 bash -c "$*"
}
```

## Сборка
Теперь перейдем к, непосредственно, сборке.
```sh
$ run time go build ./pilot/cmd/pilot-discovery

real    0m33.102s
user    6m31.190s
sys     1m45.876s
```

Таким образом, для стандартной сборки мы получим чуть больше 30 секунд. Но помните, что это на <i>здоровенной машине</i>.

### Масштабирование CPU

Большинство сборок не выполняется на 48 ядрах; например, в стандартных раннера GitHub-actions используется только 2 ядра. 
Давайте посмотрим, как время сборки зависит от процессора.


Нам понадобится еще один хелпер для тестирования ограничений по ядерам. 
Мне также было интересно, поможет ли здесь настройка GOMAXPROCS - она по умолчанию определяет количество 
процессоров на машине, но не учитывает ограничения cgroup, как те, что накладывает docker. 
Мы создадим хелперы для обоих вариантов и сравним их.

```sh
function run-with-cores() {
  cores="$1"
  shift
  docker run --rm -v $PWD:$PWD -w $PWD \
    --cpus="$cores" \
    -e 'GOFLAGS=-buildvcs=false' \
    -v `go env GOMODCACHE`:/go/pkg/mod \
    -it --init golang:1.20 bash -c "$*"
}

function run-with-cores-gomaxprocs() {
  cores="$1"
  maxprocs="$2"
  shift; shift;
  docker run --rm -v $PWD:$PWD -w $PWD \
    --cpus="$cores" -e GOMAXPROCS="$maxprocs" \
    -e 'GOFLAGS=-buildvcs=false' \
    -v `go env GOMODCACHE`:/go/pkg/mod \
    -it --init golang:1.20 bash -c "$*"
}
```

Сравним их использование
```sh 
$ run-with-cores 4 'time go build ./pilot/cmd/pilot-discovery'
real    2m0.627s
user    6m21.382s
sys     1m25.052s

$ run-with-cores-gomaxprocs 4 4 'time go build ./pilot/cmd/pilot-discovery'
real    1m26.253s
user    4m34.381s
sys     0m59.795s
```

Итак, установка GOMAXPROCS действительно помогает.

Я предполагаю, что количество ядер == GOMAXPROCS - это идеальный вариант, но мы должны это проверить:
```sh
$ run-with-cores-gomaxprocs 4 1 'time go build ./pilot/cmd/pilot-discovery'
real    4m3.413s

$ run-with-cores-gomaxprocs 4 2 'time go build ./pilot/cmd/pilot-discovery'
real    1m41.406s

$ run-with-cores-gomaxprocs 4 4 'time go build ./pilot/cmd/pilot-discovery'
real    1m24.643s

$ run-with-cores-gomaxprocs 4 8 'time go build ./pilot/cmd/pilot-discovery'
real    1m38.170s

$ run-with-cores-gomaxprocs 4 16 'time go build ./pilot/cmd/pilot-discovery'
real    1m53.609s
```

Действительно помогает. Давайте сделаем соответствующий хелпер.

```sh
function run-with-cores() {
  cores="$1"
  shift
  docker run --rm -v $PWD:$PWD -w $PWD \
    --cpus="$cores" -e GOMAXPROCS="$cores" \
    -e 'GOFLAGS=-buildvcs=false' \
    -v `go env GOMODCACHE`:/go/pkg/mod \
    -it --init golang:1.20 bash -c "$*"
}
```

Наконец, мы можем посмотреть, как время сборки зависит от процессора:
```shell
run-with-cores 1 'time go build -o /tmp/build ./pilot/cmd/pilot-discovery'
real    7m12.354s

run-with-cores 2 'time go build -o /tmp/build ./pilot/cmd/pilot-discovery'
real    3m50.390s

run-with-cores 4 'time go build -o /tmp/build ./pilot/cmd/pilot-discovery'
real    2m4.813s

run-with-cores 8 'time go build -o /tmp/build ./pilot/cmd/pilot-discovery'
real    1m10.144s

run-with-cores 16 'time go build -o /tmp/build ./pilot/cmd/pilot-discovery'
real    0m44.286s

run-with-cores 32 'time go build -o /tmp/build ./pilot/cmd/pilot-discovery'
real    0m33.755s
```

Построим график, сравнив его с теоретически идеальным масштабированием 
(то есть использование 100 ядер в 100 раз быстрее, чем 1 ядро):

![Desktop View](/assets/img/posts/2024-03-01-golang-build-times/compile-time-cores.svg)

Мы видим, что он процесс сборки довольно хорошо масштабируется при увеличении количества ядер, 
но в определенный момент отдача снижается. Мы рассмотрим это подробнее в разделе [трассировки](#трассировка).

### Реально большие машины

Мне стало любопытно, и я запустил сборку на `c3-standard-176` (да, это 176 ядер!).

```shell
$ time go build ./pilot/cmd/pilot-discovery

real    0m25.188s
user    6m28.325s
sys     1m26.272s
```

Немного разочаровывает - почти никакого ускорения по сравнению с 48 ядрами. 

## Кэширование

### С обновлением

### Сохранение кэша

### Теги сборки

### Параллельная сборка

#### Поэтапная сборка

#### Несоответствие размеров сборки

### Конкурентность сборки

### Сборка нескольких бинарников

## Тесты

### Состояние гонки

### Vet

### Кэширование тестов

## Линковка и компиляция

### Альтернативные компоновщики

## Анализ влияния на время сборки

### Пользовательская обертка toolexec.

### Граф действий

### Трассировка

### Профилирование

### Goda

## Анализ реального приложения

### Медленное выполнение тестов

### Интеграционные тесты

### Kubernetes

### Упорядоченное выполнение тестов

### Сборка и тестирование

## Сравнение с Rust



<i>Данная статья является вольным переводом статьи [Analyzing Go Build Times](https://blog.howardjohn.info/posts/go-build-times/)</i>
