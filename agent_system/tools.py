from __future__ import annotations

import subprocess
from pathlib import Path
from shlex import split

from config import ALLOWED_COMMANDS, PROJECT_DIR


PROJECT_DIR = PROJECT_DIR.expanduser().resolve()
LOG_FILE = PROJECT_DIR / ".agent_commands.log"


def _log(command: str, result: subprocess.CompletedProcess[str]) -> None:
    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
    with LOG_FILE.open("a", encoding="utf-8") as fh:
        fh.write(f"$ {command}\n")
        fh.write(result.stdout)
        if result.stderr:
            fh.write("[stderr]\n" + result.stderr)
        fh.write("\n")


def run_allowed(command: str) -> subprocess.CompletedProcess[str]:
    """Run one exact allow-listed command inside the project directory."""
    if command not in ALLOWED_COMMANDS:
        raise PermissionError(f"Command is not allow-listed: {command}")

    PROJECT_DIR.mkdir(parents=True, exist_ok=True)
    result = subprocess.run(
        split(command),
        cwd=PROJECT_DIR,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    _log(command, result)
    return result


def read_project(max_chars: int = 12000) -> str:
    """Collect a compact text snapshot of source/config files."""
    chunks: list[str] = []
    for path in sorted(PROJECT_DIR.rglob("*")):
        if not path.is_file() or ".git" in path.parts or path.name == ".agent_commands.log":
            continue
        if path.suffix.lower() not in {".c", ".h", ".cpp", ".py", ".md", ".txt", ".mk", ".json"}:
            continue
        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        remaining = max_chars - sum(len(x) for x in chunks)
        if remaining <= 0:
            break
        chunks.append(f"\n--- {path.relative_to(PROJECT_DIR)} ---\n{text[:remaining]}")
    return "".join(chunks)
