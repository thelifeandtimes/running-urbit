---
name: hoon-basics
description: Quick reference for Hoon syntax fundamentals including rune forms, data types, gates, and common idioms. Use when needing fast syntax lookups, verifying rune usage, or resolving common gotchas for developers with working Hoon knowledge.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Hoon Basics Quick Reference

Concise syntax reference for core Hoon patterns and common operations.

## Rune Forms

### Tall vs Wide vs Irregular

```hoon
::  Tall form (multi-line, explicit)
%-  add
:-  2
3

::  Wide form (single-line, compact)
%-(add [2 3])

::  Irregular form (syntactic sugar)
(add 2 3)
```

**Gotcha**: Irregular forms are preferred for readability but compile identically.

### Bracket and Paren Irregular Forms

`[]` tuple syntax and `()` gate-call syntax are single-line irregular forms.
When an expression needs to contain tall-form runes, use tall form for the
containing cell or gate call too.

```hoon
::  CORRECT: all on one line
=/  foo  [(heading i.selected name.i.selected) 42]

::  WRONG: [] cannot contain a multi-line tall-form expression
=/  foo  [(heading i.selected name.i.selected)
            (%-  selected-cte-dime  [i.selected named-ctes])]

::  CORRECT: use tall cell construction when an item needs tall form
=/  foo
  :-  (heading i.selected name.i.selected)
  %-  selected-cte-dime
  [i.selected named-ctes]
```

### Face Labels Cannot Directly Take Tall-Form Values

Face-label syntax like `name=value` is only safe when `value` is a regular
single-expression form. Do not put a tall-form rune immediately after `=`.

```hoon
::  WRONG: face label directly before tall list syntax
:-  columns=~[col1 col2 col3]
    values=:~  [value-type=%t value='foo']
              [value-type=%tas value=%foo]
              [value-type=%ta value=~.foo-bar]
              ==
```

Factor the tall-form value out, or build the surrounding value without labels.

```hoon
::  CORRECT: bind the tall list first
=/  vals
  :~  [value-type=%t value='foo']
      [value-type=%tas value=%foo]
      [value-type=%ta value=~.foo-bar]
      ==

:-  columns=~[col1 col2 col3]
    values=vals
```

This also applies to other tall runes after labels, such as `field=%-`,
`field=:-`, or `field=:*`.

## Core Data Types

### Atoms (unsigned integers with auras)

```hoon
42              ::  @ud (unsigned decimal)
0x2a            ::  @ux (hexadecimal)
~zod            ::  @p (ship name)
'Hello'         ::  @t (text/cord)
0b101010        ::  @ub (binary)
```

### Cells (ordered pairs)

```hoon
[1 2]           ::  Two-element cell
[1 2 3]         ::  Right-branching: [1 [2 3]]
[[1 2] [3 4]]   ::  Nested cells
```

## Gates (Functions)

### Basic Gate Syntax

```hoon
|=  a=@ud           ::  Gate with typed argument
(add a 10)

|=  [a=@ud b=@ud]   ::  Multiple arguments
(add a b)

|%                  ::  Core with multiple arms
++  increment
  |=  a=@ud
  (add a 1)
++  decrement
  |=  a=@ud
  (sub a 1)
--
```

## Conditional Logic

```hoon
?:  condition       ::  If-then-else (wutcol)
  true-branch
false-branch

?~  list            ::  If null/not-null (wutsig)
  null-case
not-null-case

?@  value           ::  If atom/cell (wutpat)
  atom-case
cell-case
```

### Single-Expression Branch Rule

Conditional runes (`?:`, `?~`, `?@`, etc.) take exactly **one hoon expression** for each branch. If a branch requires multiple statements, extract them into a separate arm and call it as a single expression.

**Exception:** `~&` and `~|` hint runes fuse with their following rune into one statement, so `~|("error" (some-gate ...))` counts as one expression.

```hoon
::  CORRECT: single expression in true branch
?~  tbl  (from-cte qualified-table named-ctes)

::  CORRECT: ~| hint fuses with following expression
?~  tbl  ~|("not found" !!)

::  WRONG: multiple statements in true branch — must use a separate arm
?~  tbl
  =/  x  (some-gate ...)
  =/  y  i.x
  (another-gate y)
```

### Tall-Form `?+` / `?-` Must End With `==`

Tall-form switch runes like `?+` and `?-` open a clause block that must be closed with `==`.

If you forget the final `==`, the parser often reports a syntax error at the next arm (`++ foo`) or the next top-level form, which can make the real problem hard to spot.

```hoon
::  WRONG — missing final ==
?+  -.result  ;/("")
  %result-set
    (print-result-export-set +.result)

::  CORRECT
?+  -.result  ;/("")
  %result-set
    (print-result-export-set +.result)
==

::  Another example
?-  kind
  %foo  foo-value
  %bar  bar-value
==
```

## Lists

```hoon
~[1 2 3 4]         ::  List literal
[1 2 3 4 ~]        ::  Manual construction (equivalent)
~                  ::  Empty list (null)

::  List operations
(lent list)        ::  Length
(snag 2 list)      ::  Index access (0-based)
(weld list1 list2) ::  Concatenate
(turn list gate)   ::  Map
(roll list gate)   ::  Reduce/fold
```

