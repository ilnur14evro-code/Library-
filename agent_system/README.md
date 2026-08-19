# Local Qwen 2.5 Agent System for Termux

Локальная система агентов для Android + Termux. API-ключ не используется. После первоначальной установки пакетов и загрузки GGUF-модели система может работать без облачного API.

## Быстрая установка

### 1. Обновить Termux

Используйте актуальный Termux из F-Droid или GitHub Releases. В Termux выполните:

```bash
pkg update -y
pkg upgrade -y
```

Если `pkg` сообщает, что зеркало не выбрано или репозиторий недоступен:

```bash
termux-change-repo
```

Выберите основной репозиторий Termux и повторите `pkg update -y`.

### 2. Рекомендуемый способ: автоматический установщик из Library-

Сначала скачайте только установщик:

```bash
curl -fsSL https://raw.githubusercontent.com/ilnur14evro-code/Library-/main/install_termux.sh -o "$PREFIX/tmp/install_library.sh"
bash "$PREFIX/tmp/install_library.sh"
```

Он устанавливает зависимости, получает `Library-`, проверяет `llama-cli` и при отсутствии `llama-cli` собирает `llama.cpp` из исходников внутри Termux.

Существующие файлы `~/Library-` не удаляются.

### 3. Ручной способ получить репозиторий

Правильно:

```bash
cd ~
git clone https://github.com/ilnur14evro-code/Library-.git
cd ~/Library-
```

Не добавляйте `<` и `>` вокруг URL.

Если репозиторий уже скачан:

```bash
cd ~/Library-
git pull --ff-only
```

### 4. Проверить llama.cpp

Если `llama-cli` уже есть в Termux:

```bash
command -v llama-cli
llama-cli --version
```

Если его нет, автоматический установщик соберёт его сам. Для Android/Termux сборка выполняется с консервативными параметрами и только для `llama-cli`.

### 5. Подготовить локальную модель

```bash
mkdir -p ~/models
```

Положите совместимую Qwen2.5-Coder GGUF-модель в `~/models/`.

Для телефона с 8 ГБ RAM начинайте с:

```text
Qwen2.5-Coder-1.5B-Instruct Q4_K_M
```

или:

```text
Qwen2.5-Coder-3B-Instruct Q4_K_M
```

Для 12–16 ГБ RAM можно тестировать 7B Q4.

Проверьте файл:

```bash
ls -lh ~/models/*.gguf
```

По умолчанию система ожидает:

```text
~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Если имя другое, измените `MODEL_PATH` в `agent_system/config.py`.

### 6. Проверить модель до запуска агентов

```bash
cd ~/Library-/agent_system
python -c "from llm import ask; print(ask('Ответь одним словом: готов'))"
```

Если эта команда возвращает ответ Qwen, локальный inference работает.

### 7. Указать игру

По умолчанию:

```text
~/Game
```

В `agent_system/config.py` можно указать другой абсолютный путь в `PROJECT_DIR`.

### 8. Запустить агента

```bash
cd ~/Library-/agent_system
python run_agent.py "Добавь экран меню с кнопками Start, Settings и Exit"
```

Цикл:

```text
Planner → Coder → Test → Fixer → Test
```

## Что система может менять

Агент работает только внутри `PROJECT_DIR`.

Он не получает произвольный shell-доступ. Команды тестирования должны присутствовать в allow-list в `config.py`.

Командный журнал:

```text
<PROJECT_DIR>/.agent_commands.log
```

## Защита существующих файлов

Система не содержит команд удаления файлов. Не используйте `rm`, `git clean` или другие команды удаления через агентный контур.

Текущая версия перед применением ответа модели проверяет путь, но полное содержимое изменяемого файла может быть заменено. Перед реальной разработкой рекомендуется добавить резервные копии/патч-режим и проверку diff.

## Ограничения

- API-ключ не нужен.
- Интернет нужен только для первоначальной установки Termux-пакетов, получения репозитория и загрузки модели.
- После установки inference выполняется локально через `llama-cli`.
- Автоматические `git commit`, `git push`, установка Python-пакетов моделью и произвольные shell-команды намеренно не включены.
