from __future__ import annotations

import sys

from agents import apply_edits, coder, fixer, planner, tester
from config import MAX_FIX_ATTEMPTS


def main() -> int:
    if len(sys.argv) < 2:
        print('Usage: python run_agent.py "game task"')
        return 2

    task = " ".join(sys.argv[1:]).strip()
    print("[planner]")
    plan = planner(task)
    print(plan)

    print("[coder]")
    edits = coder(task, plan)
    changed = apply_edits(edits)
    print("Changed:", ", ".join(map(str, changed)) or "none")

    for attempt in range(1, MAX_FIX_ATTEMPTS + 1):
        print(f"[tester] attempt {attempt}")
        code, output = tester()
        print(output)
        if code == 0:
            print("SUCCESS")
            return 0

        if attempt == MAX_FIX_ATTEMPTS:
            print("FAILED: maximum repair attempts reached")
            return code or 1

        print("[fixer]")
        patch = fixer(task, plan, output)
        changed = apply_edits(patch)
        print("Changed:", ", ".join(map(str, changed)) or "none")

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
