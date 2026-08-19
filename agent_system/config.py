from pathlib import Path

# Local GGUF Qwen2.5-Coder model.
MODEL_PATH = Path.home() / "models" / "qwen2.5-coder-3b-instruct-q4_k_m.gguf"

# Existing game/project directory. Change to an absolute path if needed.
PROJECT_DIR = Path.home() / "Game"

# Installed by: pkg install llama-cpp
LLAMA_CLI = "llama-cli"

CONTEXT_SIZE = 4096
MAX_TOKENS = 1024
TEMPERATURE = 0.2
MAX_FIX_ATTEMPTS = 3

# Exact commands allowed to the build/test tool.
# No delete command is included.
ALLOWED_COMMANDS = {
    "make",
    "make test",
    "make clean",
    "make test_entity",
    "make test_player",
    "make test_collision",
    "make test_camera",
    "make test_component",
    "make test_brain",
}
