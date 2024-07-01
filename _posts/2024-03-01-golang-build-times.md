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
К счастью, Go поставляется с довольно надежным кэшированием сборки из коробки:

```shell
$ run '
time go build -o /tmp/build ./pilot/cmd/pilot-discovery
time go build -o /tmp/build ./pilot/cmd/pilot-discovery
time go build -o /tmp/build2 ./pilot/cmd/pilot-discovery
'
real    0m32.577s
real    0m0.810s
real    0m4.918s
```
Мы видим, что последующие сборки происходят практически мгновенно - особенно если мы пишем в один и тот же файл. 
Если мы не пишем в тот же файл, нам приходится линковать бинарник, что занимает около 5 с.

### С обновлением

Приведенный выше тест не слишком реалистичен - обычно мы меняем код в промежутках между сборками:

```shell
$ run '
time go build -o /tmp/build ./pilot/cmd/pilot-discovery
echo 'var _ = 1' >> pilot/cmd/pilot-discovery/main.go
time go build -o /tmp/build ./pilot/cmd/pilot-discovery
echo 'var _ = 2' >> pilot/cmd/pilot-discovery/main.go
time go build -o /tmp/build2 ./pilot/cmd/pilot-discovery
'
real    0m32.601s
real    0m5.017s
real    0m4.995s
```

Здесь мы видим, что преимущество вывода в один и тот же файл полностью утрачено, что, скорее всего, 
является оптимизацией для полностью неизмененных сборок. Однако в остальном затраты минимальны.

Однако в приведенном выше тесте мы изменяем файл, находящийся в верхней части цепочки зависимостей. 
Все выглядит немного иначе, если мы изменим глубокую зависимость. 
В нашем приложении пакет log используется почти везде; давайте попробуем изменить его:

```shell
$ run '
time go build -o /tmp/build ./pilot/cmd/pilot-discovery
sed -i  's/"message"/"new"/g' pkg/log/config.go
time go build -o /tmp/build ./pilot/cmd/pilot-discovery
'

real    0m31.760s
real    0m15.268s
```

Здесь мы видим, что времени тратится гораздо больше. Вероятно, почти каждый пакет в нашем репозитории перестраивается, 
а зависимости кэшируются.


### Сохранение кэша

А если мы постоянно переключаемся между ветками? Или, в случае с CI, кэширование между филиалами?

```shell
run '
git config --global --add safe.directory /usr/local/google/home/howardjohn/go/src/istio.io/istio
time go build -o /tmp/build ./pilot/cmd/pilot-discovery
git checkout release-1.18
time go build -o /tmp/build ./pilot/cmd/pilot-discovery
git checkout master
time go build -o /tmp/build ./pilot/cmd/pilot-discovery
'
real    0m31.690s
Switched to branch 'release-1.18'

real    0m37.476s
Switched to branch 'master'

real    0m5.006s
```

Так же быстро. По крайней мере, в этом простом случае переключение между ветками не вредит кэшированию.

### Теги сборки
Что если изменить теги сборки? Ниже я тестирую тег, который нигде не используется:
```shell
run '
time go build -o /tmp/build ./pilot/cmd/pilot-discovery
time go build -o /tmp/build -tags=nothing ./pilot/cmd/pilot-discovery
'

real    0m31.719s
real    0m4.956s
```

Как и ожидалось, никакого влияния на кэширование

### Параллельная сборка

При кэшировании в CI мы можем создавать одни и те же вещи одновременно. 
Обычно это происходит, когда в коммите запланировано несколько заданий одновременно, и они оба создают похожие вещи.

Насколько хорошо оно кэшируется?

Мы ограничимся 4 ядрами, чтобы преимущества не были замаскированы высоким параллелизмом.

```shell
$ run-with-cores 4 'time go build -o /dev/null ./pilot/cmd/pilot-discovery'

real    1m29.778s
```

```shell
$ run-with-cores 4 '
time go build -o /dev/null ./pilot/cmd/pilot-discovery &
time go build -o /dev/null ./pilot/cmd/pilot-discovery &
time wait
'

real    2m58.492s
real    2m58.650s
```

Интересно, что это намного медленнее, чем я ожидал. 
Это некорректный тест, поскольку мы запускаем обе сборки при одинаковом ограничении на 4 ядра CPU.

Вместо этого нам нужно запускать их отдельно, но с общим кэшем:

```shell
$ function run-with-cores-cached() {
  cores="$1"
  shift
  docker run --rm -v $PWD:$PWD -w $PWD \
    --cpus="$cores" -e GOMAXPROCS="$cores" \
    -e 'GOFLAGS=-buildvcs=false' \
    -v `go env GOMODCACHE`:/go/pkg/mod \
    -v /tmp/gocache:/root/.cache/go-build \
    --init golang:1.20 bash -c "$*"
}
$ run-with-cores 4 'time go build -o /dev/null ./pilot/cmd/pilot-discovery' &
$ run-with-cores 4 'time go build -o /dev/null ./pilot/cmd/pilot-discovery' &
$ wait
real    1m34.677s
real    1m36.572s
$ run-with-cores 4 'time go build -o /dev/null ./pilot/cmd/pilot-discovery'
real    0m5.163s
```

И мы видим, что при одновременном запуске кэширование практически не происходит. 
Однако если мы сделаем еще одну сборку после этого, то увидим, что кэш работает - просто не одновременно.

Это вполне объяснимо: теоретически, если при каждом выполнении выполняются одни и те же шаги за одинаковое время, 
никакие действия не будут кэшироваться. Тем не менее я удивлен тем, насколько незначительны улучшения.

