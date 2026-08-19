# Library- + Qwen2.5-Coder — полная установка в Termux

Эта инструкция рассчитана на **чистый Android + Termux** и описывает не только успешный сценарий, но и основные варианты отказа. Выполняйте основной сценарий сверху вниз. Если на каком-либо шаге возникает ошибка, переходите к соответствующей ветке диагностики ниже.

API-ключ не нужен. После загрузки GGUF-модели inference работает локально через `llama-cli`.

## 0. Что должно получиться

```text
/data/data/com.termux/files/home/
├── Library-/                              # репозиторий
│   └── agent_system/
├── llama.cpp/                             # только если llama-cli собирался из исходников
└── models/
    └── qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Поток работы:

```text
Задача → Planner → Coder → Test → Fixer → Test
```

---

# ЧАСТЬ A. УСТАНОВКА С НУЛЯ

## 1. Установить Termux

Используйте актуальный Termux из F-Droid или официального GitHub-репозитория Termux.

После первого запуска:

```bash
pkg update -y
pkg upgrade -y
```

Если появляется ошибка зеркала/репозитория:

```bash
termux-change-repo
pkg update -y
```

Затем повторите установку.

---

## 2. Установить Git

```bash
pkg install -y git
```

Проверка:

```bash
git --version
```

---

## 3. Скачать `Library-`

```bash
cd ~
git clone https://github.com/ilnur14evro-code/Library-.git
cd ~/Library-
```

**Важно:** URL не заключать в `< >`.

Если `~/Library-` уже существует:

```bash
cd ~/Library-
git pull --ff-only
```

Не удаляйте репозиторий для повторной установки.

---

## 4. Установить зависимости

```bash
pkg install -y python clang cmake make curl coreutils
```

Проверка:

```bash
python --version
clang --version
cmake --version
curl --version
sha256sum --version
```

Если `sha256sum` не найден:

```bash
pkg install -y coreutils
```

---

## 5. Создать каталог модели

Сделать это **до проверки/скачивания модели**:

```bash
mkdir -p ~/models
```

Проверить:

```bash
ls -ld ~/models
```

Каталог должен быть:

```text
/data/data/com.termux/files/home/models
```

### Не делайте этого

```bash
cd ~/models
Qwen2.5-Coder-3B-Instruct Q4_K_M
```

`Qwen2.5-Coder-3B-Instruct Q4_K_M` — название модели, а не команда Termux.

---

## 6. Запустить основной установщик

```bash
cd ~/Library-
bash ./install_termux.sh
```

Установщик выполняет всю последовательность:

```text
Termux update
  ↓
зависимости
  ↓
Library-
  ↓
llama-cli
  ├── пакет llama-cpp доступен → установить
  └── пакет недоступен → собрать llama.cpp
  ↓
~/models
  ↓
проверка существующей Qwen
  ↓
скачивание через временный .part
  ↓
SHA256
  ├── совпала → модель принимается
  └── не совпала → повреждённый файл сохраняется, загрузка повторяется
  ↓
настройка MODEL_PATH
  ↓
прямой тест Qwen
  ↓
проверка Python-агентов
```

Установщик не выполняет `rm -rf ~/Library-` и не удаляет существующие файлы репозитория. Повреждённая модель сохраняется с суффиксом `.broken.<дата>`. fileciteturn56file0

---

# ЧАСТЬ B. ТОЧНЫЙ ПУТЬ МОДЕЛИ

После успешной загрузки Qwen должна находиться **ровно здесь**:

```text
/data/data/com.termux/files/home/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Сокращённая запись:

```text
~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Проверка:

```bash
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Для выбранного файла Qwen2.5-Coder-3B-Instruct Q4_K_M используется контрольная SHA256:

```text
724fb256bec1ff062b2f65e4569e871ad2e95ab2a3989723d1769c54294730b7
```

Файл размером примерно 1.8 GB сам по себе **не означает**, что он корректен. Проверяется SHA256. Именно это отличает полный GGUF от обрезанного файла. fileciteturn53file0

Ручная проверка:

