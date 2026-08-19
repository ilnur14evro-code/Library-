# Полная установка Library- + Qwen 2.5 Agent System в Termux

Эта инструкция предназначена для **Android + Termux**, без API-ключей и без облачного inference. Интернет нужен только для первоначальной загрузки репозитория, `llama.cpp` и локальной GGUF-модели. После этого Qwen запускается прямо на телефоне через `llama-cli`.

## Важное перед началом

На фото видно типичную ошибку:

```text
~/models $ Qwen2.5-Coder-3B-Instruct Q4_K_M
Qwen2.5-Coder-3B-Instruct: command not found
```

Так делать **не надо**. `Qwen2.5-Coder-3B-Instruct Q4_K_M` — это название модели, а не команда Termux. Сначала модель нужно скачать как файл `.gguf`, затем запускать `llama-cli -m ПУТЬ_К_ФАЙЛУ`.

В этом репозитории `install_termux.sh` теперь делает это автоматически.

## 1. Установить Termux

Используйте актуальный Termux из F-Droid или официального GitHub-репозитория Termux. Старый пакет Termux из Google Play может иметь устаревшие репозитории.

Откройте Termux и выполните:

```bash
pkg update -y
pkg upgrade -y
```

Если обновление сообщает об ошибке зеркала:

```bash
termux-change-repo
```

Выберите основной репозиторий Termux и снова:

```bash
pkg update -y
```

## 2. Скачать и запустить установщик Library-

Используйте URL **без** `< >`.

```bash
cd ~
git clone https://github.com/ilnur14evro-code/Library-.git
cd ~/Library-
bash ./install_termux.sh
```

Если `~/Library-` уже существует:

```bash
cd ~/Library-
git pull --ff-only
bash ./install_termux.sh
```

Установщик выполняет всё основное:

```text
Termux packages
      ↓
Library-
      ↓
llama.cpp / llama-cli
      ↓
Qwen2.5-Coder-3B-Instruct Q4_K_M
      ↓
проверка Qwen
      ↓
проверка Python-агентов
```

Существующие файлы `Library-` этим установщиком не удаляются.

## 3. Что именно устанавливает install_termux.sh

Устанавливаются:

```bash
pkg install -y git python clang cmake make curl
```

Затем проверяется `llama-cli`.

Если готовый пакет `llama-cpp` доступен в репозитории Termux, он устанавливается. Если `llama-cli` после этого отсутствует, скрипт автоматически клонирует `llama.cpp` и собирает `llama-cli` через CMake.

## 4. Загрузка Qwen2.5-Coder

Установщик автоматически создаёт:

```text
~/models/
```

и скачивает:

```text
~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Размер этой Q4_K_M-модели в репозитории GGUF составляет около **2.1 GB**. citeturn156303search0

Источник модели:

```text
Qwen/Qwen2.5-Coder-3B-Instruct-GGUF
```

На странице модели прямо указан вариант `Q4_K_M` для llama.cpp. citeturn156303search0

Установщик использует загрузку с продолжением:

```bash
curl -L --fail --retry 3 --continue-at - ...
```

Поэтому при прерывании загрузки можно снова выполнить:

```bash
cd ~/Library-
bash ./install_termux.sh
```

и продолжить загрузку.

## 5. Не вводите название модели как команду

Неправильно:

```bash
cd ~/models
Qwen2.5-Coder-3B-Instruct Q4_K_M
```

Правильно проверить файл:

```bash
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Правильно проверить Qwen:

```bash
llama-cli \
  -m ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf \
  -c 2048 \
  -n 32 \
  -p "Ответь одним словом: готов"
```

Страница GGUF также показывает запуск Qwen через `llama-cli` и локальный `.gguf`-файл. citeturn156303search0

## 6. Где находится модель после установки

Проверьте:

```bash
ls -lh ~/models/
```

Должно быть:

