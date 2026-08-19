# Полная установка Library- + Qwen 2.5 Agent System в Termux

Эта инструкция рассчитана на Android + Termux. API-ключ не нужен. После первоначальной загрузки модели inference выполняется локально через `llama.cpp`.

## 0. Что должно получиться

```text
Android
└── Termux
    ├── ~/Library-
    │   └── agent_system/
    ├── ~/models/
    │   └── Qwen2.5-Coder*.gguf
    └── ~/llama.cpp/
        └── build/bin/llama-cli
```

Агентный цикл:

```text
Задача → Planner → Coder → Test → Fixer → Test
```

Агент не получает произвольный shell-доступ и не должен удалять существующие файлы проекта.

## 1. Установить Termux

Установите актуальный Termux из F-Droid или официального репозитория Termux. Не используйте старую версию из Google Play.

После первого запуска:

```bash
pkg update -y
pkg upgrade -y
```

Если `pkg update` пишет об ошибке репозитория или зеркала:

```bash
termux-change-repo
```

Выберите основной репозиторий Termux и снова выполните:

```bash
pkg update -y
```

## 2. Установить базовые пакеты

```bash
pkg install -y git curl python clang cmake make
```

Проверка:

```bash
git --version
python --version
clang --version
cmake --version
```

## 3. Скачать Library-

Важно: URL не заключать в `< >`.

```bash
cd ~
git clone https://github.com/ilnur14evro-code/Library-.git
cd ~/Library-
```

Если `~/Library-` уже существует:

```bash
cd ~/Library-
git pull --ff-only
```

Не выполняйте для этого проекта:

```bash
rm -rf ~/Library-
git clean -fd
```

## 4. Установить llama.cpp

Сначала проверьте, есть ли готовый пакет:

```bash
pkg search llama-cpp
```

Если пакет есть:

```bash
pkg install -y llama-cpp
```

Проверка:

```bash
command -v llama-cli
llama-cli --version
```

Если `llama-cli` после установки не найден, соберите `llama.cpp` из исходников:

```bash
cd ~
if [ -d ~/llama.cpp/.git ]; then
    git -C ~/llama.cpp pull --ff-only
else
    git clone --depth=1 https://github.com/ggml-org/llama.cpp.git ~/llama.cpp
fi

cmake -S ~/llama.cpp -B ~/llama.cpp/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DGGML_NATIVE=OFF \
  -DGGML_OPENMP=OFF \
  -DLLAMA_CURL=OFF \
  -DLLAMA_BUILD_TESTS=OFF \
  -DLLAMA_BUILD_EXAMPLES=ON

cmake --build ~/llama.cpp/build --config Release --target llama-cli -j 2

install -m 755 ~/llama.cpp/build/bin/llama-cli "$PREFIX/bin/llama-cli"
```

Проверка:

```bash
llama-cli --version
```

Если сборка закончилась ошибкой, сохраните последние 30–50 строк вывода. `~/Library-` при этом удалять не нужно.

## 5. Подготовить каталог модели

```bash
mkdir -p ~/models
```

Нужен локальный файл модели формата GGUF. Для первого запуска на телефоне рекомендуется Qwen2.5-Coder 1.5B или 3B в Q4-квантизации. На телефонах с большим объёмом RAM можно тестировать 7B Q4.

Проверьте файлы:

```bash
ls -lh ~/models/*.gguf
```

По умолчанию `agent_system/config.py` ожидает:

