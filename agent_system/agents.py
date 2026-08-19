from __future__ import annotations

import re
from pathlib import Path

from llm import ask
from tools import read_project, run_allowed, PROJECT_DIR


def planner(task: str) -> str:
    prompt = f"""You are the planning agent for a local Android/Termux game project.\nTask: {task}\nProject snapshot:\n{read_project()}\nReturn a short numbered implementation plan. Do not invent files that are unnecessary."""
    return ask(prompt)


def coder(task: str, plan: str) -> str:
    prompt = f"""You are the coding agent working inside {PROJECT_DIR}.\nUser task: {task}\nPlan:\n{plan}\nProject:\n{read_project()}\nGive precise file edits only. For each changed file use:\nFILE: relative/path\n```text\ncomplete replacement file contents\n```\nDo not delete unrelated files. Preserve existing functionality."""
    return ask(prompt)


def apply_edits(response: str) -> list[Path]:
    pattern = re.compile(r"FILE:\s*(.+?)\n```(?:text|python|c|cpp|h|json|markdown)?\n(.*?)\n```", re.S)
    changed: list[Path] = []
    for raw_path, content in pattern.findall(response):
        relative = Path(raw_path.strip())
        if relative.is_absolute() or ".." in relative.parts:
            raise ValueError(f"Unsafe path from model: {relative}")
        target = (PROJECT_DIR / relative).resolve()
        if PROJECT_DIR not in target.parents and target != PROJECT_DIR:
            raise ValueError(f"Path escapes project directory: {relative}")
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")
        changed.append(relative)
    return changed


def tester() -> tuple[int, str]:
    result = run_allowed("make test")
    output = (result.stdout + "\n" + result.stderr).strip()
    return result.returncode, output


def fixer(task: str, plan: str, test_output: str) -> str:
    prompt = f"""You are the fixing agent.\nTask: {task}\nPlan: {plan}\nTest/build output:\n{test_output}\nProject:\n{read_project()}\nProduce only the minimal file edits required to fix the failure. Use FILE: path and fenced complete file contents. Never remove unrelated files."""
    return ask(prompt)
