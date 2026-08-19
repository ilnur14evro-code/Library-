#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPO_URL="https://github.com/ilnur14evro-code/Library-.git"
REPO_DIR="${HOME}/Library-"
LLAMA_SRC="${HOME}/llama.cpp"
MODEL_DIR="${HOME}/models"
MODEL_FILE="qwen2.5-coder-3b-instruct-q4_k_m.gguf"
MODEL_PATH="${MODEL_DIR}/${MODEL_FILE}"
PART_PATH="${MODEL_PATH}.part"
MODEL_URL="https://huggingface.co/Qwen/Qwen2.5-Coder-3B-Instruct-GGUF/resolve/main/${MODEL_FILE}?download=true"
EXPECTED_SHA256="724fb256bec1ff062b2f65e4569e871ad2e95ab2a3989723d1769c54294730b7"
BIN_DIR="${PREFIX}/bin"
CACHE_DIR="${HOME}/.cache/library-qwen"
TEST_OUT="${CACHE_DIR}/qwen_test.out"
TEST_ERR="${CACHE_DIR}/qwen_test.err"

say() { printf '\n==> %s\n' "$*"; }
fail() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

command -v pkg >/dev/null 2>&1 || fail "Этот скрипт нужно запускать внутри Termux."

say "Обновление Termux"
pkg update -y
pkg upgrade -y

say "Установка базовых зависимостей"
pkg install -y git python clang cmake make curl

say "Проверка Library-"
if [ -d "$REPO_DIR/.git" ]; then
    git -C "$REPO_DIR" pull --ff-only || fail "Не удалось обновить Library-. Сначала проверьте git -C '$REPO_DIR' status."
else
    if [ -e "$REPO_DIR" ]; then
        fail "$REPO_DIR уже существует, но это не Git-репозиторий. Не удаляйте его автоматически. Проверьте содержимое вручную."
    fi
    git clone "$REPO_URL" "$REPO_DIR"
fi

say "Проверка llama-cli"
if command -v llama-cli >/dev/null 2>&1; then
    echo "llama-cli уже установлен: $(command -v llama-cli)"
else
    say "Попытка установки пакета llama-cpp"
    if pkg search llama-cpp >/dev/null 2>&1; then
        pkg install -y llama-cpp || true
    fi
fi

if ! command -v llama-cli >/dev/null 2>&1; then
    say "Сборка llama.cpp внутри Termux"
    if [ -d "$LLAMA_SRC/.git" ]; then
        git -C "$LLAMA_SRC" pull --ff-only
    elif [ -e "$LLAMA_SRC" ]; then
        fail "$LLAMA_SRC уже существует, но это не Git-репозиторий. Удалять его автоматически нельзя."
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
mkdir -p "$MODEL_DIR" "$CACHE_DIR"

verify_model() {
    [ -s "$1" ] || return 1
    local actual
    actual="$(sha256sum "$1" | awk '{print $1}')"
    [ "$actual" = "$EXPECTED_SHA256" ]
}

if [ -s "$MODEL_PATH" ]; then
    say "Проверка существующей модели"
    if verify_model "$MODEL_PATH"; then
        echo "Модель корректна: $MODEL_PATH"
    else
        BROKEN_PATH="${MODEL_PATH}.broken.$(date +%Y%m%d-%H%M%S)"
        echo "Существующий GGUF не совпадает с контрольной суммой. Сохраняю его как: $BROKEN_PATH"
        mv "$MODEL_PATH" "$BROKEN_PATH"
    fi
fi

if [ ! -s "$MODEL_PATH" ]; then
    say "Загрузка Qwen2.5-Coder-3B-Instruct Q4_K_M"
    echo "Целевой файл: $MODEL_PATH"
    echo "SHA256 оригинального файла Qwen: $EXPECTED_SHA256"
    echo "Не вводите имя модели как команду. Установщик скачивает .gguf сам."

    if [ -s "$PART_PATH" ]; then
        echo "Продолжаем незавершённую загрузку: $PART_PATH"
    fi

    curl -L --fail --retry 5 --retry-delay 3 --continue-at - \
        -o "$PART_PATH" \
        "$MODEL_URL"

    if ! verify_model "$PART_PATH"; then
        echo "SHA256 загруженного файла не совпадает. Начинаю чистую загрузку."
        rm -f "$PART_PATH"
        curl -L --fail --retry 5 --retry-delay 3 \
            -o "$PART_PATH" \
            "$MODEL_URL"
    fi

    verify_model "$PART_PATH" || fail "Файл модели скачан, но SHA256 не совпадает. Это нерабочая/неполная загрузка. Повторите установку; Library- удалять не нужно."
    mv "$PART_PATH" "$MODEL_PATH"
fi

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
if ! llama-cli \
    -m "$MODEL_PATH" \
    -c 2048 \
    -n 32 \
    -p "Ответь одним словом: готов" \
    >"$TEST_OUT" 2>"$TEST_ERR"; then
    cat "$TEST_ERR" >&2 || true
    fail "Qwen не запустился. Если SHA256 совпадает, смотрите ошибку выше: это уже проблема запуска или памяти, а не повреждённого файла."
fi
cat "$TEST_OUT"

say "Проверка Python-файлов агентов"
cd "$REPO_DIR/agent_system"
python -m py_compile config.py llm.py tools.py agents.py run_agent.py

cat <<EOF

Установка завершена.

Library-:
  $REPO_DIR

Модель:
  $MODEL_PATH

SHA256:
  $EXPECTED_SHA256

llama-cli:
  $(command -v llama-cli)

Игровой проект по умолчанию:
  ${HOME}/Game

Запуск агента:
  cd "$REPO_DIR/agent_system"
  python run_agent.py "Добавь небольшое изменение в игру и запусти тесты"

Важно:
  - API-ключ не используется.
  - После загрузки модели inference выполняется локально.
  - Существующие файлы Library- этим скриптом не удаляются.
  - Повреждённая модель сохраняется с суффиксом .broken.<дата>, а не удаляется.
  - Не вводите "Qwen2.5-Coder-3B-Instruct Q4_K_M" как команду: это название модели, а не команда Termux.
EOF
