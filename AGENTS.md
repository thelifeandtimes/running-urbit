# Creating Agent Skills for urbit-skills

This guide explains how to create new AI agent skills for the urbit-skills repository. These skills improve an agent's understanding of how to operate within Urbit and help Urbit developers build apps on the platform.

## Repository Structure

```
urbit-skills/
├── SKILL.md                 # Repository overview
├── AGENTS.md                # This guide
├── LICENSE                  # MIT License
└── <skill-name>/
    └── SKILL.md             # Skill definition
```

## What is a Skill?

A skill is a markdown file that teaches an AI agent how to perform specific tasks within Urbit. Skills follow the [Agent Skills](https://agentskills.io/) open standard and work across multiple AI tools including Claude Code.

Each skill has two parts:

1. **YAML frontmatter** (between `---` markers) - Controls when and how the skill is invoked
2. **Markdown content** - Instructions the agent follows when the skill is invoked

## Creating a New Skill

### Step 1: Create the Skill Directory

```bash
mkdir -p urbit-skills/your-skill-name
```

Use lowercase letters, numbers, and hyphens only (max 64 characters).

### Step 2: Write SKILL.md

Create `urbit-skills/your-skill-name/SKILL.md` with the following structure:

```markdown
---
name: your-skill-name
description: Brief description of what this skill does and when to use it.
user-invocable: true
disable-model-invocation: false
argument-hint: [argument-hint-here]
---

# Your Skill Title

Detailed instructions for the agent to follow when this skill is invoked.
```

### Step 3: Test the Skill

Add the skills directory to your Claude Code configuration:

```bash
/add-dir /path/to/urbit-skills
```

Then test by either:
- Letting the agent invoke it automatically based on the description
- Invoking it directly: `/your-skill-name <arguments>`

## Frontmatter Reference

All frontmatter fields are optional except where noted:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | Display name. If omitted, uses directory name. Lowercase letters, numbers, hyphens only (max 64 chars). |
| `description` | string | Recommended | What the skill does and when to use it. Agents use this to decide when to apply the skill. |
| `argument-hint` | string | No | Hint shown during autocomplete. Example: `[pier-path]` or `[command] [pier-path]` |
| `disable-model-invocation` | boolean | No | Set to `true` to prevent automatic invocation. Use for manual-only workflows. Default: `false`. |
| `user-invocable` | boolean | No | Set to `false` to hide from the `/` menu. Use for background knowledge. Default: `true`. |
| `allowed-tools` | array | No | Tools agents can use without permission when this skill is active. |
| `model` | string | No | Model to use when this skill is active. |
| `context` | string | No | Set to `fork` to run in a forked subagent context. |
| `agent` | string | No | Which subagent type to use when `context: fork` is set. |
| `hooks` | object | No | Hooks scoped to this skill's lifecycle. |

## Controlling Skill Invocation

By default, both users and agents can invoke any skill. Use these fields to control behavior:

### `disable-model-invocation: true`

Only users can invoke the skill. Use this for workflows with side effects or that you want to control timing.

Example:
```yaml
---
name: ship-backup
description: Create a backup of a running ship's pier
disable-model-invocation: true
---
```

### `user-invocable: false`

Only agents can invoke the skill. Use this for background knowledge that users shouldn't invoke directly.

Example:
```yaml
---
name: urbit-reference
description: Reference information about Urbit's architecture and design patterns
user-invocable: false
---
```

### Invocation Summary

| Frontmatter | User can invoke | Agent can invoke | When loaded into context |
|-------------|----------------|------------------|--------------------------|
| (default) | Yes | Yes | Description always in context, full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description not in context, full skill loads when you invoke |
| `user-invocable: false` | No | Yes | Description always in context, full skill loads when invoked |

## Passing Arguments to Skills

Both users and agents can pass arguments when invoking a skill. Arguments are available via the `$ARGUMENTS` placeholder.

### Using `$ARGUMENTS`

```yaml
---
name: run-hoon-test
description: Run Hoon tests for a specific desk
argument-hint: <desk-name>
---

Run tests for $ARGUMENTS desk:

1. Use urbit-terminal to switch to the desk
2. Run :hood +dribble
3. Check the output for failures
```

When invoked: `/run-hoon-test base` → `$ARGUMENTS` becomes `base`

### Using positional arguments

```yaml
---
name: install-desk
description: Install a desk from another ship
argument-hint: <source-ship> <desk-name>
---

Install desk $1 from $0:

1. Verify source ship $0 is accessible
2. Run |install ~$0 $1
3. Verify installation succeeded
```

When invoked: `/install-desk sampel-palnet %base` → `$0` is `sampel-palnet`, `$1` is `%base`

## String Substitutions

Skills support these variables for dynamic values:

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed when invoking |
| `$ARGUMENTS[N]` | Specific argument by 0-based index |
| `$N` | Shorthand for `$ARGUMENTS[N]` |
| `${CLAUDE_SESSION_ID}` | Current session ID |

## Skill Content Guidelines

### Reference Content

Adds knowledge agents apply to current work. Use for conventions, patterns, style guides, domain knowledge.

```yaml
---
name: hoon-style
description: Hoon code style conventions for this codebase
---

When writing Hoon:
- Use consistent indentation (2 spaces)
- Follow naming conventions: nouns end with `-`, verbs with `=`
- Document complex cores with `+*`
```

### Task Content

Gives agents step-by-step instructions for specific actions like deployments, commits, or code generation. These are often actions you want to invoke directly with `/skill-name`.

```yaml
---
name: publish-app
description: Publish an app to the Urbit network
disable-model-invocation: true
---

Publish $ARGUMENTS to the network:

1. Verify the app builds successfully
2. Create a release desk
3. Submit to Landscape
4. Verify publication
```

## Urbit-Specific Best Practices

### Ship Discovery

Skills that interact with ships should support auto-discovery:

```markdown
## Discover Running Ships

Search for active conn.sock files:

```bash
find ~/zod ~/bus ~/piers ~/urbit ~/.urbit -name "conn.sock" -path "*/.urb/*" 2>/dev/null
```

### Safety Guards

Always include safety checks before destructive operations:

```markdown
## Safety

Before running |pack or |meld:
- Confirm the pier path is correct
- Warn these operations can take significant time
- Verify the ship is responsive with +vats first
```

### Error Handling

Provide guidance on common failure modes:

```markdown
## Troubleshooting

If conn.sock is not found:
- The ship may not be running
- The pier path may be incorrect
- Try running +vats in the dojo to verify ship state
```

## Advanced Patterns

### Supporting Files

Skills can include additional files for reference material, examples, or scripts:

```
your-skill/
├── SKILL.md           # Main instructions (required)
├── reference.md       # Detailed API docs (optional)
├── examples.md       # Usage examples (optional)
└── scripts/
    └── helper.sh      # Executable scripts (optional)
```

Reference these files from SKILL.md:

```markdown
## Additional Resources

- For complete API details, see [reference.md](reference.md)
- For usage examples, see [examples.md](examples.md)
```

### Running in a Subagent

Use `context: fork` to isolate skill execution:

```yaml
---
name: urbit-research
description: Deep research into Urbit internals
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly:

1. Find relevant files in the Arvo codebase
2. Analyze the implementation
3. Summarize findings with file references
```

### Dynamic Context Injection

Use `!command` syntax to inject shell command output:

```yaml
---
name: ship-status
description: Get real-time status of running ships
---

## Ship Status

Current time: !`date`
Running ships: !`pgrep -a urbit | head -10`
```

## Skill Naming Conventions

- Use lowercase, hyphenated names
- Be descriptive but concise
- Avoid generic names like "test" or "deploy"
- Prefix with urbit- if generic, or specific domain names

Good examples:
- `urbit-conn` - Specific Urbit functionality
- `hoon-analyzer` - Specific domain
- `ship-backup` - Clear action

Poor examples:
- `test` - Too generic
- `deploy` - Doesn't indicate target
- `thing` - Not descriptive

## Testing Your Skill

1. **Manual invocation**: Test with `/your-skill-name <arguments>`
2. **Automatic triggering**: Ask questions that match your description
3. **Edge cases**: Test with missing or invalid arguments
4. **Error paths**: Verify error handling works correctly

## Contributing

When contributing a new skill:

1. Follow this guide's structure
2. Include comprehensive documentation
3. Test thoroughly with real Urbit ships
4. Add the skill to the README.md summary
5. Submit a pull request with descriptive commit message

## Resources

- [Agent Skills Specification](https://agentskills.io/)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Urbit Documentation](https://docs.urbit.org/)
- [Urbit Conn Protocol](https://github.com/urbit/urbit/blob/main/pkg/arvo/sys/zuse.hoon)
