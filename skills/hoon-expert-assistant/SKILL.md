---
name: hoon-expert-assistant
description: Expert Hoon development assistant for implementing complex features, debugging issues, and writing production-ready Hoon code. Use when needing help with Hoon implementation, type errors, performance optimization, or understanding idiomatic patterns.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Hoon Expert Assistant

Provides expert guidance for writing idiomatic, type-safe, and performant Hoon code following community best practices.

## Core Competencies

### Functional Programming
- Pure functional paradigm: immutability, referential transparency
- Higher-order functions: gates, cores, functional abstractions
- Recursion patterns: tail recursion, mutual recursion
- Type-driven development using molds and type system

### Subject-Oriented Programming
- Subject manipulation and transformation
- Context management with wings, faces, and limbs
- Core construction and door patterns
- Subject-based scoping and resolution

### Rune Expertise
**Core construction**: `|%`, `|_`, `|^`, `|*` (cores, doors, trap cores, wet gates)
**Conditionals**: `?:`, `?-`, `?+`, `?~` (if-then-else, switch, default switch, null check)
**Recursion**: `|-`, `|.` (trap, gate)
**Composition**: `;:`, `=<`, `=>`, `=;` (function chaining and composition)
**Type manipulation**: `^-`, `^+`, `^*`, `^~` (casts, type inference)
**Advanced patterns**: wet gates (`|*`), kelvin versioning, metaprogramming

### Type System
- Aura system: `@`, `@p`, `@t`, `@ud`, `@ux` and custom auras
- Molds: validation, normalization, type construction
- Vases: type-value pairs for dynamic typing
- Type inference and variance
- Generic programming with wet gates

### Standard Library
- **Core utilities**: `++turn`, `++roll`, `++snap`, `++flop`, `++weld`
- **Data structures**: sets (`++in`), maps (`++by`), jugs, mops
- **Text processing**: tapes, cords, knots, formatting (`++scot`, `++scow`)
- **Parsing**: parser combinators, `++so`, `++ne`, custom parsers
- **Cryptography**: hashing, encryption, signature verification
- **JSON**: `++enjs`, `++dejs`, custom encoders/decoders

### Gall Agent Development
- **Lifecycle**: `++on-init`, `++on-save`, `++on-load`
- **State management**: versioned state, migration patterns
- **Subscription model**: `++on-watch`, `++on-leave`, `++on-agent`
- **Poke handling**: `++on-poke`, action processing
- **Effects and cards**: HTTP requests, subscriptions, scries
- **Error handling and recovery**

## Common Patterns

### Type-Safe Casting
```hoon
::  Explicit cast with clear error messages
=/  num=@ud  (slay %ud (scot %ud input))
^-  @ud  num
```

### List Processing
```hoon
::  Efficient single-pass composition
=/  result
  %+  turn
    %+  skim  data
      |=(item ~(has in lookup set))
    process
  sort-with
```

### Gate Definition
```hoon
::  Idiomatic gate with explicit types
++  process-input
  |=(input *)
  ^-  output
  =/  intermediate  (transform input)
  (finalize intermediate)
```

### Core with Battery
```hoon
::  Production-ready core pattern
|%
++  method-a
  |=(input *)
  ^-  output
  (internal-computation input)
--
```

## Critical Syntax Pitfalls

### Number Formatting

Hoon requires dot-separated groups of three digits for any number over 999:

```hoon
::  CORRECT
1.000
844.494
1.000.000

::  WRONG — parser error with no helpful message
1000      ::  Error: {1 4}
844494    ::  Error: {1 6}
1000000   ::  Error: {1 7}
```

The error message (e.g. `{1 52}`) gives only a line/column position with no mention of number formatting. This is one of the most common sources of hard-to-diagnose Hoon errors.

### Backtick Escaping from Python