#### Поэтапная сборка

Что, если мы немного раздвинем сроки сборки?

```shell
$ run-with-cores 4 'time go build -o /dev/null ./pilot/cmd/pilot-discovery' &
$ sleep 20
$ run-with-cores 4 'time go build -o /dev/null ./pilot/cmd/pilot-discovery' &
$ wait
real    1m11.095s
real    1m31.409s
$ run-with-cores 4 'time go build -o /dev/null ./pilot/cmd/pilot-discovery' &
$ sleep 60
$ run-with-cores 4 'time go build -o /dev/null ./pilot/cmd/pilot-discovery' &
$ wait
real    1m31.126s
real    0m30.614s
```

Мы видим тенденцию: сколько бы мы ни ждали, сборка происходит намного быстрее. 
Это логично: мы можем либо выполнить работу по компиляции за N секунд, либо подождать, 
пока это сделает другой процесс (тоже за N секунд), и прочитать кэшированный результат <i>незамедлительно</i>.

#### Несоответствие размеров сборки

Выше у нас было точно такое же распределение процессора. А что, если у нас есть несоответствие?

```shell
$ run-with-cores 40 'time go build -o /dev/null ./pilot/cmd/pilot-discovery' &
$ run-with-cores 4 'time go build -o /dev/null ./pilot/cmd/pilot-discovery' &
$ wait
real    0m32.319s
real    0m32.959s
```

И снова мы видим точно такое же время сборки, но на этот раз оно больше у самого быстрого сборщика. 
Таким образом, наш медленный сборщик может воспользоваться преимуществами более быстрого сборщика.

Интересно, что это означает, что троттлинг некоторых задач может принести пользу. Запуск того же теста, 
но с предоставлением каждой задаче доступа ко всем ядрам, приводит к замедлению общего времени выполнения:

```shell
$ run-with-cores 48 'time go build -o /dev/null ./pilot/cmd/pilot-discovery' &
$ run-with-cores 48 'time go build -o /dev/null ./pilot/cmd/pilot-discovery' &
$ wait
real    0m37.321s
real    0m37.571s
```

Однако разница не так велика. Возможно, это связано с тем, что при 48 ядрах компилятор 
Go не выжимает максимум из процессора. Скорее всего, мы увидели бы другие результаты, 
если бы наша хост-машина была меньше.

Мы можем довести это до крайности и выполнять сразу несколько заданий:

```shell
$ for i in {0..15}; do
  run-with-cores-cached 48 'time go build -o /dev/null ./pilot/cmd/pilot-discovery' &
done
$ wait
...
real    2m11.136s # (repeated 16x)
...

```

Значительно медленнее. К плюсам можно отнести то, 
что это был один из первых случаев, когда я максимально задействовал процессор своей машины.

Если у нас будет только одна быстрая работа, а остальные - поменьше, мы получим гораздо лучшие результаты:

```shell
$ run-with-cores-cached 36 'time go build -o /dev/null ./pilot/cmd/pilot-discovery' &
$ for i in {0..14}; do
  run-with-cores-cached 1 'time go build -o /dev/null ./pilot/cmd/pilot-discovery' &
done
$ wait
...
real    0m39.383s # (repeated 16x)
...

```

### Конкурентность сборки

