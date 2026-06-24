---
name: hoon-style-guide
description: Comprehensive style guide for writing clean, idiomatic, and maintainable Hoon code following community conventions including naming, formatting, documentation, and idiomatic patterns. Use when writing new code, reviewing code, establishing team standards, or ensuring code quality.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Hoon Style Guide Skill

Comprehensive style guide for writing clean, idiomatic, and maintainable Hoon code following desired conventions. Use when writing new code or reviewing code.

## Overview

This guide covers naming conventions, code organization, formatting, documentation practices, and idiomatic patterns that make Hoon code readable and maintainable.

## Learning Objectives

1. Follow Hoon naming conventions
2. Format code for readability
3. Write effective comments and documentation
4. Organize code into coherent structures
5. Apply idiomatic Hoon patterns
6. Avoid common anti-patterns

Syntax and compiler-failure details belong in the companion skills:
`hoon-basics` for parseability and rune usage, `type-system` for casts and
molds, `data-structures` for container APIs, and
`debugging-specialist-assistant` for compiler/runtime failures.

## 1. Naming Conventions

### faces

1. arm names `++`
2. type names `+$`
3. named nouns '=/'

**Use lowercase with hyphens**:
```hoon
::  ✓ Good
++  parse-input
++  validate-user
++  get-current-time
+$  user-profile
=/  user-id  42

::  ✗ Bad, will not build
++  parseInput      :: camelCase
++  ParseInput      :: PascalCase
++  parse_input     :: snake_case
+$  UserProfile    :: PascalCase
+$  user_profile   :: snake_case
=/  userId  42
```

## 2. Code Formatting

### Line Length

**maximum of 80 characters**:
```hoon
::  ✓ Good: Wrap and properly indent long lines
=/  very-long-computation
  %+  combine-results  %+  first-complex-operation  input-data
                                                    threshold
                       default-value

::  ✗ Bad: Too long
=/  very-long-computation  (combine-results (first-complex-operation input-data threshold) default-value)
```

**when wide form exceeds 80 characters**
```hoon
::  ✗ Bad: wide format too long
~|("resolve selected-cte-column: no rows in cte {<cte.selected>}" !!) 

::  ✓ Good: use tall format and align rune parameters
~|  "resolve selected-cte-column: no rows in cte {<cte.selected>}"
    !!

::  ✓ Good: continue message on next ling by adding dot after closing quote
~|  "resolve selected-cte-column: no rows in cte ".
    "and tape must be broken up into multiple lines {<cte.selected>}"
    !!
```

### Indentation

**Use 2 spaces** (not tabs):
```hoon
|%
++  example
  |=  input=@t
  ^-  @ud
  =/  processed  (parse input)
  ?~  processed
    0
  u.processed
--
```

### Wide Form Usage

**Use for simple expressions**:
```hoon
::  ✓ Good: Simple operations
=/  sum  (add a b)
=/  doubled  (mul n 2)
?:(=(x 0) 'zero' 'non-zero')

::  ✓ Good
=/  target-val  (apply-scalar data-row +.target-ps)

::  ✗ Bad
?:  condition
=/  target-val  %+  apply-scalar  data-row
                                  +.target-ps
```

### Tall Form Alignment

**Align children under parent**:
```hoon
::  ✓ Good
?:  condition
  true-branch
false-branch

=/  value
  %+  function  arg-1
                arg-2

::  ✗ Bad
?:  condition
true-branch
false-branch
```

### Tall Form Cell Alignment

align all cell items to the same column
```hoon
::  ✓ Good
:+  %fn  type.expr
          |=  =data-row
          ^-  dime
          ?-  number-system
              ::
              %rd  :-  number-system
                      (~(abs rd:math [%z .~1e-15]) +:(f.expr data-row))
              ::
              %sd  [number-system (sun:si (abs:si +:(f.expr data-row)))]
              ::
              %ud  (f.expr data-row)
              ==

::  ✗ Bad
:+  %fn
  type.expr
  |=  =data-row
  ^-  dime
  ?-  number-system
      ::
      %rd  :-  number-system
                (~(abs rd:math [%z .~1e-15]) +:(f.expr data-row))
      ::
      %sd  [number-system (sun:si (abs:si +:(f.expr data-row)))]
      ::
      %ud  (f.expr data-row)
      ==
```


For syntax constraints on wide, tall, bracket, and paren forms, use
`hoon-basics`. This section only covers readability preferences.

## 3. Comments and Documentation

### File Headers

arm and core header blocks gap indented 

**Document purpose and structure**:
```hoon
|%
  ::  User Management Library
  ::
  ::  Provides functions for creating, updating, and querying user data.
  ::  Implements validation, password hashing, and role-based access.
  ::
  ::  Usage:
  ::    =/  user  (create-user 'alice@example.com' 'password')
  ::    =/  valid  (validate-credentials user credentials)
  ::
...
--
```

### Arm Documentation

1. one empty comment line before ++ arm
2. arm description comments gap indented

**Describe purpose**:
```hoon
::
++  parse-http-request
  ::  Parse an HTTP request into structured data
  ::
  ::  Returns:
  ::    unit of parsed request, ~ if invalid
  |=  raw-request=@t
  ^-  (unit http-request)
  ...
```

### Inline Comments

**Explain why, not what**:
```hoon
::  ✓ Good: Explains reasoning
=/  timeout  ~s30
::  30-second timeout prevents hanging on slow connections

::  ✗ Bad: States the obvious
=/  timeout  ~s30
::  Set timeout to 30 seconds
```

