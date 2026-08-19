#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPO_URL="https://github.com/ilnur14evro-code/Library-.git"
REPO_DIR="${HOME}/Library-"
LLAMA_SRC="${HOME}/llama.cpp"
MODEL_DIR="${HOME}/models"
BIN_DIR="${PREFIX}/bin"

say() { printf '\n==> %s\n' "$*"; }
fail() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

command -v pkg >/dev/null 2>&1 || fail "Этот скрипт нужно запускать внутри Termux."

say "Обновление Termux"
pkg update -y
pkg upgrade -y

say "Установка зависимостей"
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

say "Подготовка каталогов"
mkdir -p "$MODEL_DIR"

say "Проверка Python"
python --version
llama-cli --version

cat <<EOF

Установка завершена.

Репозиторий:
  $REPO_DIR

Папка моделей:
  $MODEL_DIR

Установленный llama-cli:
  $(command -v llama-cli)

Следующий шаг:
  cd "$REPO_DIR/agent_system"
  sed -n '1,220p' README.md

Поместите локальный GGUF Qwen2.5-Coder в:
  $MODEL_DIR

После этого проверьте путь модели в:
  $REPO_DIR/agent_system/config.py

Важно: существующие файлы репозитория не удаляются этим установщиком.
EOF