```bash
sha256sum ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Ожидается строка, начинающаяся с:

```text
724fb256bec1ff062b2f65e4569e871ad2e95ab2a3989723d1769c54294730b7
```

---

# ЧАСТЬ C. ПРОВЕРКА `llama-cli`

## 7. Проверить наличие `llama-cli`

```bash
command -v llama-cli
llama-cli --version
```

### Вариант C1 — `llama-cli` уже есть

Ничего устанавливать заново не нужно. Переходите к шагу 8.

### Вариант C2 — `llama-cli: command not found`

```bash
cd ~/Library-
bash ./install_termux.sh
```

Сначала установщик пытается поставить `llama-cpp`. Если пакет недоступен, он собирает `llama.cpp` через CMake. fileciteturn56file0

### Вариант C3 — сборка `llama.cpp` завершилась ошибкой

Сначала проверьте:

```bash
clang --version
cmake --version
make --version
free -h
```

Если телефон не хватает памяти во время сборки, закройте другие приложения Android и повторите:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Не удаляйте `~/Library-`.

Если `~/llama.cpp` существует, но это не Git-репозиторий, установщик специально остановится и не удалит его автоматически. Содержимое нужно проверить вручную. fileciteturn56file0

---

# ЧАСТЬ D. ПРОВЕРКА МОДЕЛИ

## 8. Проверить модель напрямую

Не запускайте Python-агента, пока этот тест не проходит.

```bash
llama-cli \
  -m ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf \
  -c 2048 \
  -n 32 \
  -p "Ответь одним словом: готов"
```

### Нормальный результат

Qwen отвечает текстом.

### Вариант D1 — `model not found`

```bash
ls -lh ~/models/
```

Если `.gguf` отсутствует:

```bash
cd ~/Library-
bash ./install_termux.sh
```

### Вариант D2 — `data is not within the file bounds`

Это означает повреждённый или неполный GGUF.

Выполните:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Установщик сравнивает SHA256. Если существующий файл неправильный, он сохраняется как `.broken.<дата>`, после чего скачивается новый. fileciteturn56file0

Дополнительная ручная проверка:

```bash
sha256sum ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Если SHA256 не совпадает с:

```text
724fb256bec1ff062b2f65e4569e871ad2e95ab2a3989723d1769c54294730b7
```

файл нельзя использовать.

### Вариант D3 — загрузка оборвалась

Не удаляйте `Library-`.

Запустите:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Незавершённая загрузка хранится во временном `.part`, а затем проверяется SHA256. fileciteturn56file0

### Вариант D4 — файл скачался, но SHA256 не совпадает

Это проблема целостности загрузки, а не Python-агента.

Повторите:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Установщик не принимает файл, пока контрольная сумма не совпадёт.

---

# ЧАСТЬ E. ОШИБКИ ЗАПУСКА QWEN ПОСЛЕ УСПЕШНОЙ SHA256

Если SHA256 правильная, но `llama-cli` всё равно не загружает модель, это уже **не проблема скачивания**.

## 9. Проверить RAM

```bash
free -h
```

Закройте другие приложения Android.

Начните с:

```text
Qwen2.5-Coder-3B-Instruct Q4_K_M
context = 2048
```

Если памяти всё равно не хватает, уменьшите `CONTEXT_SIZE` в:

```text
~/Library-/agent_system/config.py
```

например:

```python
CONTEXT_SIZE = 2048
```

Если модель всё равно не загружается, используйте меньшую Qwen2.5-Coder GGUF-квантизацию/размер.

Важно: сообщение:

```text
data is not within the file bounds
```

при **несовпадающей SHA256** означает повреждённый файл. При **совпадающей SHA256** нужно смотреть остальной вывод `llama-cli`: причина может быть в runtime, совместимости или памяти.

---

# ЧАСТЬ F. ПРОВЕРКА PYTHON-СИСТЕМЫ

## 10. Проверить `MODEL_PATH`

```bash
cd ~/Library-/agent_system
python -c 'from config import MODEL_PATH; print(MODEL_PATH); print(MODEL_PATH.exists())'
```

Ожидается:

```text
/data/data/com.termux/files/home/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
True
```

Если `False`:

