# urbit-skills

A growing repository of AI agent skills that solves the problem of coding agents having imperfect understanding of the Urbit runtime, Urbit terminal commands, and Urbit-native programming languages like Hoon and Nock. These skills give AI agents practical knowledge of ship operations, the Urbit development workflow, and the tools that ship owners and app developers use day to day.

The skills below are the first in the collection, focused on ship interaction. Future skills will cover areas like Hoon development, agent building, desk management, testing, and more.

## Skills

### urbit-conn

Programmatic ship interaction via the `conn.c` Unix domain socket (`.urb/conn.sock`). Sends commands using `click` or the raw `urbit eval | nc` pipeline without requiring an interactive terminal session.

Supports: scry (`%peek`), runtime queries (`%peel`), thread execution (`%fyrd`), raw event injection (`%ovum`), and runtime commands (`%urth`). Includes ready-to-use templates for common operations like `|pack`, `|meld`, `+code`, `+vats`, `|ota`, and `|install`.

### urbit-terminal

Interactive dojo access through screen or tmux. Discovers running ship sessions, sends dojo commands, and captures output via scrollback buffers.

Includes a dojo command reference covering generators, hood commands, threads, and agent interaction, along with safety guards for destructive operations.

## Contributing

To create new skills for this repository, see [AGENTS.md](AGENTS.md) for a complete guide on skill creation, frontmatter configuration, and best practices for Urbit-specific skills.

## Installation

Add the skills directory to your Claude Code configuration:

```
/add-dir /path/to/urbit-skills
```

Or place individual skill directories into `~/.claude/skills/`.

## Requirements

- **urbit-conn**: `urbit` binary on PATH (required). `click` on PATH (optional, recommended). `nc` (netcat) for raw socket communication.
- **urbit-terminal**: `screen` or `tmux` with a ship running in a named session.
