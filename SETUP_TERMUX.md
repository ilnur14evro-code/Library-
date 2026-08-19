# Termux + локальный Qwen Agent System

Эта инструкция устанавливает проект `Library-` на Android через Termux и подготавливает локальный `llama.cpp` для Qwen2.5-Coder без API.

## 1. Установить Termux

Используйте актуальный Termux из F-Droid или официального репозитория Termux.

После первого запуска:

```bash
pkg update -y
pkg upgrade -y
```

## 2. Самый простой способ установить Library- и llama.cpp

Не используйте угловые скобки вокруг URL. Правильная команда:

```bash
git clone https://github.com/ilnur14evro-code/Library-.git
```

Или полностью автоматический вариант из одной команды:

```bash
curl -fsSL https://raw.githubusercontent.com/ilnur14evro-code/Library-/main/install_termux.sh -o "$PREFIX/tmp/install_library.sh"
bash "$PREFIX/tmp/install_library.sh"
```

Установщик:

- обновляет Termux;
- устанавливает `git`, `python`, `clang`, `cmake`, `make`, `curl`;
- получает или обновляет `~/Library-`;
- проверяет `llama-cli`;
- если `llama-cli` отсутствует, собирает `llama.cpp` из исходников прямо в Termux;
- устанавливает `llama-cli` в `$PREFIX/bin`.

Существующие файлы `~/Library-` не удаляются.

## 3. Проверка установки

```bash
cd ~/Library-
python --version
llama-cli --version
```

Если обе команды отрабатывают без ошибки, базовая установка готова.

## 4. Подготовить локальную модель

Создать каталог:

```bash
mkdir -p ~/models
```

Поместить в него локальный GGUF Qwen2.5-Coder, например:

```text
~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Для телефона с 8 ГБ RAM начать с 1.5B/3B Q4. Для 12–16 ГБ можно тестировать 7B Q4.

В `agent_system/config.py` укажите точное имя файла модели.

## 5. Настроить проект игры

По умолчанию агент работает с:

```text
~/Game
```

Если игра находится в другом месте, измените `PROJECT_DIR` в:

```text
~/Library-/agent_system/config.py
```

## 6. Проверить сам llama.cpp до запуска агентов

```bash
llama-cli \
  -m ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf \
  -c 4096 \
  -n 64 \
  -p "Напиши одно предложение: Termux работает."
```

Если модель отвечает, локальный LLM-слой исправен.

## 7. Запустить агентную систему

```bash
cd ~/Library-/agent_system
python run_agent.py "Добавь главное меню с кнопками Start, Settings и Exit"
```

Цикл:

```text
Planner → Coder → make test → Fixer → make test
```

## 8. Безопасность

Агент не получает произвольный shell-доступ.

Разрешены только команды из `ALLOWED_COMMANDS` в `agent_system/config.py`.

Изменения модели ограничены `PROJECT_DIR`.

Абсолютные пути и путь через `..` отклоняются.

Команды тестирования записываются в:

```text
<PROJECT_DIR>/.agent_commands.log
```

## 9. Обновление проекта без удаления файлов

```bash
cd ~/Library-
git pull --ff-only
```

Не используйте:

```bash
rm -rf ~/Library-
git clean -fd
```

## 10. Если сборка llama.cpp завершается ошибкой

Сначала обновите пакеты:

```bash
pkg update -y
pkg upgrade -y
```

Удалять `~/Library-` не требуется.

Для повторной сборки можно использовать существующий каталог:

```bash
cd ~/llama.cpp
cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DGGML_NATIVE=OFF \
  -DGGML_OPENMP=OFF \
  -DLLAMA_CURL=OFF \
  -DLLAMA_BUILD_TESTS=OFF \
  -DLLAMA_BUILD_EXAMPLES=ON
cmake --build build --config Release --target llama-cli -j 2
install -m 755 build/bin/llama-cli "$PREFIX/bin/llama-cli"
```

Отключение native-оптимизаций и сборка только `llama-cli` используются как более консервативный вариант для Android/Termux. В сообществе llama.cpp также описаны случаи проблем Android-сборки и рабочие варианты с отключением `GGML_NATIVE`/лишних targets. citeturn798422search0turn798422search8

## 11. Запуск существующей игры

Эта часть проекта не изменяет игровой репозиторий автоматически.

Если используется отдельный проект `Game`, следуйте его собственному `Makefile` и тестам.

```bash
cd ~/Game
make
make test
```

## 12. Полностью локальная работа

После того как модель `.gguf` уже находится на телефоне, агентная система может работать без API и без облачного inference:

```text
Android
  ↓
Termux
  ↓
Python orchestrator
  ↓
llama-cli
  ↓
Qwen2.5-Coder GGUF
  ↓
локальные файлы игры
```
