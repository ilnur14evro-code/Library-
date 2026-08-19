from __future__ import annotations

import subprocess
from pathlib import Path

from config import CONTEXT_SIZE, LLAMA_CLI, MAX_TOKENS, MODEL_PATH, TEMPERATURE


def ask(prompt: str) -> str:
    """Run the local GGUF model through llama.cpp; no API is used."""
    model = Path(MODEL_PATH).expanduser()
    if not model.is_file():
        raise FileNotFoundError(f"Local model not found: {model}")

    command = [
        LLAMA_CLI,
        "-m",
        str(model),
        "-c",
        str(CONTEXT_SIZE),
        "-n",
        str(MAX_TOKENS),
        "--temp",
        str(TEMPERATURE),
        "-p",
        prompt,
    ]

    result = subprocess.run(
        command,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "llama.cpp failed")
    return result.stdout.strip()