```text
qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Путь в агентной системе:

```text
~/Library-/agent_system/config.py
```

Установщик автоматически выставляет:

```python
MODEL_PATH = Path.home() / "models" / "qwen2.5-coder-3b-instruct-q4_k_m.gguf"
```

## 7. Проверить llama.cpp

```bash
command -v llama-cli
llama-cli --version
```

Если путь не выводится:

```bash
ls -l "$PREFIX/bin/llama-cli"
```

Если файл отсутствует, повторно запустите:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Не удаляйте `~/Library-` для повторной установки.

## 8. Проверить Python-агентов

```bash
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
```

Если команда завершилась без вывода, синтаксис Python-файлов корректен.

## 9. Подготовить игру

По умолчанию агент работает внутри:

```text
~/Game
```

Проверить каталог:

```bash
ls -la ~/Game
```

Если игра находится в другом месте, измените `PROJECT_DIR` в:

```text
~/Library-/agent_system/config.py
```

## 10. Проверить игру до запуска AI

Перед первым запуском агента желательно убедиться, что игра сама собирается:

```bash
cd ~/Game
make
make test
```

Если в игре другой способ сборки, используйте его вручную. Агентный контур запускает только команды, перечисленные в `ALLOWED_COMMANDS` внутри `config.py`.

## 11. Запустить систему агентов

```bash
cd ~/Library-/agent_system
python run_agent.py "Добавь главное меню с кнопками Start, Settings и Exit"
```

Цикл:

```text
Planner
  ↓
Coder
  ↓
изменение файлов
  ↓
Tester
  ↓
ошибка?
  ↓
Fixer
  ↓
Tester
```

Количество попыток исправления задаётся `MAX_FIX_ATTEMPTS`.

## 12. Что разрешено агенту

Агент не получает произвольный shell-доступ.

В `config.py` разрешены только конкретные команды тестовой сборки.

Файловые изменения ограничены `PROJECT_DIR`.

Абсолютные пути и `..` отклоняются.

Лог команд сохраняется в:

```text
<PROJECT_DIR>/.agent_commands.log
```

## 13. Важное ограничение текущего агента

Агент не должен удалять существующие файлы. Однако текущая реализация может заменить полное содержимое файла при применении ответа модели. Поэтому для важных проектов перед массовой работой желательно иметь Git-историю или резервную копию каталога игры.

Это не влияет на сам `Library-`: установщик не выполняет `rm`, `git clean` и другие команды удаления.

## 14. Полностью локальный режим

После загрузки модели:

```text
Android
  ↓
Termux
  ↓
Python agent_system
  ↓
llama-cli
  ↓
локальный Qwen2.5-Coder GGUF
  ↓
локальные файлы игры
```

API-ключи для генерации не нужны.

## 15. Повторная установка и обновление

Обновить только репозиторий:

```bash
cd ~/Library-
git pull --ff-only
```

Повторно проверить среду:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Если модель уже скачана, установщик её повторно не загружает.

## 16. Частые ошибки

### `Qwen2.5-Coder-3B-Instruct: command not found`

Вы ввели название модели как команду. Ничего удалять не нужно. Выполните:

```bash
ls -lh ~/models/
```

Если модель отсутствует:

```bash
cd ~/Library-
bash ./install_termux.sh
```

### `llama-cli: command not found`

```bash
command -v llama-cli
```

Если ничего не выводится:

```bash
cd ~/Library-
bash ./install_termux.sh
```

### `model not found`

```bash
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Если файла нет:

```bash
cd ~/Library-
bash ./install_termux.sh
```

### `git: command not found`

```bash
pkg install -y git
```

### `cmake: command not found`

```bash
pkg install -y cmake
```

### `pkg update` не работает

```bash
termux-change-repo
pkg update -y
```

### Недостаточно памяти

Для телефона с ограниченной RAM используйте меньшую Qwen2.5-Coder GGUF-квантизацию. Контекст можно уменьшить в `agent_system/config.py`, например с `4096` до `2048`.

## 17. Финальная проверка

```bash
cd ~/Library-
python --version
llama-cli --version
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
```

Проверка локального Qwen:

```bash
llama-cli \
  -m ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf \
  -c 2048 \
  -n 32 \
  -p "Напиши: готов"
```

Проверка агента:

```bash
cd ~/Library-/agent_system
python run_agent.py "Проверь проект игры и предложи одно небольшое безопасное изменение"
```

Если какая-либо команда выдаёт ошибку, сохраните полный вывод Termux. Для повторной установки **не удаляйте `~/Library-`**.
