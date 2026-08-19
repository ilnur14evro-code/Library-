#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPO_URL="https://github.com/ilnur14evro-code/Library-.git"
REPO_DIR="${HOME}/Library-"
LLAMA_SRC="${HOME}/llama.cpp"
MODEL_DIR="${HOME}/models"
MODEL_FILE="qwen2.5-coder-3b-instruct-q4_k_m.gguf"
MODEL_PATH="${MODEL_DIR}/${MODEL_FILE}"
MODEL_URL="https://huggingface.co/Qwen/Qwen2.5-Coder-3B-Instruct-GGUF/resolve/main/${MODEL_FILE}?download=true"
BIN_DIR="${PREFIX}/bin"

say() { printf '\n==> %s\n' "$*"; }
fail() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

command -v pkg >/dev/null 2>&1 || fail "Этот скрипт нужно запускать внутри Termux."

say "Обновление Termux"
pkg update -y
pkg upgrade -y

say "Установка базовых зависимостей"
pkg install -y git python clang cmake make curl

say "Получение Library-"
if [ -d "$REPO_DIR/.git" ]; then
    git -C "$REPO_DIR" pull --ff-only
else
    git clone "$REPO_URL" "$REPO_DIR"
fi

say "Проверка llama-cli"
if command -v llama-cli >/dev/null 2>&1; then
    echo "llama-cli уже установлен: $(command -v llama-cli)"
else
    if pkg search llama-cpp 2>/dev/null | grep -Eiq '(^|[[:space:]])llama-cpp([[:space:]]|$)'; then
        say "Установка готового пакета llama-cpp"
        pkg install -y llama-cpp || true
    fi
fi

if ! command -v llama-cli >/dev/null 2>&1; then
    say "Сборка llama.cpp внутри Termux"
    if [ -d "$LLAMA_SRC/.git" ]; then
        git -C "$LLAMA_SRC" pull --ff-only
    else
        git clone --depth=1 https://github.com/ggml-org/llama.cpp.git "$LLAMA_SRC"
    fi

    cmake -S "$LLAMA_SRC" -B "$LLAMA_SRC/build" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DGGML_NATIVE=OFF \
        -DGGML_OPENMP=OFF \
        -DLLAMA_CURL=OFF \
        -DLLAMA_BUILD_TESTS=OFF \
        -DLLAMA_BUILD_EXAMPLES=ON

    cmake --build "$LLAMA_SRC/build" --config Release --target llama-cli -j 2
    test -x "$LLAMA_SRC/build/bin/llama-cli" || fail "Сборка завершилась, но llama-cli не найден."
    install -m 755 "$LLAMA_SRC/build/bin/llama-cli" "$BIN_DIR/llama-cli"
fi

say "Подготовка каталога модели"
mkdir -p "$MODEL_DIR"

if [ -f "$MODEL_PATH" ]; then
    echo "Модель уже загружена: $MODEL_PATH"
else
    say "Загрузка Qwen2.5-Coder-3B-Instruct Q4_K_M (~2.1 GB)"
    echo "Не вводите имя модели как команду. Установщик сам скачивает файл."
    echo "Можно прервать загрузку и повторно запустить этот скрипт: curl продолжит загрузку."
    curl -L --fail --retry 3 --retry-delay 3 --continue-at - \
        -o "$MODEL_PATH" \
        "$MODEL_URL"
fi

test -s "$MODEL_PATH" || fail "Файл модели отсутствует или пустой: $MODEL_PATH"

say "Настройка пути модели"
python - "$REPO_DIR/agent_system/config.py" "$MODEL_FILE" <<'PY'
from pathlib import Path
import re
import sys

config = Path(sys.argv[1])
model_file = sys.argv[2]
text = config.read_text(encoding="utf-8")
replacement = f'MODEL_PATH = Path.home() / "models" / "{model_file}"'
text, count = re.subn(r'^MODEL_PATH\s*=.*$', replacement, text, flags=re.MULTILINE)
if count != 1:
    raise SystemExit("Не удалось автоматически настроить MODEL_PATH в config.py")
config.write_text(text, encoding="utf-8")
PY

say "Проверка llama.cpp и Qwen"
python --version
llama-cli --version
llama-cli \
    -m "$MODEL_PATH" \
    -c 2048 \
    -n 32 \
    -p "Ответь одним словом: готов" \
    >/tmp/qwen_test.out
cat /tmp/qwen_test.out

GAME_DIR="${HOME}/Game"
mkdir -p "$GAME_DIR"

say "Проверка Python-файлов агентов"
cd "$REPO_DIR/agent_system"
python -m py_compile config.py llm.py tools.py agents.py run_agent.py

cat <<EOF

Установка завершена.

Library-:
  $REPO_DIR

Модель:
  $MODEL_PATH

llama-cli:
  $(command -v llama-cli)

Игровой проект по умолчанию:
  $GAME_DIR

Проверка агента:
  cd "$REPO_DIR/agent_system"
  python run_agent.py "Добавь небольшое изменение в игру и запусти тесты"

Важно:
  - API-ключ не используется.
  - После загрузки модели inference выполняется локально.
  - Существующие файлы Library- этим скриптом не удаляются.
  - Не вводите "Qwen2.5-Coder-3B-Instruct Q4_K_M" как команду: это название модели, а не команда Termux.
EOF
