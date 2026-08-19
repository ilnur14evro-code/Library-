# Library-

Локальная система Qwen 2.5-Coder агентов для Android + Termux.

## Полная установка: один основной сценарий

После установки актуального Termux выполните **только эти команды по порядку**:

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

### 2. Скачать Library-

```bash
pkg install -y git
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

### 3. Запустить автоматическую установку

```bash
bash ./install_termux.sh
```

Установщик автоматически:

```text
установит git/python/clang/cmake/make/curl
        ↓
проверит llama-cli
        ↓
установит llama-cpp или соберёт llama.cpp
        ↓
создаст ~/models
        ↓
скачает Qwen2.5-Coder-3B-Instruct Q4_K_M
        ↓
настроит MODEL_PATH
        ↓
проверит Qwen
        ↓
проверит Python-агентов
```

Q4_K_M-файл 3B занимает около 2.1 GB.

### Важно: не вводите название модели как команду

Неправильно:

```bash
Qwen2.5-Coder-3B-Instruct Q4_K_M
```

Это **название модели**, а не команда Termux. Установщик сам скачивает файл:

```text
~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

### 4. Проверить модель

```bash
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Затем:

```bash
llama-cli \
  -m ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf \
  -c 2048 \
  -n 32 \
  -p "Ответь одним словом: готов"
```

### 5. Подготовить игру

По умолчанию агент использует:

```text
~/Game
```

Проверить:

```bash
ls -la ~/Game
```

Если игра находится в другом месте, измените `PROJECT_DIR` в:

```text
~/Library-/agent_system/config.py
```

### 6. Проверить Python-часть

```bash
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
```

### 7. Запустить агента

```bash
cd ~/Library-/agent_system
python run_agent.py "Добавь главное меню в игру"
```

Цикл:

```text
Planner → Coder → Test → Fixer → Test
```

## Без API

После загрузки модели inference выполняется локально:

```text
Termux → Python → llama-cli → Qwen GGUF → файлы игры
```

API-ключ не нужен.

## Безопасность

Агент не получает произвольный shell-доступ. Команды тестов ограничены `ALLOWED_COMMANDS` в `agent_system/config.py`.

Файловые изменения ограничены `PROJECT_DIR`.

Установщик не выполняет `rm`, `git clean` или другие операции удаления файлов `Library-`.

## Повторная установка

Если установка была прервана:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Скачанный файл модели повторно не загружается. Прерванную загрузку установщик может продолжить.

**Не удаляйте `~/Library-` для повторной установки.**

## Подробная инструкция и диагностика

Смотрите:

```text
SETUP_TERMUX.md
```

Там разобраны ошибки `command not found`, `model not found`, проблемы `pkg`, сборка `llama.cpp`, память Android и проверка агентной системы.
