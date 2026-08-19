# Library-

Локальная система Qwen 2.5-Coder агентов для Android + Termux.

## Установка с нуля — один сценарий

Выполняйте команды **по порядку**. Название модели не является командой Termux.

### 1. Установить Termux

Используйте актуальный Termux из F-Droid или официального GitHub-репозитория Termux.

После запуска:

```bash
pkg update -y
pkg upgrade -y
```

Если `pkg update` сообщает об ошибке зеркала:

```bash
termux-change-repo
pkg update -y
```

### 2. Скачать репозиторий

```bash
pkg install -y git
cd ~
git clone https://github.com/ilnur14evro-code/Library-.git
cd ~/Library-
```

URL вводится **без** `<` и `>`.

Если `~/Library-` уже существует:

```bash
cd ~/Library-
git pull --ff-only
```

### 3. Запустить установщик

```bash
bash ./install_termux.sh
```

Установщик сам:

```text
установит зависимости
        ↓
проверит / установит llama-cli
        ↓
при необходимости соберёт llama.cpp
        ↓
создаст ~/models
        ↓
скачает Qwen2.5-Coder-3B-Instruct Q4_K_M
        ↓
настроит MODEL_PATH
        ↓
запустит тест Qwen
        ↓
проверит Python-агентов
```

### 4. Не вводите название модели вручную

Неправильно:

```bash
Qwen2.5-Coder-3B-Instruct Q4_K_M
```

Это **название модели**, а не команда.

После работы установщика должен существовать файл:

```text
/data/data/com.termux/files/home/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Проверка:

```bash
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

### 5. Проверить llama.cpp и Qwen

```bash
command -v llama-cli
llama-cli --version
```

Затем:

```bash
llama-cli \
  -m ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf \
  -c 2048 \
  -n 32 \
  -p "Ответь одним словом: готов"
```

Ожидаемый результат — ответ модели, например `готов`.

### 6. Подготовить игру

По умолчанию агент работает в:

```text
~/Game
```

Проверка:

```bash
ls -la ~/Game
```

Если игра находится в другом каталоге, измените `PROJECT_DIR` в:

```text
~/Library-/agent_system/config.py
```

Используйте абсолютный путь.

### 7. Проверить Python-агентов

```bash
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
```

Если команда завершилась без вывода — синтаксис корректен.

### 8. Запустить агента

```bash
cd ~/Library-/agent_system
python run_agent.py "Добавь главное меню в игру"
```

Цикл:

```text
Planner → Coder → Test → Fixer → Test
```

## Повторная установка

Если установка прервалась:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Не удаляйте `~/Library-`.

Установщик не выполняет `rm`, `git clean` или автоматическое удаление существующих файлов.

## Если появляется `Local model not found`

Проверьте:

```bash
ls -lh ~/models/
```

Если `.gguf` нет:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Если файл есть, но ошибка сохраняется:

```bash
cd ~/Library-/agent_system
python -c 'from config import MODEL_PATH; print(MODEL_PATH); print(MODEL_PATH.exists())'
```

Вторая строка должна быть:

```text
True
```

## Если появляется `Qwen2.5-Coder-3B-Instruct: command not found`

Вы ввели название модели как команду. Ничего удалять не нужно. Запустите установщик:

```bash
cd ~/Library-
bash ./install_termux.sh
```

## Если появляется `llama-cli: command not found`

```bash
cd ~/Library-
bash ./install_termux.sh
```

## Если не хватает RAM

Начните с меньшей GGUF-квантизации/модели и уменьшите `CONTEXT_SIZE` в `agent_system/config.py`, например до `2048`.

## Архитектура

```text
Android
  ↓
Termux
  ↓
Python agent_system
  ↓
llama-cli
  ↓
Qwen2.5-Coder GGUF
  ↓
локальные файлы игры
```

API-ключ для inference не используется.

### Безопасность

Агент не получает произвольный shell-доступ. Команды сборки/тестов ограничены `ALLOWED_COMMANDS` в `agent_system/config.py`. Пути ограничены `PROJECT_DIR`. Установщик не удаляет существующие файлы репозитория.

Подробная диагностика: `SETUP_TERMUX.md`.