## 4. Code Organization

### Core Structure

**Organize from general to specific**:
```hoon
|%
::  +|  Types
::
+$  user  [id=@ud name=@t]
+$  state  [users=(map @ud user)]

::  +|  Constants
::
++  max-users  1.000
++  default-name  'Guest'

::  +|  Public API
::
++  create-user
  ...
++  get-user
  ...

::  +|  Internal Helpers
::
++  validate-name
  ...
++  generate-id
  ...
--
```

### File Organization

**One major component per file**:
```
/lib/user-management.hoon     :: User CRUD operations
/lib/authentication.hoon      :: Auth logic
/lib/validation.hoon          :: Input validation
/sur/types.hoon               :: Shared type definitions
```

## 5. Idiomatic Patterns

### Pattern 1: Safe APIs

Prefer APIs that make failure explicit when absence is expected. Return `unit`
for lookups, parsing, and optional values; reserve crashes for invariant
violations. For container-specific access rules, use `data-structures`.

### Pattern 2: Standard Library Operations

```hoon
::  ✓ Good: use a clear stdlib traversal
(turn items |=(n=@ud (mul n 2)))

::  ✗ Bad: hand-rolled recursion for a simple map
|-  ^-  (list @ud)
?~  items  ~
[(mul i.items 2) $(items t.items)]
```

### Pattern 3: Type Annotations

```hoon
::  ✓ Good: Explicit return types
++  process
  |=  input=@t
  ^-  (unit @ud)
  ...

::  ✗ Bad: Inferred (unclear contract)
++  process
  |=  input=@t
  ...
```

### Pattern 4: Crash Handling

Crashes should include useful context. Use `~|` around known crash points, and
put detailed debugging workflows in `debugging-specialist-assistant`.

```hoon
::  ✗ Bad: known danger of crash
(potential-crash param)

::  ✓ Good: guard with message including data
~|  "failed at potential crash site {<param>}"
    (potential-crash param)
```

### Pattern 5: Default Values

```hoon
::  ✓ Good: Provide defaults
++  get-config
  |=  [key=@tas config=(map @tas @t)]
  ^-  @t
  (~(gut by config) key 'default')

::  ✗ Bad: Force caller to handle ~
++  get-config
  |=  [key=@tas config=(map @tas @t)]
  ^-  (unit @t)
  (~(get by config) key)
```

## 6. Anti-Patterns to Avoid

### Anti-Pattern 1: Magic Numbers

```hoon
::  ✗ Bad
++  check-limit
  |=  count=@ud
  ?:  (gth count 100)
    'too many'
  'ok'

::  ✓ Good: Named constants
++  max-count  100
++  check-limit
  |=  count=@ud
  ?:  (gth count max-count)
    'too many'
  'ok'
```

### Anti-Pattern 2: Inconsistent Naming

All names below build; the anti-pattern is inconsistent vocabulary and
word order, not illegal characters (for those, see §1).

```hoon
::  ✗ Bad: mixed verbs and word order
++  get-user
++  fetch-account   :: 'fetch' where 'get' is used elsewhere
++  user-remove     :: noun-verb; the others are verb-noun

::  ✓ Good: one verb per action, consistent verb-noun order
++  get-user
++  get-account
++  remove-user
```

## 7. Testing and Examples

### Provide Examples

```hoon
::  ✓ Good: Include usage examples
::
++  create-user
  ::  Example:
  ::    =/  user  (create-user 'Alice' 'alice@example.com')
  ::    =/  saved  (save-user user)
  ::    (get-user id.user)
  |=  [name=@t email=@t]
  ...
```

### Write Testable Code

```hoon
::  ✓ Good: Pure function, easy to test
++  calculate-total
  |=  items=(list @ud)
  ^-  @ud
  (roll items add)

::  ✗ Bad: Side effects, hard to test
::  (Gall agents handle effects separately)
```

## 8. Performance Considerations

### Document Complexity

```hoon
::  ✓ Good: Note performance characteristics
::  O(log n) lookup using map
++  find-user
  |=  [id=@ud users=(map @ud user)]
  (~(get by users) id)

::  O(n) linear search - use sparingly
++  find-by-name
  |=  [name=@t users=(map @ud user)]
  %+  find  ~(tap by users)
  |=([id=@ud user=user] =(name.user name))
```

### Prefer Standard Library

Use jetted standard-library functions for common traversals and container
operations. See `data-structures` for the concrete list, set, map, mop, jar,
and jug APIs.

## 9. Hoon-Specific Conventions

### Face Punning

**Use when faces match types**:
```hoon
::  ✓ Good: Faces match field names
+$  user  [id=@ud name=@t email=@t]

++  create-user
  |=  [name=@t email=@t]
  ^-  user
  [id=0 name email]  ::  Faces match
```

### Bunting for Defaults

Use bunting for default initialization when the mold is clear. See
`hoon-basics` and `type-system` for the mechanics of bunts.

```hoon
::  ✓ Good: Use * for defaults
=/  users  *(map @ud user)
=/  count  *@ud

::  ✗ Bad: Explicit zeros
=/  users  `(map @ud user)`~
=/  count  0
```

### Irregular for Common Patterns

```hoon
::  ✓ Good: Use irregular forms
[a b c]
(func arg)
=(x y)
name=value

::  ✗ Bad: Overly regular for simple things
:-  a
:-  b
c
```
