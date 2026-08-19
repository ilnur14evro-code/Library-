# Termux Game — Быстрый запуск на другом Android-смартфоне

## 1. Установить Termux

Рекомендуется F-Droid версия.

После запуска обновить пакеты:

```bash
pkg update
pkg upgrade -y
```

## 2. Установить необходимые пакеты

```bash
pkg install -y git clang make
```

Проверка:

```bash
git --version
clang --version
make --version
```

## 3. Скачать проект

```bash
git clone <https://github.com/ilnur14evro-code/Game>
```

Перейти в каталог проекта:

```bash
cd Game
```

Проверить ветку:

```bash
git branch
```

Если нужно:

```bash
git checkout dev
git pull
```

## 4. Сборка игры

```bash
make
```

Должен появиться файл:

```bash
ls -l termux_game
```

## 5. Запуск игры

```bash
./termux_game
```

Управление:

```text
W A S D  — движение
N        — включить/выключить AI
Q        — выход
ESC      — выход
```

## 6. Полный запуск тестов

```bash
make test
```

Ожидаемый результат:

```text
entity test: ok
player test: ok
collision test: ok
camera test: ok
component test: ok
brain test: ok
```

## 7. Отдельные тесты

Entity:

```bash
make test_entity
```

Player:

```bash
make test_player
```

Collision:

```bash
make test_collision
```

Camera:

```bash
make test_camera
```

Component:

```bash
make test_component
```

Brain:

```bash
make test_brain
```

## 8. Проверка использования памяти

Запустить игру:

```bash
./termux_game
```

В другом окне Termux:

Найти PID:

```bash
pidof termux_game
```

Наблюдение:

```bash
watch -n1 'ps -p $(pidof termux_game) -o pid,rss,vsz,%cpu'
```

## 9. Сохранение истории памяти и CPU

```bash
while true; do
    date '+%F %T'
    ps -p $(pidof termux_game) -o rss,vsz,%cpu
    echo
    sleep 5
done > game_session.log
```

Остановить:

```bash
Ctrl+C
```

Просмотр:

```bash
tail -50 game_session.log
```

## 10. Копирование логов в память телефона

Один раз выдать разрешение:

```bash
termux-setup-storage
```

Скопировать лог:

```bash
cp game_session.log ~/storage/shared/
```

После этого файл будет доступен через файловый менеджер Android.

## 11. Обновление проекта

```bash
git pull
```

Если изменились исходники:

```bash
make clean
make
```

После этого снова:

```bash
make test
```

Все тесты должны завершаться успешно.
