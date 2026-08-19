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

### 2. Установить зависимости

```bash
pkg install -y git python clang cmake make
```

`llama-cpp` является пакетом Termux. Сначала установите его напрямую:

```bash
pkg install -y llama-cpp
```

Проверка:

```bash
command -v llama-cli
llama-cli --version
```

Если `pkg install llama-cpp` сообщает, что пакет не найден, не переходите сразу к ручной сборке: сначала выполните `termux-change-repo`, затем:

```bash
pkg update -y
pkg install -y llama-cpp
```

Если пакет установлен, но `llama-cli` не запускается, проверьте доступные backend-пакеты:

```bash
pkg search llama-cpp
```

Для первого запуска используйте CPU backend. Дополнительные GPU/OpenCL/Vulkan backend-пакеты не обязательны.

### 3. Получить репозиторий

```bash
cd ~
git clone https://github.com/ilnur14evro-code/Library-.git
cd ~/Library-
```

Если репозиторий уже скачан:

```bash
cd ~/Library-
git pull
```

### 4. Подготовить локальную модель

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

### 5. Указать игру

По умолчанию:

```text
~/Game
```

В `agent_system/config.py` можно указать другой абсолютный путь в `PROJECT_DIR`.

### 6. Проверить модель до запуска агентов

```bash
cd ~/Library-/agent_system
python -c "from llm import ask; print(ask('Ответь одним словом: готов'))"
```

Если эта команда возвращает ответ Qwen, локальный inference работает.

### 7. Запустить агента

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

Система не должна удалять существующие исходники игры. Не используйте `rm`, `git clean` или другие команды удаления через агентный контур.

Текущая версия перед применением ответа модели проверяет путь, но полное содержимое изменяемого файла может быть заменено. Перед реальной разработкой рекомендуется добавить резервные копии/патч-режим и проверку diff.

## Ограничения

- API-ключ не нужен.
- Интернет нужен только для первоначальной установки Termux-пакетов, получения репозитория и загрузки модели.
- После установки inference выполняется локально через `llama-cli`.
- Автоматические `git commit`, `git push`, установка Python-пакетов моделью и произвольные shell-команды намеренно не включены.