```bash
cd ~/Library-
bash ./install_termux.sh
```

---

## 11. Проверить Python-файлы

```bash
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
```

Если команда ничего не выводит, синтаксис корректен.

---

# ЧАСТЬ G. ПОДГОТОВКА ИГРЫ

## 12. Каталог игры

По умолчанию:

```text
~/Game
```

Проверка:

```bash
ls -la ~/Game
```

Если игра находится в другом месте, измените:

```python
PROJECT_DIR = Path.home() / "Game"
```

в:

```text
~/Library-/agent_system/config.py
```

Используйте абсолютный путь.

---

## 13. Сначала проверить игру без AI

```bash
cd ~/Game
make
make test
```

Если игра не использует `make`, сначала соберите и проверьте её вручную.

Только рабочий проект следует отдавать агенту.

---

# ЧАСТЬ H. ЗАПУСК АГЕНТОВ

## 14. Первый безопасный запуск

```bash
cd ~/Library-/agent_system
python run_agent.py "Проверь проект игры и предложи одно небольшое изменение"
```

Основной цикл:

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

Команды сборки/тестов ограничены `ALLOWED_COMMANDS`. Файловые пути ограничены `PROJECT_DIR`.

---

# ЧАСТЬ I. ПОЛНЫЙ СЦЕНАРИЙ ДЛЯ ЧИСТОГО TERMUX

Если Termux только что установлен, выполните **именно эти команды сверху вниз**:

```bash
pkg update -y
pkg upgrade -y
pkg install -y git
cd ~
git clone https://github.com/ilnur14evro-code/Library-.git
cd ~/Library-
pkg install -y python clang cmake make curl coreutils
mkdir -p ~/models
bash ./install_termux.sh
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
sha256sum ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
llama-cli --version
llama-cli -m ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf -c 2048 -n 32 -p "Ответь: готов"
cd ~/Library-/agent_system
python -c 'from config import MODEL_PATH; print(MODEL_PATH); print(MODEL_PATH.exists())'
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
python run_agent.py "Проверь проект игры"
```

---

# ЧАСТЬ J. ЕСЛИ УЖЕ ЧТО-ТО УСТАНОВЛЕНО

## Сценарий J1 — `Library-` уже есть

```bash
cd ~/Library-
git pull --ff-only
bash ./install_termux.sh
```

## Сценарий J2 — `llama-cli` уже есть

Просто:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Установщик обнаружит существующий `llama-cli` и не будет собирать его заново. fileciteturn56file0

## Сценарий J3 — модель уже корректна

Если SHA256 совпадает, загрузка модели не выполняется заново.

## Сценарий J4 — модель есть, но повреждена

Установщик сохраняет её как:

```text
qwen2.5-coder-3b-instruct-q4_k_m.gguf.broken.ГГГГММДД-ЧЧММСС
```

и загружает новую.

## Сценарий J5 — есть незавершённый `.part`

Установщик продолжает загрузку `.part`, после чего проверяет SHA256.

## Сценарий J6 — `~/Library-` существует, но это не Git

Установщик остановится и **не удалит каталог автоматически**. Проверьте его вручную.

## Сценарий J7 — `~/llama.cpp` существует, но это не Git

Установщик также не удаляет его автоматически. Проверьте каталог вручную.

---

# ЧАСТЬ K. ЧТО НЕ НУЖНО ДЕЛАТЬ

Не нужно вводить:

```bash
Qwen2.5-Coder-3B-Instruct Q4_K_M
```

Не нужно удалять репозиторий для повторной установки:

```bash
rm -rf ~/Library-
```

Не нужно очищать рабочее дерево:

```bash
git clean -fd
```

Не нужно запускать агента до успешного прямого теста `llama-cli`.

---

# ЧАСТЬ L. РЕЗУЛЬТАТ

После успешной установки должны быть доступны:

```bash
command -v llama-cli
```

```bash
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

```bash
sha256sum ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

```bash
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
```

И только после этого:

```bash
python run_agent.py "Проверь проект игры"
```

Все существующие файлы `Library-` сохраняются. Установщик не удаляет их автоматически.
