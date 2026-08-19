# Library-

Локальная система Qwen 2.5-Coder агентов для Android + Termux.

## Установка на телефон

В Termux выполните:

```bash
pkg update -y
pkg upgrade -y
pkg install -y git curl
```

Затем скачайте репозиторий:

```bash
cd ~
git clone https://github.com/ilnur14evro-code/Library-.git
cd ~/Library-
```

Не используйте `<` и `>` вокруг URL.

После клонирования запустите установщик:

```bash
bash ./install_termux.sh
```

Он установит зависимости и подготовит локальный `llama-cli`. Если `llama-cli` уже установлен, повторная сборка не выполняется.

## Быстрая проверка

```bash
cd ~/Library-
llama-cli --version
```

## Модель

Создайте каталог:

```bash
mkdir -p ~/models
```

Положите туда локальную GGUF-модель Qwen2.5-Coder. По умолчанию агент ожидает:

```text
~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Точный путь можно изменить в:

```text
agent_system/config.py
```

## Запуск агентов

```bash
cd ~/Library-/agent_system
python run_agent.py "Добавь главное меню в игру"
```

Цикл:

```text
Planner → Coder → Test → Fixer → Test
```

## Важно

Система рассчитана на локальную работу без API после первоначальной загрузки модели и зависимостей.

Существующие файлы репозитория не удаляются установщиком.

Подробная инструкция:

```text
SETUP_TERMUX.md
```