(Thanks to [@josharian](https://github.com/josharian) for the suggestion!)

Компилятор Go имеет [множество флагов](https://pkg.go.dev/cmd/compile), которые мы можем настраивать. 
Среди них `-c`, который управляет "параллельностью во время компиляции". 
По умолчанию это максимальное значение между `GOMAXPROCS` и `4`. 
Обратите внимание, что этот флаг отличается от `-p`, который управляет количеством операций сборки, 
выполняемых одновременно (подробнее обсуждается в [интеграционных тестах](#интеграционные-тесты)); 
этот флаг управляет параллельностью одной операции сборки.

Поскольку мы используем Go 1.20, в которой пока нет [исправления](https://go-review.googlesource.com/c/go/+/465095) 
для этого флага, 
мы также установили `GO19CONCURRENTCOMPILATION=0` для обходного пути. 
Это запретит Go устанавливать свой собственный флаг `-c`, так что он будет уважать наш флаг, 
установленный вручную (в противном случае он всегда будет добавлять свой собственный флаг 
по умолчанию после нашего).

<i>На момент перевода статьи, актуальная версия Go уже 1.22.4 и это изменение вмержено в мастер.</i>

Давайте попробуем:

```shell
$ run time env GO19CONCURRENTCOMPILATION=0 go build '-gcflags=all="-c=1"' ./pilot/cmd/pilot-discovery
run time env GO19CONCURRENTCOMPILATION=0 go build '-gcflags=all="-c=4"' ./pilot/cmd/pilot-discovery
run time env GO19CONCURRENTCOMPILATION=0 go build '-gcflags=all="-c=48"' ./pilot/cmd/pilot-discovery
run time env GO19CONCURRENTCOMPILATION=0 go build '-gcflags=all="-c=256"' ./pilot/cmd/pilot-discovery

real    0m40.473s
real    0m32.385s
real    0m29.666s
real    0m31.711s
```

Мы видим, что, как и при настройке `GOMAXPROCS`, мы получаем оптимальные результаты при установке значения, 
соответствующего нашему реальному количеству процессоров. Разница, однако, довольно мала 
по сравнению с управлением `GOMAXPROCS` или `-p`.


### Сборка нескольких бинарников

До сих пор мы рассматривали создание только одного бинарника. А что, если нам нужно собрать несколько?

Давайте попробуем несколько различных подходов к сборке нескольких двоичных файлов:

1. Последовательная сборка

```shell
$ BINARIES="./istioctl/cmd/istioctl ./pilot/cmd/pilot-discovery ./pkg/test/echo/cmd/client ./pkg/test/echo/cmd/server ./samples/extauthz/cmd/extauthz ./operator/cmd/operator ./tools/bug-report"
$ run "
time {
for bin in $BINARIES; do
  go build -o /tmp/ \$bin
done
};
"

real    1m25.276s
```

2. Параллельная сборка

```shell
$ run "
for bin in $BINARIES; do
  go build -o /tmp/ \$bin &
done
time wait
"

real    1m4.005s
```

3. Сборка в единый `go build`

```shell
$ run "time go build -o /tmp/ $BINARIES"

real    0m44.410s
```

Сборка с помощью одной команды `go build` значительно быстрее!

Исходя из нашего другого анализа, это вполне логично.

При последовательной сборке можно получить доступ к кэшу предыдущих сборок, 
но все новые зависимости нужно будет собирать, а связывание не может быть выполнено параллельно.

Параллельная сборка немного лучше, но, как мы видели в [Параллельной сборке](#Параллельная-сборка), 
кэширование ограничено при параллельном выполнении.

Использование одной команды позволяет Go максимизировать параллельность.


## Тесты

Что касается компиляции тестов? В Go каждый пакет генерирует отдельный тестовый бинарник.
```shell
$ go list ./... | wc -l
497
```

Это означает, что при запуске `go test ./...` будет сгенерировано почти 500 двоичных файлов! 
В результате время компиляции может быть особенно важным при запуске тестов.

```shell
$ run '
time go test -c -o /tmp/build ./pilot/pkg/xds
time go test -c -o /tmp/build ./pilot/pkg/xds
'
real    0m31.007s
real    0m1.760s
```

Речь идет о времени, затраченном на сборку.

### Состояние гонки

[Детектор гонок](https://go.dev/doc/articles/race_detector) очень полезен для тестов; 
мы всегда запускаем тесты со включенным детектором. 
Однако за это приходится платить:

```shell
$ run 'time go test -c -o /tmp/build -race ./pilot/pkg/xds'

real    0m44.167s
```

Почти на 50% больше времени сборки.

### Vet
Go автоматически запускает некоторые линтеры при компиляции тестов. Их можно отключить:
```shell
$ run 'time go test -c -o /tmp/build -vet=off ./pilot/pkg/xds'

real    0m28.965s
user    5m8.443s
sys     1m18.009s
$ run 'time go test -c -o /tmp/build ./pilot/pkg/xds'

real    0m30.658s
user    6m49.299s
sys     1m43.606s
```

Здесь мы видим небольшое улучшение `real`, но довольно большое улучшение 
`user`; я подозреваю, что 48 ядер маскируют некоторые издержки на запуск команды vet.
### Кэширование тестов

Разогревает ли сборка бинарного файла кэш для сборки тестов?
```shell
$ run '
time go build -o /tmp/build ./pilot/cmd/pilot-discovery
time go test -c -o /tmp/build ./pilot/pkg/xds
'

real    0m31.690s
real    0m8.980s
```

Да, это так!

А если использовать `-race`?

```shell
$ run '
time go build -o /tmp/build ./pilot/cmd/pilot-discovery
time go test -c -o /tmp/build -race ./pilot/pkg/xds
'

real    0m31.551s
real    0m43.568s
```

Нет, здесь мы теряем выгоду от кэша!

## Линковка и компиляция

Чтобы измерить время, потраченное на компоновку по сравнению с компиляцией, 
мы можем создать пользовательский инструмент для компиляции <i>без компоновки</i>. 
Это очень полезно для проверки компиляции всего кода/тестов, поэтому мы измерим это ниже.

Это можно сделать и в [Go 1.21](https://github.com/golang/go/issues/15513),
но сработает линковка, если у вас есть пакеты с таким же именем. 

Вместо этого мы можем использовать обходной путь - просто не запускать линковку.

```shell
$ run '
time go test -exec=true -vet=off ./...
time go test -exec=true -vet=off ./...
'
real    2m33.337s
real    0m51.978s
'
```

Даже повторные запуски выполняются довольно медленно. 
Учитывая то. что мы знаем, что вся компиляция кэшируется, мы можем сделать вывод, 
что компоновка всех тестовых двоичных файлов занимает примерно 50 секунд.

Теперь попробуем без линковки:
```shell

# Setup our tool
$ cat <<'EOF' > ./go-compile-without-link
#!/bin/bash

if [[ "${2}" == "-V=full" ]]; then
  "$@"
  exit 0
fi
case "$(basename ${1})" in
  link)
    # Output a dummy file
    touch "${3}"
    ;;
  *)
    "$@"
esac
EOF

$ chmod +x go-compile-without-link
# Now build without linking
$ run '
time go test -exec=true -toolexec=$PWD/go-compile-without-link -vet=off ./...
time go test -exec=true -toolexec=$PWD/go-compile-without-link -vet=off ./...
'

real    1m18.623s
real    0m3.055s
```

Это не только в 2 раза быстрее в целом, но и почти в 20 раз быстрее с прогретым кэшем. 
Это огромный выигрыш при разработке. 
Я регулярно выполняю приведенную выше команду перед коммитом в качестве легковесной проверки.

Предупреждение: при этом могут быть пропущены некоторые 
[ошибки времени линковки](https://github.com/golang/go/issues/15513#issuecomment-1416190695). 

По моему опыту, они встречаются достаточно редко, что делает эту команду чрезвычайно полезной для разработки.
Если вы используете CGO, это может быть не так.

### Альтернативные компоновщики

Учитывая, что линковка вносит такой большой вклад в медленное время сборки, 
что если использовать более быстрый компоновщик? 
[mold](https://github.com/rui314/mold) - это широко используемый компоновщик в других языках, 
предлагающий впечатляющие улучшения по сравнению с другими компоновщиками. 
Хотя он не так распространен, его можно использовать и в Go.

Поскольку время компоновки составляет порядка нескольких секунд, 
мы будем использовать [hyperfine](https://github.com/sharkdp/hyperfine) для более точного измерения времени.

```shell
$ hyperfine 'rm test; time go build -ldflags "-linkmode external -extld clang -extldflags -fuse-ld=mold"' 'rm test; time go build'
Benchmark 1: rm test; time go build -ldflags "-linkmode external -extld clang -extldflags -fuse-ld=mold"
  Time (mean ± σ):      1.880 s ±  0.038 s    [User: 2.876 s, System: 2.142 s]
  Range (min … max):    1.815 s …  1.938 s    10 runs

Benchmark 2: rm test; time go build
  Time (mean ± σ):      1.582 s ±  0.022 s    [User: 2.693 s, System: 1.043 s]
  Range (min … max):    1.549 s …  1.615 s    10 runs

Summary
  'rm test; time go build' ran
    1.19 ± 0.03 times faster than 'rm test; time go build -ldflags "-linkmode external -extld clang -extldflags -fuse-ld=mold"'
```

Похоже, что в этом случае линковка с использованием `mold` происходит немного медленнее.

## Анализ времени сборки

Есть несколько инструментов, которые помогут проанализировать время сборки.

### Пользовательская обертка `toolexec`.

Примечание: этот вариант не самый лучший, но я написал этот раздел до того, 
как нашел другие (лучшие) инструменты.

Go может выдавать подробные журналы сборок с помощью параметра `-x`, 
но это действительно многословно. 
К счастью, мы можем обернуть вызовы инструментов 
[скриптом](https://github.com/istio/istio/blob/master/tools/go-compile-verbose), который записывает в журнал то, 
что конкретно занимает время.

Его можно вызвать с помощью `-toolexec` во время сборки.

Вот результаты сборки одного и того же бинарника `./pilot/cmd/pilot-discovery`. 
Обратите внимание: поскольку мы используем несколько ядер, в сумме получается больше времени, 
чем фактически затрачено. Это примерно соответствует `user` из предыдущих запусков `time`.

**Action** | **SUM of Duration**
link | 3.789593331
gcc |	0.022386331
compile | 305.6692171
cgo | 1.526077562
asm	| 2.99016495
**Grand Total**	| **313.9974393**

Как видно из таблицы, больше всего времени тратится на `compile`, 
поэтому мы сосредоточимся на этом пункте. 
Интересен и `link` - несмотря на то, что он занимает всего 1% времени, 
он наименее кэшируемый и распараллеливаемый.

Рассмотрим каждый модуль отдельно:

**Location** | **SUM of Duration**
k8s.io/client-go | 67.86363857
github.com/envoyproxy/go-control-plane | 48.72126327
local	| 44.15472995
std | 25.53394494
k8s.io/api | 23.03486699
k8s.io/apimachinery | 7.960915542
google.golang.org/grpc | 6.152948778
google.golang.org/protobuf | 5.491289355
istio.io/client-go | 4.632729928
istio.io/api | 4.437340682
github.com/google/cel-go | 4.240151317
k8s.io/kube-openapi | 3.00321029
github.com/google/gnostic | 2.668591864
golang.org/x/net | 2.611716846
k8s.io/apiextensions-apiserver | 2.411767233
github.com/google/s2a-go | 2.291722416
github.com/gogo/protobuf | 2.07997357
github.com/google/go-containerregistry | 2.050610622

Модулей довольно много, поэтому в список включены только те, которые заняли больше двух секунд. 
`local` означает, что это код локального модуля (Istio), а `std` - обозначает стандартную библиотеку Go.

А как насчет отдельных файлов? Рассмотрим те, компиляция которых занимает больше 1 секунды:

**File** | **SUM of Duration**
core/v1/zz_generated.deepcopy.go | 3.901002923
src/runtime/write_err.go | 1.755470748
envoy/config/route/v3/scoped_route.pb.validate.go | 1.579764655
parser/gen/doc.go | 1.490590828
src/net/http/transport_default_other.go | 1.475054625
utils_set.go | 1.436838859
envoy/config/core/v3/udp_socket_config.pb.validate.go | 1.436230022
pilot/pkg/serviceregistry/kube/controller/util.go | 1.399423632
pilot/pkg/xds/xdsgen.go | 1.373964964
pilot/pkg/model/xds_cache.go | 1.341942513
ztypes.go | 1.336568761
yamlprivateh.go | 1.220097377
proto/wrappers_gogo.go | 1.193810348
openapiv2/document.go | 1.122113029
openapiv3/document.go | 1.086110353
pilot/pkg/bootstrap/webhook.go | 1.054076742
pilot/pkg/config/kube/gateway/model.go | 1.051825111
pilot/pkg/networking/core/v1alpha3/waypoint.go | 1.000428311

Подозреваю, что данные, полученные при анализе отдельных файлов  
немного искажены. Маловероятно, что [write_err.go](https://go.dev/src/runtime/write_err.go), 
14-строчный файл, реально занимает 1,7 секунд компиляции. 
Скорее всего, более уместен анализ на уровне пакета. 
С этим справляются другие инструменты, рассмотренные далее.

### Граф действий

Go предоставляет очень полезный, недокументированный флаг `-debug-actiongraph`, 
который может выдать "граф действий", сгенерированный во время сборки. 
По сути, граф действий - это [направленный ацикличный граф](https://habr.com/ru/companies/otus/articles/473096/) шагов, 
которые компилятор выполняет для компиляции, компоновки, запуска тестов и т. д. 
Флаг `-debug-actiongraph` выдает этот граф в виде JSON-файла, вместе с таймингами.

```shell
$ run 'go build -debug-actiongraph=/tmp/actiongraph ./pilot/cmd/pilot-discovery'
```

Общий результат довольно велик, но для некоторого контекста один элемент выглядит так:
```json
{
  "ID": 1500,
  "Mode": "build",
  "Package": "github.com/modern-go/concurrent",
  "Deps": [
    27,
    8,
    266,
    175,
    5,
    96,
    6,
    931,
    45,
    24
  ],
  "Objdir": "/tmp/go-build1707548832/b322/",
  "Priority": 313,
  "NeedBuild": true,
  "ActionID": "rfdTmXlzNWtJZwTp13Ge",
  "BuildID": "rfdTmXlzNWtJZwTp13Ge/OeZ8FbMdRkPAoFt_nshl",
  "TimeReady": "2023-07-05T17:13:41.827369909Z",
  "TimeStart": "2023-07-05T17:13:41.838775857Z",
  "TimeDone": "2023-07-05T17:13:41.930219542Z",
  "Cmd": [
    "/usr/local/go/pkg/tool/linux_amd64/compile -o /tmp/go-build1707548832/b322/_pkg_.a -trimpath \"/tmp/go-build1707548832/b322=>\" -p github.com/modern-go/concurrent -lang=go1.16 -complete -buildid rfdTmXlzNWtJZwTp13Ge/rfdTmXlzNWtJZwTp13Ge -goversion go1.20.5 -c=4 -nolocalimports -importcfg /tmp/go-build1707548832/b322/importcfg -pack /go/pkg/mod/github.com/modern-go/concurrent@v0.0.0-20180306012644-bacd9c7ef1dd/executor.go /go/pkg/mod/github.com/modern-go/concurrent@v0.0.0-20180306012644-bacd9c7ef1dd/go_above_19.go /go/pkg/mod/github.com/modern-go/concurrent@v0.0.0-20180306012644-bacd9c7ef1dd/log.go /go/pkg/mod/github.com/modern-go/concurrent@v0.0.0-20180306012644-bacd9c7ef1dd/unbounded_executor.go"
  ],
  "CmdReal": 87273795,
  "CmdUser": 52534000,
  "CmdSys": 8082000
}
```

К счастью, тулза [actiongraph](https://github.com/unravelin/actiongraph) может помочь 
представить это в более удобочитаемом виде:

```shell
$ actiongraph -f /tmp/actiongraph top
  4.143s   1.41%  build k8s.io/api/core/v1
  4.077s   2.80%  link  istio.io/istio/pilot/cmd/pilot-discovery
  1.936s   3.45%  build net
  1.851s   4.08%  build runtime
  1.533s   4.61%  build github.com/google/cel-go/parser/gen
  1.518s   5.12%  build github.com/envoyproxy/go-control-plane/envoy/config/route/v3
  1.492s   5.63%  build github.com/envoyproxy/go-control-plane/envoy/config/core/v3
  1.464s   6.13%  build github.com/antlr/antlr4/runtime/Go/antlr/v4
  1.463s   6.63%  build istio.io/istio/pilot/pkg/xds
  1.463s   7.12%  build istio.io/istio/pilot/pkg/serviceregistry/kube/controller
  1.428s   7.61%  build istio.io/istio/pilot/pkg/model
  1.420s   8.09%  build net/http
  
$ actiongraph -f /tmp/actiongraph tree -L 2 | head -n 20
289.792s          (root)
101.954s            k8s.io
 64.735s              k8s.io/client-go
 23.827s              k8s.io/api
  6.883s              k8s.io/apimachinery
  2.853s              k8s.io/kube-openapi
  2.424s              k8s.io/apiextensions-apiserver
  0.610s              k8s.io/utils
  0.400s              k8s.io/klog
  0.222s              k8s.io/apiserver
 78.280s            github.com
 42.103s              github.com/envoyproxy
 12.069s              github.com/google
  2.473s              github.com/prometheus
  2.052s              github.com/gogo
  1.562s              github.com/lestrrat-go
  1.464s              github.com/antlr
  1.449s              github.com/klauspost
  1.331s              github.com/miekg
  0.990s              github.com/cncf

```

Мы получаем примерно ту же информацию, что и выше, но гораздо более простую в использовании и запросах.

### Трассировка
В Go также есть новая функция `-debug-trace`, которая выдает довольно похожую информацию, 
но в формате 
[Trace Event Format](https://docs.google.com/document/d/1CvAClvFfyA5R-PhYUmn5OOQtYMH4h6I0nSsKchNAySU/preview). 
Это очень простой формат, но он дает нам много информации

Записи в трассировке выглядят следующим образом:
```json
[{"name":"Executing action (link istio.io/istio/pilot/cmd/pilot-discovery)","ph":"B","ts":1688578195814105.2,"pid":0,"tid":43}
,{"name":"Executing action (link istio.io/istio/pilot/cmd/pilot-discovery)","ph":"E","ts":1688578195827795.8,"pid":0,"tid":43}]
```

`ph: B` представляет время "Begin", а `ph: E` обозначает время "End". `tid` - это горутина.

Их можно визуализировать, чтобы получить представление о том, сколько времени тратит каждая из горутин. 
Некоторые примеры приведены ниже:

* [Building with 48 GOMAXPROCS](https://ui.perfetto.dev/#!/?s=6872d4938c2308148c4f811785b522c2f1e376de39c62f80146d2b7ab2e5dba6)
* [Building with 4 GOMAXPROCS](https://ui.perfetto.dev/#!/?s=cb51fc97fdaf1b7767e4fc38c9d9badf245d6367fa5aa00a5ad445a6d99c41da)

Здесь мы видим, что, хотя 48 ядер выполняются быстрее, много времени уходит на бездействие. 
Дальнейшее исследование показало, что это происходит потому, 
что не остается никакой работы - все ядра заблокированы и ждут, 
пока другое ядро завершит свою часть работы с зависимостями.

Еще один интересный момент: в обоих случаях мы видим, что время выполнения сборки 
блокирует все остальные потоки примерно на 2 секунды.

Представление трассировки невероятно полезно для понимания не только времени выполнения каждого действия, 
но и контекста. Гораздо хуже, если что-то занимает 10 секунд, 
и блокирует все остальные потоки, а не выполняется параллельно.


### Профилирование

Go также предоставляет возможность профилировать компиляцию и линковку. 
Например: 
```shell
go build -ldflags='-cpuprofile /tmp/linker-cpu.prof' -gcflags='-cpuprofile /tmp/compiler-cpu.prof' .
```

Однако результирующий `cpuprofile` пуст, поэтому я подозреваю, что сделал что-то не так.
Однако, в любом случае, меня больше интересует компоновщик.

При линковке тестовой программы получается вот такой 
[профиль](https://flamegraph.com/share/18a5b502-1b63-11ee-b13f-de9431916b05). 
Как и ожидалось, здесь ничего не выделяется в качестве очевидного бутылочного горлышка - 
компилятор Go довольно хорошо оптимизирован.

### Goda
[`goda`](https://github.com/loov/goda) - "Go Dependency Analysis toolkit"

`goda` - один из моих любимых инструментов для понимания процесса сборки Go.

Хотя он не анализирует `время` сборки напрямую, 
он неоценим для понимания зависимостей в программе на Go. 
Как мы видели выше, зависимости вносят огромный вклад во время сборки, 
поэтому эти два аспекта тесно связаны.

Хотя `goda` имеет большое количество функций, 
моими любимыми являются tree и reach. Например, мы можем узнать, каким образом один пакет зависит от другого пакета:

```shell
$ goda tree 'reach(./pilot/cmd/pilot-discovery:all, k8s.io/api/authorization/v1beta1)' | head
  ├ istio.io/istio/pilot/cmd/pilot-discovery
    └ istio.io/istio/pilot/cmd/pilot-discovery/app
      └ istio.io/istio/pilot/pkg/bootstrap
        ├ istio.io/istio/pilot/pkg/config/kube/crdclient
          ├ istio.io/istio/pkg/kube
            ├ istio.io/client-go/pkg/clientset/versioned
              └ k8s.io/client-go/discovery
                └ k8s.io/client-go/kubernetes/scheme
                  └ k8s.io/api/authorization/v1beta1
```

## Анализ реального приложения

Используя описанные выше инструменты, я попытался понять, почему наши сборки были медленными.

### Медленное выполнение тестов

Анализируя реальные трассы компиляции во время работы нашего CI, 
я обнаружил кое-что странное в задании юнит-теста `go test ./...`.

Ниже показан фрагмент трассировки:
![](https://blog.howardjohn.info/images/test-trace.png#center)

[Полный трэйс](https://ui.perfetto.dev/#!/?s=38a5b5f85d0a548a8725917622db8fcaf8f7a64b051aa21544a9987ae0d5e67b) 
также доступен, но весит больше 150MB

Мы видим, что `test run istio.io/istio/pkg/test/framework/resource/config/cleanup` 
выполняется почти все время выполнения теста, более 50 секунд. 
Если копнуть глубже, то можно обнаружить еще более интересную вещь - `в этом пакете нет тестов`.

Причину этого можно найти, изучив, что на самом деле делает действие `test run`. В общем случае граф действий 
компилятора Go гарантирует, что действия не будут выполняться до тех пор, пока не будут завершены все зависимости. 
Однако для того, чтобы журналы запуска тестов выдавались в правильном порядке, 
была добавлена некоторая сериализация запусков тестов вне этого механизма зависимостей. 
Это можно найти [здесь](https://github.com/golang/go/blob/894d24d617bb72d6e1bed7b143f9f7a0ac16b844/src/cmd/go/internal/test/test.go#L1220).

В результате даже очень быстрый тест (или вообще пакет без тестов) может начаться, 
а затем сразу же заблокироваться до завершения других задач. 
Это означает, что в конечном итоге мы вынуждены задерживать воркера (обычно на каждое ядро приходится по одному воркеру), 
ожидая завершения другой задачи.

В крайнем случае, самый `последний` по алфавиту пакет может быть запущен первым, 
что приведет к блокировке всего воркера на все время тестирования.

На основе этого анализа был открыт [Go issue](https://github.com/golang/go/issues/61233) и 
[предложил возможное исправление](https://go.dev/cl/508515).

### Интеграционные тесты

В Istio интеграционные тесты отделены от модульных тестов тегом сборки `integ`. 
Кроме того, ожидается, что тесты будут запускаться с параметром `-p 1`, 
который указывает Go на выполнение только одного пакета за раз.

Это гарантирует, что к общим ресурсам (кластерам Kubernetes, в общем случае) 
не будет одновременного доступа.

Интеграционные тесты, в частности, всегда казались в Istio немного медленными. 
Если посмотреть на трассировку сборки, то причина становится очевидной: `-p 1` сделал больше, чем мы хотели!

Мы хотели, чтобы тесты выполнялись последовательно - но это также компилирует их последовательно.

Это занимает `8 минут 25 секунд`.

Я не нашел никаких отличных способов исправить это из коробки, 
но мы можем использовать некоторые из наших предыдущих выводов, чтобы улучшить ситуацию.

```
$ run '
time go test -exec=true -toolexec=$PWD/go-compile-without-link -vet=off -tags=integ ./tests/integration/...
time go test -exec=true -vet=off -tags=integ -p 1 ./tests/integration/...
'
```

Здесь мы сначала прекомпилируем все (без линковки), чтобы прогреть кэш сборки, а затем выполняем тесты как обычно. 
Первый шаг занимает всего `40 секунд`, а выполнение - `3 минуты 40 секунд` - в целом в **2 раза быстрее**, 
чем при обычном подходе.


Тем не менее мы могли бы сделать сильно лучше. Большая часть времени уходит на линковку тестовых бинарников, 
которая по-прежнему выполняется последовательно. Мы не можем просто собрать и линкануть все перед выполнением, 
как мы видели ранее - линковка кэшируется только при сохранении бинарника.

Эта проблема несколько решена в [Go 1.21](https://github.com/golang/go/commit/b611b3a8cc8c4cab3853853a135d5c29e807f513), 
который позволяет использовать опцию `-c` (позволяет сохраняет тестовый бинарник) 
при тестировании нескольких пакетов. Однако это может быть неудобно в использовании, 
так как любые имена пакетов будут конфликтовать.

У нас было довольно много конфликтов, которые привели к такому хаку:

```shell
$ run-21 '
grep -r TestMain tests/integration -l |
  xargs -n1 dirname |
  sort |
  uniq |
  grep -v tests/integration/telemetry/stackdriver/api |
  grep -v tests/integration/security/fuzz |
  grep -v tests/integration$ |
  xargs -I{} echo './{}' |
  xargs go test -tags=integ -c -o testsout/ -vet=off 
grep -r TestMain tests/integration -l |
  xargs -n1 dirname |
  sort |
  uniq |
  grep -v tests/integration/telemetry/stackdriver/api |
  grep -v tests/integration/security/fuzz |
  grep -v tests/integration$ |
  xargs -I{} echo './{}' |
  xargs go test -p 1 -tags=integ -o testsout/ -vet=off  -exec=true
'
```

Результаты превосходны - первый запуск занимает всего 50 секунд, а последующие - практически мгновенные.

### Kubernetes

Из раздела [Анализ времени сборки](#анализ-времени-сборки), мы увидели, что корень большинства наших проблем - 
библиотеки Kubernetes. Только от `k8s.io/client-go` и нескольких его зависимостей (`k8s.io/api` и `k8s.io/apimachinery`) 
мы получаем время компиляции до **100 секунд**!

Это стандарт для любого проекта, взаимодействующего с Kubernetes, 
что составляет довольно большой сегмент использования Go. 
Не считая форков, кубер используют более 
[10 тысяч проектов на GitHub](https://github.com/search?type=code&q=k8s.io%2Fclient-go+path%3Ago.mod+NOT+is%3Afork)!

Проблема не только во времени компиляции!

Простое импортирование этой библиотеки приводит к удивительным результатам и для размера бинарника:

```shell
$ go mod init test
$ cat <<EOF>main.go
package main

import _ "k8s.io/client-go/kubernetes"

func main() {}
EOF
$ go mod tidy
$ go build
$ du -h main
40M     main

```

Ух ты! 40 мб для нашего ну оооочень пустого бинарника!

Kubernetes кажется почти уникально плохим в этом отношении, но и `envoyproxy` не отстает!
`github.com/envoyproxy/go-control-plane` тоже выглядит довольно плохо - компилится 50 секунд. 
Но это примерно вдвое меньше, чем у Kubernetes.

Istio [явно импортирует](https://github.com/istio/istio/blob/411f2d73e707fead75fa9f4e7dd11bb763728ada/pkg/config/xds/filter_types.gen.go#L22) 
каждый пакет в модуле, что довольно нетипично. 
Удаление этого файла сокращает время компиляции `go-control-plane` до 15 секунд 
(при этом приличная часть библиотеки все еще импортируется за счет использования ядра).

Тот же самый простой бинарник, импортирующий `github.com/envoyproxy/go-control-plane/envoy/type`, занимает всего 6 Мб. 
Go также достаточно умен, чтобы полностью исключить зависимость в некоторых случаях; 
например, [grpc-go](https://github.com/grpc/grpc-go/blob/620a118c67c6e2392562ba32352670dd92dd02b6/go.mod#L9) зависит 
от `go-control-plane`, но не отображается как зависимость, 
если только не импортирован `xds` пакет (редкость для пользователей `grpc-go`).

Причина, по которой клиент Kubernetes так плох, заключается в том, что его нельзя использовать частями. 
Я предполагаю, что большинство приложений не используют `все версии всех API Kubernetes`. 
Но первое, что делает пользователь Go клиента кубера - 
[импортирует пакет](https://github.com/kubernetes/client-go/blob/0cde78477a6d3ec3682b922654942a9a21f3a9eb/kubernetes/clientset.go#L21-L79), 
который **зависит от всех версий всех API**. 
Это, в свою очередь, заставляет компилятор Go компилировать _все_ API Kubernetes для любого пользователя библиотеки.

Эти API содержат не только [здоровенные](https://github.com/kubernetes/api/blob/master/core/v1/types.go) структуры Go, 
но и сгенерированные документы [protobuf](https://github.com/kubernetes/api/blob/master/core/v1/generated.pb.go), 
[deepcopy](https://github.com/kubernetes/api/blob/master/core/v1/zz_generated.deepcopy.go) и 
[доку swagger](https://github.com/kubernetes/api/blob/master/core/v1/types_swagger_doc_generated.go).

Все это порождает комбинацию медленной компиляции и огромных бинарников. Так и живем.

### Упорядоченное выполнение тестов

Если порядок сборки довольно интуитивен, то с тестами дело обстоит несколько сложнее. 
Запуск `go test ./...` - это компиляция кучи кода, линковка тестового бинарника для каждого пакета, 
запуск `go vet` на нем, выполнение теста и вывод результата.

В реальном проекте это может быть слишком сложным, поэтому для анализа мы будем использовать фейковый проект:

```shell
for i in a b c d; do
	mkdir -p $i
	cat <<EOF > "$i/${i}_test.go"
package $i

import (
	"testing"
	"time"
)

func TestSleep(t *testing.T) {
	if "$i" == "b" {
		time.Sleep(time.Second)
	}
}
EOF
done
GOMAXPROCS=2 go test -debug-trace=trace ./...
```

Результаты в этом [трэйсе](https://ui.perfetto.dev/#!/?s=afb713a8b4929d54924c4c2d5a08b38299970a6ce454f9b95e2c44e8b5152708).

Здесь мы можем увидеть несколько интересных вещей:

* Выполнение тестов начинается по порядку (в алфавитном порядке).
* Один пакет будет полностью выполнен, прежде чем переходить к другой работе 
(то есть сначала мы собираем и выполняем пакет `a`, и не собираем `a-d`, прежде чем приступить к выполнению).
* Однако несколько процессов могут сделать вышеописанное неблокируемым. 
В нашем примере у нас есть один пакет, который проходит медленный тест. 
Пока он выполняется, остальные пакеты, могут проводить свои тесты

### Сборка и тестирование

Работа юнит-тестов в Istio - возможно, одна из самых важных задач, 
которая должна быть быстрой для быстрой итерации - уже много лет работает эффективно:

```shell
$ go build ./...
$ go test -race ./...
```

Это было сделано так потому, что необходимо проверять размер двоичных файлов релиза, чтобы избежать регрессий. 
Когда-то предполагалось, что это наиболее "подходящий" вариант.

Однако из анализа [обнаружения гонок](#состояние-гонки) мы знаем, что это не так!

Если кэш не прогрет, это добавит примерно 45 секунд к нашим джобам, 
которые выполняются на 16 CPU. Не конец света, но иногда каждая секунда имеет значение.

Это легко исправить, переместив прогон тестов в джобу, которая и так уже собирает бинарники.


## Сравнение с Rust
В отличие от Go, Rust часто критикуют за "медленное время сборки". Действительно ли он хуже Go?

Ответить на этот вопрос довольно сложно, так как они очень далеки друг от друга.

Мы можем получить очень приблизительные данные, взглянув на некоторые другие проекты. 
Обратите внимание, что в отличие от Go, Rust имеет разные профили разработки. 
Обычно сборки для разработки используются для локального тестирования, а сборки для релиза - для... релизов. 
Время обоих процессов сборки важно.

`[linked2-proxy](https://github.com/linkerd/linkerd2-proxy)`:
```shell
$ docker run --rm -v $PWD:$PWD -w $PWD -it --init --entrypoint bash ghcr.io/linkerd/dev:v40-rust -c '
cargo fetch
time cargo build --package=linkerd2-proxy
cargo clean
time cargo build --package=linkerd2-proxy --profile release
'

Finished dev [unoptimized] target(s) in 1m 43s
Finished release [optimized] target(s) in 5m 18s
```

`[ztunnel](https://github.com/istio/ztunnel)`:
```shell
$ docker run --rm -v $PWD:$PWD -w $PWD -it --init --entrypoint bash gcr.io/istio-testing/build-tools:master-4c71169512fe79b59b89664ef1b273da813d1c93 -c '
cargo fetch
time cargo build --package=linkerd2-proxy
cargo clean
time cargo build --package=linkerd2-proxy --profile release
'
Finished dev [unoptimized + debuginfo] target(s) in 40.71s
Finished release [optimized] target(s) in 2m 19s
```

Так что, высокоуровнево, это утверждение в какой-то степени справедливо, особенно если сравнивать время сборки релизов. 
По крайней мере, если сравнивать эти проекты, то Rust немного медленнее - но, на мой взгляд, не настолько, как принято считать.


<i>Данная статья является вольным переводом статьи [Analyzing Go Build Times](https://blog.howardjohn.info/posts/go-build-times/)</i>
