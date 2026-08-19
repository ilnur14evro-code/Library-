from pathlib import Path

# Change this path after downloading your local GGUF model.
MODEL_PATH = Path.home() / "models" / "qwen2.5-coder-3b-instruct-q4_k_m.gguf"

# Existing game/project directory. Override with an absolute path if needed.
PROJECT_DIR = Path.home() / "Game"

# llama.cpp executable. Termux package or local build may expose llama-cli here.
LLAMA_CLI = "llama-cli"

CONTEXT_SIZE = 4096
MAX_TOKENS = 1024
TEMPERATURE = 0.2
MAX_FIX_ATTEMPTS = 3

# Commands explicitly allowed to the test/build tool.
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