When generating Hoon code from Python, backtick (`` ` ``) characters conflict with string formatting and f-strings. Use `\x60` as the Python-safe escape:

```python
# Python: generating a Hoon type cast
hoon_code = f"\x60@ud\x60value"  # produces `@ud`value
```

In bash, single-quoted strings pass backticks through safely — no escaping needed:

```bash
# Bash: single-quoted strings are safe
echo '`@ud`value'  # backticks are literal, no escaping required
```

This is especially relevant when writing Hoon to files for conn.c thread execution.

### Face Names Shadow Molds

Do not give gate arguments or local faces the same name as molds/types used in
casts or return annotations. A face like `=data` shadows the `data` mold, so a
nearby `^-  [data file]` may fail with `-find.$` or resolve differently than
intended. Prefer value faces such as `cur-data=data`, `next-data=data`, or
`acc-data=data` and keep mold names available for type syntax.

```hoon
::  WRONG: the face named data shadows the data mold.
|=  =data
^-  [data file]
[data parent-file]

::  RIGHT: face is distinct, mold remains available.
|=  cur-data=data
^-  [data file]
[cur-data parent-file]
```

## Debugging Type Errors

### Common Issues

**1. Missing type cast**
```hoon
::  Error: nest-fail
=/  num  5
^-  @t  num  ::  @ud doesn't nest in @t

::  Fix: Use conversion function
=/  num  5
(scot %ud num)  ::  Produces @t
```

**2. Mold mismatch**
```hoon
::  Error: Incorrect structure
+$  person  [name=@t age=@ud]
=/  data  [name='alice' height=170]

::  Fix: Match mold exactly
=/  data  [name='alice' age=30]
```

**3. Face name mismatch**
```hoon
::  Error: Wrong face names
+$  coord  [x=@ud y=@ud]
=/  point  [a=5 b=10]

::  Fix: Use correct faces
=/  point  [x=5 y=10]
```

## Performance Optimization

### Anti-Patterns to Avoid

**Repeated traversals**
```hoon
::  Slow: three separate traversals
=/  filtered  (skim data predicate)
=/  mapped  (turn filtered process)
=/  sorted  (sort mapped comparator)

::  Fast: single composed pass
=/  result
  %+  sort
    %+  turn
      (skim data predicate)
    process
  comparator
```

**O(n²) nested loops**
```hoon
::  Slow: nested linear search
=/  matches
  %+  turn  list-a
  |=  item-a=*
  %+  skim  list-b
  |=(item-b=* =(id.item-a id.item-b))

::  Fast: use set for O(1) lookup
=/  set-b  (~(gas in *(set @ud)) (turn list-b |=(item id.item)))
=/  matches
  %+  skim  list-a
  |=(item (~(has in set-b) id.item))
```

**Inefficient accumulation**
```hoon
::  Slow: weld is O(n) each iteration
|-
?~  items  result
$(items t.items, result (weld result ~[i.items]))

::  Fast: accumulate then reverse
|-
?~  items  (flop result)
$(items t.items, result [i.items result])
```

### Use Jets When Possible
```hoon
::  Slow: manual recursion
=/  sum
  |-  ^-  @ud
  ?~  nums  0
  (add i.nums $(nums t.nums))

::  Fast: jet-accelerated stdlib
=/  sum  (roll nums add)
```

## Data Structure Selection

Choose based on operation patterns:

- **Lists**: sequential processing, small datasets
- **Sets**: membership testing, uniqueness
- **Maps**: key-value lookup
- **Mops**: ordered data, range queries
- **Trees**: hierarchical navigation, efficient updates

## Gall Agent Patterns

### State Versioning
```hoon
++  on-save
  |=  =vase
  ^-  +(new-state saved-vase)
  (migrate-state v.u.saved-vase)
```

### Subscription Management
```hoon
++  on-watch
  |=  path=path
  ^-  +(new-state new-watches)
  (add-watch path v.state v.watches)
```

### Poke Processing
```hoon
++  on-poke
  |=  =poke:action
  ^-  +(new-state [new-wires new-effects])
  (process-action poke.poke v.state)
```

## Best Practices

1. **Type Safety First**: Always use explicit type casts (`^-`)
2. **Idiomatic Patterns**: Follow community conventions
3. **Small Functions**: Prefer composable functions over monoliths
4. **Error Handling**: Graceful failures, informative messages
5. **Performance Awareness**: Choose appropriate data structures
6. **Documentation**: Comment complex algorithms and non-obvious patterns
7. **Testing**: Cover edge cases (null values, empty lists)

## Resources

- [Hoon Documentation](https://docs.urbit.org/hoon)
- [Hoon School](https://developers.urbit.org/guides/core/hoon-school)
- [Standard Library](https://docs.urbit.org/hoon/stdlib)
- [Rune Reference](https://docs.urbit.org/hoon/rune)
- [Urbit Examples](https://github.com/urbit/examples)
