---
name: hoon-fundamentals
description: Architectural reference for subject-oriented programming, noun data model, and Hoon-to-Nock compilation. Use when debugging low-level issues, working with subject transformations, understanding compilation semantics, or architecting noun-level operations.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Hoon Fundamentals: Architectural Reference

Deep architectural reference for Hoon's foundational paradigms: subject-oriented programming, noun data model, and compilation to Nock.

## 1. Subject-Oriented Programming

### The Subject

The **subject** is the fundamental context in which all Hoon code executes. Every Hoon expression evaluates in the context of a subject, which is a noun containing all accessible data and code.

**Contrast with traditional paradigms**:
- Traditional languages: Variables exist in nested scopes (invisible, implicit context)
- Hoon: The subject IS the context (explicit, immutable noun, transformable)

### Subject Transformation

Hoon programming is primarily about transforming the subject:

```hoon
::  Start with empty subject
::  Add 'x' to subject
=/  x  5
::  Subject now contains x=5
::  Add 'y' to subject
=/  y  10
::  Subject now contains x=5, y=10
::  Compute using subject
(add x y)  ::  15
```

### Subject Resolution

When you reference a name like `x`, Hoon searches the subject:
1. Check if `x` is a face (named value) in the current subject
2. Search outward through subject layers
3. If not found: compile error (`-find-limb.x`)

## 2. Noun Data Model

### Everything is a Noun

A **noun** is the only data structure in Nock/Hoon:
- Either an **atom** (unsigned integer of any size)
- Or a **cell** (ordered pair of two nouns)

```
noun = atom | [noun noun]
```

### Examples

```hoon
42                  ::  Atom
[1 2]               ::  Cell of two atoms
[1 [2 3]]           ::  Cell: atom and cell
[[1 2] [3 4]]       ::  Cell of two cells
```

### Tree Structure

Cells form binary trees:
```
    [1 [2 3]]
       / \
      1   [2 3]
          / \
         2   3
```

### Addressing with Axis

Every position in a noun tree has an **axis** (tree address):
```
        1
       / \
      2   3
     / \ / \
    4 5 6 7
```

- Axis 1: Root (entire tree)
- Axis 2: Left child
- Axis 3: Right child
- Axis 4: Left-left child
- etc.

```hoon
=/  tree  [[1 2] [3 4]]
+1:tree  ::  [[1 2] [3 4]] (entire tree)
+2:tree  ::  [1 2] (left branch)
+3:tree  ::  [3 4] (right branch)
+4:tree  ::  1 (left-left)
+5:tree  ::  2 (left-right)
```

## 3. From Nouns to Types

### Atoms with Meaning: Auras

An atom is just a number, but we give it **meaning** with an **aura**:

```hoon
42        ::  Just a number
`@ud`42   ::  Unsigned decimal: 42
`@ux`42   ::  Hexadecimal: 0x2a
`@t`42    ::  Text character (ASCII '*')
```

Common auras:
- `@` - Atom (any)
- `@ud` - Unsigned decimal (42)
- `@ux` - Hexadecimal (0x2a)
- `@t` - UTF-8 text ('hello')
- `@p` - Ship name (~sampel-palnet)
- `@da` - Absolute date/time

### Cells with Structure: Molds

A **mold** is a type that validates and normalizes nouns:

```hoon
::  Define a mold
+$  point  [x=@ud y=@ud]

::  Validate a noun
=/  p  [x=5 y=10]
^-  point  p  ::  Type-checks!
```

### Noun Properties

**Homoiconicity**: Code and data have the same structure (both are nouns)

**Serialization**: Any noun can be serialized to/from atoms via `jam`/`cue`

**Network Transfer**: Nouns are the atomic unit of Ames peer-to-peer networking

**State Persistence**: Ship state is a single noun in the loom

## 4. Hoon to Nock Compilation

### Compilation Pipeline

```
Hoon Source Code
     ↓ (parsed)
Abstract Syntax Tree (AST)
     ↓ (compiled)
Nock Code
     ↓ (executed)
Result Noun
```

### Example

```hoon
::  Hoon
(add 2 3)

::  Compiles to Nock (simplified)
[0 4]  ::  Nock opcode: Add atoms at address 4
```

### Compilation Properties

**Determinism**: Same Hoon always compiles to same Nock (frozen compilation semantics)

