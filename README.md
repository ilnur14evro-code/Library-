# Library-

Локальная система Qwen 2.5-Coder агентов для Android + Termux.

## Полная установка

Откройте Termux и выполняйте команды по порядку.

### 1. Обновить Termux

```bash
pkg update -y
pkg upgrade -y
```

Если `pkg update` сообщает об ошибке зеркала:

```bash
termux-change-repo
pkg update -y
```

### 2. Установить базовые пакеты

```bash
pkg install -y git curl python clang cmake make
```

### 3. Скачать репозиторий

```bash
cd ~
git clone https://github.com/ilnur14evro-code/Library-.git
cd ~/Library-
```

Не используйте `<` и `>` вокруг URL.

Если `~/Library-` уже существует:

```bash
cd ~/Library-
git pull --ff-only
```

### 4. Установить локальный llama.cpp

Сначала автоматический установщик:

```bash
bash ./install_termux.sh
```

Он проверяет готовый `llama-cpp` и, если `llama-cli` отсутствует, собирает `llama.cpp` прямо в Termux.

Проверка:

```bash
llama-cli --version
```

### 5. Подготовить Qwen2.5-Coder

```bash
mkdir -p ~/models
ls -lh ~/models/*.gguf
```

Поместите локальную Qwen2.5-Coder GGUF-модель в `~/models/`.

Для первого запуска обычно разумно начать с 1.5B или 3B Q4. Если модели нужно другое имя, измените `MODEL_PATH` в:

```text
~/Library-/agent_system/config.py
```

### 6. Проверить Qwen до запуска агентов

```bash
llama-cli \
  -m ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf \
  -c 4096 \
  -n 64 \
  -p "Ответь одним словом: готов"
```

### 7. Подготовить игру

По умолчанию агент использует:

```text
~/Game
```

Проверьте:

```bash
ls -la ~/Game
```

При необходимости измените `PROJECT_DIR` в `agent_system/config.py`.

### 8. Проверить Python-часть

```bash
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
```

### 9. Запустить агента

```bash
cd ~/Library-/agent_system
python run_agent.py "Добавь главное меню в игру"
```

Цикл:

```text
Planner → Coder → Test → Fixer → Test
```

## Без API

После загрузки модели и зависимостей inference выполняется локально:

```text
Termux → Python → llama-cli → Qwen GGUF → файлы игры
```

API-ключ не нужен.

## Безопасность

Агент не получает произвольный shell-доступ. Команды тестов ограничены `ALLOWED_COMMANDS` в `agent_system/config.py`.

Файловые изменения ограничены `PROJECT_DIR`. Существующие файлы репозитория не удаляются установщиком.

## Если установка не проходит

Подробная пошаговая диагностика находится в:

```text
SETUP_TERMUX.md
```

Не удаляйте `~/Library-` для повторной установки. Сначала исправьте ошибку и повторите нужный шаг.