```text
~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Если файл называется иначе, сначала узнайте точное имя:

```bash
ls -1 ~/models/*.gguf
```

затем измените `MODEL_PATH` в:

```text
~/Library-/agent_system/config.py
```

Например:

```python
MODEL_PATH = Path.home() / "models" / "ваше-имя-модели.gguf"
```

## 6. Проверить Qwen без агентов

До запуска Python-агентов обязательно проверьте сам LLM:

```bash
llama-cli \
  -m ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf \
  -c 4096 \
  -n 64 \
  -p "Ответь одним словом: готов"
```

Если Qwen отвечает — локальный inference работает.

Если получаете `model not found`, проблема в пути или имени `.gguf`.

Если получаете `llama-cli: command not found`, проблема в установке `llama.cpp`.

## 7. Проверить Python-агентов

```bash
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
```

Если команда ничего не вывела, синтаксис Python-файлов корректен.

## 8. Настроить проект игры

По умолчанию агент работает внутри:

```text
~/Game
```

Проверьте:

```bash
ls -la ~/Game
```

Если игра находится в другом каталоге, измените `PROJECT_DIR` в:

```text
~/Library-/agent_system/config.py
```

Используйте абсолютный путь.

## 9. Проверить существующую игру до агента

Для проекта из этого workflow:

```bash
cd ~/Game
make
make test
```

Сначала добейтесь, чтобы проект собирался и тесты проходили без AI. Тогда ошибки агента будет проще отличать от исходных проблем игры.

## 10. Запустить агента

```bash
cd ~/Library-/agent_system
python run_agent.py "Добавь главное меню с кнопками Start, Settings и Exit"
```

Система выполняет:

```text
Planner
  ↓
Coder
  ↓
изменение файлов внутри PROJECT_DIR
  ↓
make test
  ↓
Fixer при ошибке
  ↓
make test
```

Максимальное количество циклов исправления задаётся в `config.py` через `MAX_FIX_ATTEMPTS`.

## 11. Что разрешено агенту

Команды тестирования ограничены `ALLOWED_COMMANDS` в `agent_system/config.py`.

Файловые изменения ограничены `PROJECT_DIR`.

Абсолютные пути и `..` отклоняются.

Лог команд:

```text
<PROJECT_DIR>/.agent_commands.log
```

Существующие файлы репозитория `Library-` этим установщиком не удаляются.

## 12. Полностью локальный режим

После того как `.gguf` уже находится на телефоне:

```text
Termux
  ↓
Python
  ↓
llama-cli
  ↓
Qwen2.5-Coder GGUF
  ↓
локальный проект игры
```

Для генерации текста API не используется.

Интернет при этом нужен только для загрузки обновлений, исходников и самой модели.

## 13. Обновление Library- без удаления файлов

```bash
cd ~/Library-
git pull --ff-only
```

После обновления снова проверить:

```bash
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
```

## 14. Полностью автоматическая установка

Можно использовать установщик из репозитория:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Он устанавливает базовые зависимости, получает `Library-`, проверяет `llama-cli` и при необходимости собирает `llama.cpp`.

После завершения выполните шаги 5–10 этой инструкции: добавить GGUF-модель, проверить её через `llama-cli`, указать `MODEL_PATH`, проверить `~/Game` и запустить агента.

## 15. Типичные ошибки

### `git: command not found`

```bash
pkg install -y git
```

### `curl: command not found`

```bash
pkg install -y curl
```

### `cmake: command not found`

```bash
pkg install -y cmake
```

### `llama-cli: command not found`

Проверьте:

```bash
command -v llama-cli
ls -l "$PREFIX/bin/llama-cli"
```

Если файла нет — повторите сборку из шага 4.

### `model not found`

```bash
ls -lh ~/models/*.gguf
```

Сравните имя файла с `MODEL_PATH`.

### Ошибка `Repository not found`

Проверьте URL точно:

```bash
git clone https://github.com/ilnur14evro-code/Library-.git
```

Не добавляйте `<` или `>` вокруг URL.

### `pkg` не может обновить репозитории

```bash
termux-change-repo
pkg update -y
```

### Недостаточно памяти при запуске Qwen

Используйте меньшую модель/квантизацию, уменьшите `CONTEXT_SIZE` в `agent_system/config.py` и закройте ненужные приложения Android.

## 16. Итоговая проверка

В конце должны работать все четыре команды:

```bash
cd ~/Library-
python --version
llama-cli --version
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
```

Затем:

```bash
cd ~/Library-/agent_system
python run_agent.py "Добавь небольшое изменение в игру и запусти тесты"
```

Если агент сообщает ошибку, сначала сохраните полный вывод Termux; удалять `~/Library-` для повторной установки не требуется.