**Portability**: Any Nock interpreter produces identical results (noun-level determinism)

**Debugging**: Understanding Nock output aids deep issue debugging (Hoon→Nock tracing)

**Performance**: Jet acceleration replaces Nock patterns with native code (100x-1000x speedup)

## 5. Runes: Subject Manipulation

Runes are Hoon's syntax for subject transformation:

### Adding to Subject

```hoon
=/  name  value  ::  Add face 'name' with 'value' to subject
```

### Composing Subject

```hoon
=>  context     ::  Evaluate first child (context), use result as subject for second child (expression)
    expression

=<  expression  ::  Same but reversed (result-first)
    context
```

### Conditionals (Subject-Aware)

```hoon
?:  test
  true-branch   ::  Evaluated with current subject
false-branch    ::  Evaluated with current subject
```

## 6. Functional Purity

### Immutability

All Hoon data is immutable:
```hoon
=/  x  5
::  Cannot mutate x!
::  Must create new value
=/  x  (add x 1)  ::  x is now 6 (new binding in subject)
```

### Referential Transparency

Same inputs always produce same outputs:
```hoon
++  double
  |=  n=@ud
  (mul 2 n)

(double 5)  ::  Always 10, deterministic
```

### No Side Effects

Pure computation only - effects happen via Gall cards (not in pure Hoon):
```hoon
::  Pure function
++  compute
  |=  x=@ud
  (mul x x)

::  Effect (in Gall agent)
++  on-poke
  :_  this
  ~[[%give %fact ~[/updates] %json !>([%result (compute 5)])]]
```

## 7. Practical Implications

### Debugging Strategy

**Print subject**: Use `!>` to inspect what's in scope
```hoon
!>(.)  ::  Vase of entire subject
```

**Trace subject transformations**: Follow `=/`, `=>`, `=<` runes to understand context flow

**Understand resolution**: Know how names resolve in subject (outward search through layers)

### Code Organization

Structure code around subject manipulation:
```hoon
=>  |%                ::  Build library core
    ++  helper-1  ...
    ++  helper-2  ...
    --
=<  (main-logic)      ::  Use library
|%
++  main-logic
  ::  Can access helper-1, helper-2 from subject
  ...
--
```

### Type-Driven Development

1. Design noun structure (data model)
2. Create molds (types)
3. Write functions operating on typed nouns
4. Compiler enforces correctness

## 8. Common Patterns

### Building Context

```hoon
::  Pattern: Layer context progressively
=>  [constant-1=100 constant-2=200]
=>  |%
    ++  helper  |=(x=@ (add x constant-1))
    --
=<  (main-program)
|%
++  main-program
  (helper constant-2)  ::  300
--
```

### Core Construction

```hoon
::  Pattern: Reusable library
|%
++  add-ten  |=(x=@ (add x 10))
++  mul-two  |=(x=@ (mul x 2))
--
```

## 9. Advanced Concepts

### Subject as First-Class Value

The subject itself is a noun that can be captured:
```hoon
.  ::  The entire subject (axis 1)
```

### Computation = Subject Transformation

Every Hoon program:
1. Starts with a subject (context)
2. Transforms the subject (computation)
3. Produces a new subject or extracts value from it

### Wings, Limbs, and Faces

**Face**: A name bound to a value (`x=5`)

**Limb**: An axis or face in the subject

**Wing**: A path through the subject (`a.b.c`)

## Core Architectural Principles

1. **Subject-oriented** programming is Hoon's core paradigm (explicit context)
2. **Nouns** are the only data structure (atoms or cells, forming binary trees)
3. **Auras** give meaning to atoms (@ud, @ux, @p, @t, etc.)
4. **Molds** give structure and validation to nouns
5. **Runes** manipulate the subject explicitly
6. **Compilation** to Nock ensures determinism and portability
7. **Immutability** and **purity** are enforced (no mutation, no side effects)
8. **Understanding the subject** is the key architectural mental model

## Resources

- [Hoon School](https://developers.urbit.org/guides/core/hoon-school)
- [Subject-Oriented Programming](https://docs.urbit.org/build-on-urbit/hoon-school/o-subject)
- [Noun Documentation](https://docs.urbit.org/build-on-urbit/hoon-school/b-syntax)
- [Nock Specification](https://docs.urbit.org/nock/specification)
