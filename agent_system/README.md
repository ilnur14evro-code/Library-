# Local Qwen Agent System for Termux

## 1. Install Termux packages

```bash
pkg update -y
pkg upgrade -y
pkg install -y git python clang cmake make
```

Check whether llama.cpp is packaged:

```bash
pkg search llama
```

If `llama-cli` is available, verify:

```bash
llama-cli --version
```

## 2. Prepare the local model

Create a model directory:

```bash
mkdir -p ~/models
```

Place a compatible Qwen2.5-Coder GGUF file there. For 8 GB RAM start with a 1.5B or 3B Q4 model. For 12–16 GB RAM test 7B Q4.

Edit `config.py` if your model filename differs.

## 3. Select the game project

The default is:

```text
~/Game
```

Edit `PROJECT_DIR` in `config.py` to point to the existing game repository. The agent writes only inside that directory.

## 4. Start an agent task

```bash
cd ~/Library-/agent_system
python run_agent.py "Добавь экран меню с кнопками Start, Settings и Exit"
```

The runner performs:

```text
Planner → Coder → make test → Fixer → make test
```

It stops after `MAX_FIX_ATTEMPTS` failed repair cycles.

## 5. Safety model

The current implementation deliberately does **not** give the model unrestricted shell access. Only exact commands listed in `config.py` can be executed by the testing tool.

The model's file edits are constrained to `PROJECT_DIR`; absolute paths and `..` traversal are rejected.

Command output is appended to:

```text
<PROJECT_DIR>/.agent_commands.log
```

## 6. Existing repository files

`README.md` and `SETUP_TERMUX.md` are existing project files and are intentionally left unchanged. This directory is additive.

## 7. Limitations

This first version does not include automatic git commits, network access, package installation by the model, or arbitrary shell commands. Those should remain explicit human-controlled operations until the agent is tested on the actual phone and game project.
