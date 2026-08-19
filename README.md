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

### Шаг 5. Запустить автоматическую установку

Из каталога `~/Library-`:

```bash
bash ./install_termux.sh
```

Установщик автоматически:

```text
1. проверяет llama-cli
2. при необходимости устанавливает llama-cpp
3. если llama-cli всё ещё нет — собирает llama.cpp
4. создаёт ~/models
5. проверяет существующую модель
6. скачивает Qwen2.5-Coder-3B-Instruct Q4_K_M при необходимости
7. проверяет SHA256 модели
8. сохраняет модель в ~/models
9. прописывает MODEL_PATH
10. запускает тест Qwen
11. проверяет Python-код агентов
```

### Шаг 6. Где именно будет модель

Модель должна находиться **именно здесь**:

```text
/data/data/com.termux/files/home/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

То же самое через `~`:

```text
~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Проверка:

```bash
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Для официального файла Qwen2.5-Coder-3B-Instruct Q4_K_M контрольная SHA256:

```text
724fb256bec1ff062b2f65e4569e871ad2e95ab2a3989723d1769c54294730b7
```

Файл около **1.8 GB**, как на скриншоте, не считается корректным автоматически: установщик сверяет SHA256 и при несовпадении скачивает файл заново.

### Шаг 7. Не вводите название модели как команду

Неправильно:

```bash
Qwen2.5-Coder-3B-Instruct Q4_K_M
```

Это **название модели**, а не команда Termux.

Правильно:

```bash
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

### Шаг 8. Проверить llama-cli и Qwen

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

Нормальный результат — ответ модели без сообщения `data is not within the file bounds`.

### Шаг 9. Проверить путь, который использует агент

```bash
cd ~/Library-/agent_system
python -c 'from config import MODEL_PATH; print(MODEL_PATH); print(MODEL_PATH.exists())'
```

Ожидается:

```text
/data/data/com.termux/files/home/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
True
```

### Шаг 10. Проверить Python-агентов

```bash
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
```

Если команда ничего не выводит — проверка пройдена.

### Шаг 11. Подготовить игру

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

### Шаг 12. Проверить игру без AI

До запуска агента желательно проверить сам проект:

```bash
cd ~/Game
make
make test
```

### Шаг 13. Запустить систему агентов

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
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
llama-cli --version
llama-cli -m ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf -c 2048 -n 32 -p "Ответь: готов"
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
python run_agent.py "Проверь проект игры"
```

## Если появляется `data is not within the file bounds`

Это означает, что GGUF повреждён или неполон.

Проверьте:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Текущий установщик сравнивает SHA256 с известной контрольной суммой и не считает файл корректным только по размеру или наличию `GGUF` в заголовке.

### Если в каталоге уже лежит старый неполный файл

Установщик не перезаписывает его вслепую. Он сохраняет повреждённый файл с суффиксом:

```text
.broken.ГГГГММДД-ЧЧММСС
```

и скачивает новый.

## Если видите `Qwen2.5-Coder-3B-Instruct: command not found`

Вы ввели **название модели вместо команды**.

Ничего удалять не нужно:

```bash
cd ~/Library-
bash ./install_termux.sh
```

## Если видите `Local model not found`

```bash
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Если файла нет:

```bash
cd ~/Library-
bash ./install_termux.sh
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
