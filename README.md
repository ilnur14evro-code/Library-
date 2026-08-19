# Library-

Локальная система Qwen 2.5-Coder агентов для Android + Termux.

## Установка с нуля — строгая последовательность

**Не пропускайте шаги и не вводите название модели как команду.**

### Шаг 1. Установить Termux

Используйте актуальный Termux из F-Droid или официального GitHub-репозитория Termux.

Откройте Termux и выполните:

```bash
pkg update -y
pkg upgrade -y
```

Если появляется ошибка зеркала:

```bash
termux-change-repo
pkg update -y
```

### Шаг 2. Установить Git

```bash
pkg install -y git
```

Проверка:

```bash
git --version
```

### Шаг 3. Скачать Library-

```bash
cd ~
git clone https://github.com/ilnur14evro-code/Library-.git
cd ~/Library-
```

Важно: URL должен быть **без** `<` и `>`.

Если `~/Library-` уже существует, не удаляйте его:

```bash
cd ~/Library-
git pull --ff-only
```

### Шаг 4. Установить базовые зависимости

```bash
pkg install -y python clang cmake make curl
```

Проверка:

```bash
python --version
clang --version
cmake --version
curl --version
```

### Шаг 5. Установить llama.cpp

Из каталога `~/Library-` запускайте:

```bash
bash ./install_termux.sh
```

Установщик автоматически:

```text
1. проверяет llama-cli
2. при необходимости устанавливает llama-cpp
3. если llama-cli всё ещё нет — собирает llama.cpp
4. создаёт каталог ~/models
5. скачивает Qwen2.5-Coder-3B-Instruct Q4_K_M
6. сохраняет модель в ~/models
7. прописывает MODEL_PATH
8. проверяет запуск модели
9. проверяет Python-код агентов
```

### Шаг 6. Где именно будет модель

После установки модель должна находиться **именно здесь**:

```text
/data/data/com.termux/files/home/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

То же самое через `~`:

```text
~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Проверка:

```bash
mkdir -p ~/models
ls -lh ~/models/
```

Ожидаемый файл:

```text
qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

**После создания `~/models` не нужно писать туда `Qwen2.5-Coder-3B-Instruct Q4_K_M`.** Это название модели, не команда.

### Шаг 7. Если автоматическая загрузка модели не запускалась

Не удаляйте репозиторий. Выполните:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Установщик сам создаст `~/models` и скачает `.gguf`.

Если загрузка была прервана, снова выполните ту же команду. Загрузка продолжается.

### Шаг 8. Проверить llama-cli

```bash
command -v llama-cli
llama-cli --version
```

### Шаг 9. Проверить модель

После того как файл существует:

```bash
llama-cli \
  -m ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf \
  -c 2048 \
  -n 32 \
  -p "Ответь одним словом: готов"
```

Нормальный результат — ответ Qwen.

### Шаг 10. Проверить путь, который использует агент

```bash
cd ~/Library-/agent_system
python -c 'from config import MODEL_PATH; print(MODEL_PATH); print(MODEL_PATH.exists())'
```

Ожидается:

```text
/data/data/com.termux/files/home/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
True
```

### Шаг 11. Проверить Python-агентов

```bash
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
```

Если команда ничего не выводит — проверка пройдена.

### Шаг 12. Подготовить игру

По умолчанию агент работает в:

```text
~/Game
```

Проверка:

```bash
ls -la ~/Game
```

Если игра находится в другом месте, измените `PROJECT_DIR` в:

```text
~/Library-/agent_system/config.py
```

### Шаг 13. Проверить игру без AI

До запуска агента желательно проверить сам проект:

```bash
cd ~/Game
make
make test
```

### Шаг 14. Запустить систему агентов

```bash
cd ~/Library-/agent_system
python run_agent.py "Проверь проект игры и сделай небольшое изменение"
```

Цикл:

```text
Planner → Coder → Test → Fixer → Test
```

## Полный сценарий с нуля одной последовательностью

Ниже — команды **в точном порядке** для чистого Termux:

```bash
pkg update -y
pkg upgrade -y
pkg install -y git
cd ~
git clone https://github.com/ilnur14evro-code/Library-.git
cd ~/Library-
pkg install -y python clang cmake make curl
bash ./install_termux.sh
ls -lh ~/models/
llama-cli --version
llama-cli -m ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf -c 2048 -n 32 -p "Ответь: готов"
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
python run_agent.py "Проверь проект игры"
```

## Если видите `Qwen2.5-Coder-3B-Instruct: command not found`

Вы ввели **название модели вместо команды**.

Ничего удалять не нужно. Выполните:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Затем:

```bash
ls -lh ~/models/
```

## Если видите `Local model not found`

Проверьте:

```bash
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Если файла нет:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Если файл есть:

```bash
cd ~/Library-/agent_system
python -c 'from config import MODEL_PATH; print(MODEL_PATH); print(MODEL_PATH.exists())'
```

## Если видите `llama-cli: command not found`

```bash
cd ~/Library-
bash ./install_termux.sh
```

## Повторная установка

Для повторного запуска используйте только:

```bash
cd ~/Library-
bash ./install_termux.sh
```

**Не выполняйте:**

```bash
rm -rf ~/Library-
git clean -fd
```

Установщик не удаляет существующие файлы `Library-`.

## Без API

После загрузки модели inference выполняется локально:

```text
Android → Termux → llama-cli → Qwen2.5-Coder GGUF → локальный проект игры
```

API-ключ не используется.

## Безопасность

Агент не получает произвольный shell-доступ. Команды сборки/тестов ограничены `ALLOWED_COMMANDS` в `agent_system/config.py`, а файловые изменения ограничены `PROJECT_DIR`.

Подробная диагностика: `SETUP_TERMUX.md`.
