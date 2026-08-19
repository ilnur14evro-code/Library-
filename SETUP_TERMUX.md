# Library- + Qwen2.5-Coder — установка с нуля в Termux

Эта инструкция описывает **весь путь от чистого Termux до работающего локального агента**. Выполняйте шаги строго по порядку.

API-ключ для inference не нужен. После загрузки модели Qwen работает локально через `llama.cpp`.

---

## 0. Что получится в конце

```text
/data/data/com.termux/files/home/
├── Library-/                              # этот репозиторий
│   └── agent_system/
├── llama.cpp/                             # исходники llama.cpp, если понадобилась сборка
└── models/
    └── qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Агентный цикл:

```text
Задача → Planner → Coder → Test → Fixer → Test
```

---

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

---

## 2. Установить Git

```bash
pkg install -y git
```

Проверить:

```bash
git --version
```

---

## 3. Скачать Library-

```bash
cd ~
git clone https://github.com/ilnur14evro-code/Library-.git
cd ~/Library-
```

Важно: URL вводится **без** `<` и `>`.

Если `~/Library-` уже существует, **не удаляйте его**. Обновите:

```bash
cd ~/Library-
git pull --ff-only
```

---

## 4. Установить зависимости для llama.cpp и агентов

Из каталога `~/Library-`:

```bash
pkg install -y python clang cmake make curl
```

Проверить:

```bash
python --version
clang --version
cmake --version
curl --version
```

---

## 5. Создать каталог для модели — ДО скачивания модели

Это отдельный и обязательный шаг.

```bash
mkdir -p ~/models
```

Проверить:

```bash
ls -ld ~/models
```

Должно быть что-то вроде:

```text
drwx------ ... /data/data/com.termux/files/home/models
```

**После создания этой папки не вводите название модели как команду.**

Неправильно:

```bash
cd ~/models
Qwen2.5-Coder-3B-Instruct Q4_K_M
```

`Qwen2.5-Coder-3B-Instruct Q4_K_M` — это название модели, а не команда Termux.

---

## 6. Запустить установщик из репозитория

Вернитесь в репозиторий:

```bash
cd ~/Library-
```

Запустите:

```bash
bash ./install_termux.sh
```

### Что делает установщик

Он выполняет по порядку:

```text
1. обновляет Termux
2. устанавливает зависимости
3. проверяет Library-
4. проверяет llama-cli
5. устанавливает llama-cpp, если пакет доступен
6. иначе собирает llama.cpp
7. создаёт ~/models
8. скачивает Qwen2.5-Coder-3B-Instruct Q4_K_M
9. сохраняет файл в ~/models/
10. прописывает MODEL_PATH
11. запускает тест Qwen
12. проверяет Python-файлы агентов
```

Существующие файлы `Library-` установщик не удаляет.

---

## 7. Где именно будет сохранена модель

После завершения загрузки файл должен лежать **ровно здесь**:

```text
/data/data/com.termux/files/home/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Сокращённая запись:

```text
~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Проверка:

```bash
ls -lh ~/models/
```

Ожидаемый файл:

```text
qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

---

## 8. Если автоматическая загрузка модели остановилась

Не удаляйте репозиторий и не создавайте модель вручную.

Просто снова выполните:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Установщик использует продолжение загрузки. Если файл уже полностью скачан, он повторно не скачивается.

---

## 9. Проверить наличие модели вручную

```bash
test -s ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf && echo "MODEL OK" || echo "MODEL MISSING"
```

Ожидается:

```text
MODEL OK
```

И размер:

```bash
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

---

## 10. Проверить llama.cpp

```bash
command -v llama-cli
llama-cli --version
```

Если `llama-cli` не найден:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Не удаляйте `~/Library-`.

---

## 11. Проверить Qwen напрямую, без агентов

Это обязательная проверка перед Python-системой.

```bash
llama-cli \
  -m ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf \
  -c 2048 \
  -n 32 \
  -p "Ответь одним словом: готов"
```

Нормальный результат — ответ модели.

### Если `Local model not found`

Проверить:

```bash
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
```

Если файла нет:

```bash
cd ~/Library-
bash ./install_termux.sh
```

### Если `llama-cli: command not found`

```bash
cd ~/Library-
bash ./install_termux.sh
```

### Если появляется `Qwen2.5-Coder-3B-Instruct: command not found`

Вы ввели название модели как команду. Это не команда. Запустите установщик:

```bash
cd ~/Library-
bash ./install_termux.sh
```

---

## 12. Проверить путь модели внутри агента

```bash
cd ~/Library-/agent_system
python -c 'from config import MODEL_PATH; print(MODEL_PATH); print(MODEL_PATH.exists())'
```

Ожидается:

```text
/data/data/com.termux/files/home/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
True
```

---

## 13. Проверить Python-код агентов

```bash
cd ~/Library-/agent_system
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
```

Если команда ничего не выводит — проверка пройдена.

---

## 14. Подготовить проект игры

По умолчанию:

```text
~/Game
```

Проверить:

```bash
ls -la ~/Game
```

Если игра находится в другом каталоге, откройте:

```text
~/Library-/agent_system/config.py
```

и измените:

```python
PROJECT_DIR = Path.home() / "Game"
```

на абсолютный путь к существующему проекту.

---

## 15. Проверить игру до запуска AI

Сначала убедитесь, что сама игра работает:

```bash
cd ~/Game
make
make test
```

Это позволяет отличить исходные ошибки игры от ошибок агента.

---

## 16. Запустить систему агентов

```bash
cd ~/Library-/agent_system
python run_agent.py "Проверь проект игры и сделай небольшое безопасное изменение"
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

---

## 17. Полный сценарий для чистого Termux

Это готовая последовательность без пропусков:

```bash
pkg update -y
pkg upgrade -y
pkg install -y git
cd ~
git clone https://github.com/ilnur14evro-code/Library-.git
cd ~/Library-
pkg install -y python clang cmake make curl
mkdir -p ~/models
bash ./install_termux.sh
ls -lh ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf
llama-cli --version
llama-cli -m ~/models/qwen2.5-coder-3b-instruct-q4_k_m.gguf -c 2048 -n 32 -p "Ответь: готов"
cd ~/Library-/agent_system
python -c 'from config import MODEL_PATH; print(MODEL_PATH); print(MODEL_PATH.exists())'
python -m py_compile config.py llm.py tools.py agents.py run_agent.py
python run_agent.py "Проверь проект игры"
```

---

## 18. Повторная установка после ошибки

Не удаляйте репозиторий.

Всегда начинайте с:

```bash
cd ~/Library-
bash ./install_termux.sh
```

Не используйте:

```bash
rm -rf ~/Library-
git clean -fd
```

Установщик намеренно не выполняет операции удаления существующих файлов репозитория.

---

## 19. Недостаточно RAM

Если `llama-cli` завершается из-за памяти:

1. используйте меньшую GGUF-модель/квантизацию;
2. уменьшите `CONTEXT_SIZE` в `agent_system/config.py`, например с `4096` до `2048`;
3. закройте другие приложения Android;
4. после этого снова выполните прямой тест `llama-cli`.

---

## 20. Полностью локальная схема

После первоначальной загрузки:

```text
Android
  ↓
Termux
  ↓
llama-cli
  ↓
Qwen2.5-Coder GGUF
  ↓
Python agent_system
  ↓
локальный проект игры
```

API-ключ для inference не используется.
