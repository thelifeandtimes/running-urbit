---
name: hoon-expert-assistant
description: Expert Hoon development assistant for implementing complex features, debugging issues, and writing production-ready Hoon code. Use when needing help with Hoon implementation, type errors, performance optimization, or understanding idiomatic patterns.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Hoon Expert Assistant

Coordinating expert skill for nontrivial Hoon work. Tells you *how to operate*:
inspect local code first, classify the task, delegate to specialized Hoon
skills, apply senior Hoon engineering judgment, make conservative edits, and
verify. This is a router and a judgment layer — not a reference manual.

## Use This Skill For

- Nontrivial Hoon implementation where design choices matter.
- Refactoring Hoon while preserving observable behavior.
- Debugging when the error crosses syntax / type / runtime boundaries.
- Choosing between competing Hoon design approaches.
- Reviewing Hoon for correctness and maintainability.

## Do Not Use This As

- A rune reference → `hoon-basics`.
- A type-system manual → `type-system`.
- A data-structure API reference → `data-structures`.
- A Gall app workflow guide → `app-development-workflow`.

## Operating Workflow

1. **Read first.** Open the target file and its nearby imports (`/-`, `/+`,
   `/=`, `=<` faces). Never edit code you have not read in context.
2. **Locate context.** Identify the desk and whether you are in an
   app/agent, lib, sur, gen, mar, or ted file. Conventions differ by role.
3. **Classify the task.** Pick the dominant axis: syntax, type-system,
   data-structure, Gall, migration, testing, style, or domain logic. Most
   real tasks have one primary axis plus one or two secondary ones.
4. **Load companion skill(s)** for the classified axes (see routing below).
   Load before deciding, not after a guess fails.
5. **Reuse before inventing.** Prefer existing project molds, arms, doors,
   marks, and helper libraries over new ones.
6. **Make the smallest coherent change** that solves the problem.
7. **Verify** with the smallest available compile/test path.

## Companion Skill Routing

| Axis / signal | Load |
|---|---|
| Rune forms, syntax, parser gotchas, number/literal formatting | `hoon-basics` |
| Molds, casts, auras, variance, `nest-fail`, `*`-typed nouns | `type-system` |
| Lists, sets, maps, mops, jars, jugs — APIs & performance | `data-structures` |
| Compiler/runtime errors, `fish-loop`, stack traces, root cause | `debugging-specialist-assistant` |
| Formatting, naming, documentation conventions | `hoon-style-guide` |
| Test design, generators, TDD | `hoon-test-workflow` |
| Gall agents, desks, fake ships, app packaging | `app-development-workflow` |
| Gall state versioning & upgrades | `hoon-migrate-workflow` |
| Obelisk urQL / SQL or `%obelisk` agent behavior | `obelisk-urql` |

When in doubt, route. A two-minute companion-skill load beats a wrong edit.

## Expert Hoon Heuristics

- Normalize untyped or `*` input at boundaries; do not carry `*` through core
  logic. Cast to a real mold as early as possible.
- Put explicit return molds (`^-`) on public arms and any nontrivial gate.
- Bind ambiguous deep wings to typed intermediates instead of repeating long
  wing paths.
- Prefer tagged unions (`$%`) for action, state, and message variants.
- Prefer stdlib container doors (`by`, `in`, `to`, `mo`, `si`) over hand-rolled
  traversal.
- Choose data structures by access pattern, not by habit.
- Use `unit` for expected absence; reserve crashes for invariant violations.
- Wrap intentional crash boundaries with `~|` traces so failures are legible.
- Avoid wet gates unless they remove real duplication and you understand the
  resulting type behavior.
- Keep Gall state versioned and migrations explicit.
- Avoid broad rewrites when a narrow change solves the problem.

## Implementation Guardrails

- Do not invent APIs before checking imports and neighboring code.
- Do not change state molds without a migration plan.
- Do not hand-roll parsers or containers when stdlib/project helpers exist.
- Do not trust abstract examples over locally compiling patterns.
- Do not silently swallow crashes that signal invariant corruption.

## Verification Checklist

- [ ] Relevant companion skill(s) loaded for the task's axes.
- [ ] Existing local patterns followed (molds, arms, helpers, marks).
- [ ] Types/molds checked at every boundary.
- [ ] Smallest compile/test path run when one is available.
- [ ] Edge cases considered: `~`, empty lists, missing map keys, bad marks,
      failed casts, unauthorized pokes.
- [ ] Final answer states what changed and what was *not* verified.