### List Head/Tail Access: `i.` and `t.`

`i.list` (head) and `t.list` (tail) are **only valid after the compiler knows the list is non-empty**. The type system enforces this — code that uses `i.` or `t.` on a `(list)` without first narrowing to a non-empty list will fail to compile.

Use `?~` to narrow the type:

```hoon
=/  items=(list @ud)  ~[1 2 3]
::
::  WRONG: i.items and t.items here — compiler rejects
::
?~  items  ~            ::  handle empty case
::  CORRECT: after ?~, compiler knows items is non-empty
=/  first  i.items      ::  head: 1
=/  rest   t.items      ::  tail: ~[2 3]
```

This applies to any list-typed expression, including faces on cores:

```hoon
=/  cte-fr  (some-gate ...)
?~  set-tables.cte-fr  !!
=/  first-st  i.set-tables.cte-fr   ::  valid after ?~
```

## Common Idioms

### Type Casting

```hoon
`@ud`0x10          ::  Cast hex to decimal → 16
`@t`'string'       ::  Cast to cord
^-  @ud  value     ::  Type assertion (kethep)
```

### Pinning Values (=/  tisfas)

```hoon
=/  x  42          ::  Pin value to face
=/  y  (add x 10)  ::  Use pinned value
(mul x y)          ::  Both available in subject
```

### Pattern Matching with Faces

```hoon
=/  cell  [1 2]
=/  [a b]  cell    ::  Destructure into faces
(add a b)          ::  → 3
```

### Bunting for Defaults

`*` produces the bunt, or default value, for a mold. This is the usual way to
initialize empty containers and typed zero values.

```hoon
=/  users  *(map @ud user)
=/  count  *@ud
```

## Gotchas

1. **Null is `~`** not `0` or `false` or `nil`
2. **Lists are right-branching**: `~[1 2 3]` = `[1 [2 [3 ~]]]`
3. **Runes are two characters**: `=+` not `=`, `|-` not `|`
4. **Hoon has no strings**: Use `@t` (cord) or `tape` (list of @tD)
5. **Subject-oriented**: Everything operates on implicit context (the subject)
6. **Whitespace matters in tall form**: Two spaces for indentation
7. **No mutation**: All data structures are immutable
8. **Number formatting**: Numbers over 999 MUST use dots every 3 digits: `1.000` not `1000`, `844.494` not `844494`. Omitting dots causes a parser error (e.g. `{1 52}`) with no hint about number formatting. This is a common source of hard-to-diagnose errors.
9. **Backtick escaping from Python**: When generating Hoon from Python, backticks (`` ` ``) conflict with string formatting. Use `\x60` as the Python-safe way to emit a backtick character in generated Hoon code. In bash, single-quoted strings (`'...'`) pass backticks through safely with no escaping needed.
10. **Wing resolution on expressions: use `:` not `.`**: The dot `.` syntax (`face.subject-path`) resolves wings by walking the **subject tree by face name**. It does **not** work on arbitrary expression results. To extract a wing from the result of an expression, use the `wing:expression` (colon) form:

```hoon
::  WRONG — syntax error: +. cannot follow an arbitrary expression
+.;;(some-type value)

::  CORRECT — evaluate the cast, then take the tail
+:;;(some-type value)

::  Same distinction for named faces
dime.;;(literal-value:ast datum)   ::  WRONG
dime:;;(literal-value:ast datum)   ::  CORRECT
```

This applies any time you want to access a wing (`+`, `-`, `p`, `q`, a face name, etc.) from the result of a gate call, cast, or other expression — always use `:` in that position.

11. lark and wing notation on arm execution

```hoon
::  WRONG — syntax error: +. cannot follow an arm application ()
+.(apply-resolved-scalar (~(got by rs) sname) [%indexed-row key.row data.row])

::  CORRECT — use colon : on parens () not dot .
+:(apply-resolved-scalar (~(got by rs) sname) [%indexed-row key.row data.row])
```

## Fast Lookups

### Arithmetic

```hoon
(add a b)    ::  Addition
(sub a b)    ::  Subtraction
(mul a b)    ::  Multiplication
(div a b)    ::  Division
(mod a b)    ::  Modulo
(pow a b)    ::  Exponentiation
```

### Boolean Logic

```hoon
&(a b)       ::  AND (pam)
|(a b)       ::  OR (bar)
!(a)         ::  NOT (zap)
=(a b)       ::  Equality test
```

### Common Runes

```hoon
|=  ::  Gate (function definition)
|-  ::  Trap Kick (create trap and immediately run)
?:  ::  If-then-else
=/  ::  Pin value to face
=<  ::  Compose with subject on right
=>  ::  Compose with subject on left
^-  ::  Type assertion
%+  ::  Call gate with two arguments
%-  ::  Call gate with one argument
```

## Resources

- [Hoon Rune Reference](https://docs.urbit.org/hoon/rune)
- [Hoon Standard Library](https://docs.urbit.org/hoon/stdlib)
- [Molds (Types)](https://docs.urbit.org/build-on-urbit/hoon-school/e-types)
