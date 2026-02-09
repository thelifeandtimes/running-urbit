---
name: hoon-style-guide
description: Comprehensive style guide for writing clean, idiomatic, and maintainable Hoon code following community conventions including naming, formatting, documentation, and idiomatic patterns. Use when writing new code, reviewing code, establishing team standards, or ensuring code quality.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Hoon Style Guide Skill

Comprehensive style guide for writing clean, idiomatic, and maintainable Hoon code following community conventions. Use when writing new code, reviewing code, or establishing team standards.

## Overview

This guide covers naming conventions, code organization, formatting, documentation practices, and idiomatic patterns that make Hoon code readable and maintainable.

## Learning Objectives

1. Follow Hoon naming conventions
2. Format code for readability
3. Write effective comments and documentation
4. Organize code into coherent structures
5. Apply idiomatic Hoon patterns
6. Avoid common anti-patterns

## 1. Naming Conventions

### Arm Names (`++`)

**Use lowercase with hyphens**:
```hoon
::  ✓ Good
++  parse-input
++  validate-user
++  get-current-time

::  ✗ Bad
++  parseInput      :: camelCase
++  ParseInput      :: PascalCase
++  parse_input     :: snake_case
```

### Type Names (`+$`)

**Use lowercase with hyphens**:
```hoon
::  ✓ Good
+$  user-profile
+$  api-request
+$  connection-state

::  ✗ Bad
+$  UserProfile    :: PascalCase
+$  user_profile   :: snake_case
```

### Variable Names

**Use lowercase with hyphens**:
```hoon
::  ✓ Good
=/  user-id  42
=/  max-count  100
=/  error-message  'Failed'

::  ✗ Bad
=/  userId  42
=/  MAX_COUNT  100
```

### Face Names in Structures

**Short, descriptive names**:
```hoon
::  ✓ Good
+$  user
  $:  id=@ud
      name=@t
      email=@t
      created-at=@da
  ==

::  ✗ Bad: Too verbose
+$  user
  $:  user-id=@ud
      user-name=@t
      user-email=@t
  ==
```

### Term Constants

**Use lowercase with hyphens after %**:
```hoon
::  ✓ Good
%connected
%user-logged-in
%api-error

::  ✗ Bad
%Connected
%USER_LOGGED_IN
```

### Abbreviations

**Avoid unless very common**:
```hoon
::  ✓ Good
++  http-request
++  json-parser
++  url-decoder

::  ✓ Acceptable (very common)
++  xml-parse
++  id-generator

::  ✗ Bad (unclear)
++  req-hndlr
++  usr-mgmt
```

## 2. Code Formatting

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

### Tall Form Alignment

**Align children under parent**:
```hoon
::  ✓ Good
?:  condition
  true-branch
false-branch

=/  value
  %+  function
    arg-1
  arg-2

::  ✗ Bad
?:  condition
true-branch
false-branch
```

### Wide Form Usage

**Use for simple expressions**:
```hoon
::  ✓ Good: Simple operations
=/  sum  (add a b)
=/  doubled  (mul n 2)
?:(=(x 0) 'zero' 'non-zero')

::  ✓ Good: Complex logic uses tall
?:  %+  gte
      (lent input)
    max-length
  (handle-long input)
(process-normal input)
```

### Blank Lines

**Separate logical sections**:
```hoon
|%
++  process-request
  |=  request=http-request
  ^-  http-response
  ::  Validate input
  =/  validated  (validate request)
  ?~  validated
    (error-response 'Invalid request')

  ::  Process data
  =/  result  (process u.validated)

  ::  Build response
  (success-response result)
--
```

### Line Length

**Aim for maximum of 80 characters**:
```hoon
::  ✓ Good: Wrap long lines
=/  very-long-computation
  %+  combine-results
    %+  first-complex-operation
      input-data
    threshold
  default-value

::  ✗ Bad: Too long
=/  very-long-computation  (combine-results (first-complex-operation input-data threshold) default-value)
```

## 3. Comments and Documentation

### File Headers

**Document purpose and structure**:
```hoon
::  User Management Library
::
::  Provides functions for creating, updating, and querying user data.
::  Implements validation, password hashing, and role-based access.
::
::  Usage:
::    =/  user  (create-user 'alice@example.com' 'password')
::    =/  valid  (validate-credentials user credentials)
::
|%
...
--
```

### Arm Documentation

**Describe purpose, parameters, and return value**:
```hoon
::  Parse an HTTP request into structured data
::
::  Arguments:
::    raw-request: Raw HTTP request as cord
::
::  Returns:
::    unit of parsed request, ~ if invalid
::
++  parse-http-request
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

**Use `::` for documentation, `::  Note:` for warnings**:
```hoon
::  Calculate user reputation score
::  Note: This is an expensive operation, use sparingly
++  calculate-reputation
  |=  user-id=@ud
  ...
```

### Section Comments

**Organize related code**:
```hoon
|%
::  +|  Validation Functions
::
++  validate-email
  ...
++  validate-password
  ...

::  +|  Database Operations
::
++  save-user
  ...
++  load-user
  ...
--
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

### Arm Ordering

**Public before private, simple before complex**:
```hoon
|%
::  Simple getters
++  get-id
  |=(user=user id.user)
++  get-name
  |=(user=user name.user)

::  Complex operations
++  create-user
  |=  [name=@t email=@t]
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

### Pattern 1: Safe Operations

```hoon
::  ✓ Good: Return unit for fallible operations
++  safe-head
  |*  items=(list)
  ^-  (unit _?>(?=(^ items) i.items))
  ?~  items  ~
  `i.items

::  ✗ Bad: Crash on empty
++  unsafe-head
  |*  items=(list)
  ?>  ?=(^ items)
  i.items
```

### Pattern 2: Tail Recursion

```hoon
::  ✓ Good: Tail-recursive with accumulator
++  sum-list
  |=  items=(list @ud)
  ^-  @ud
  =/  acc  0
  |-
  ?~  items  acc
  $(items t.items, acc (add i.items acc))

::  ✗ Bad: Non-tail-recursive
++  sum-list-slow
  |=  items=(list @ud)
  ?~  items  0
  (add i.items $(items t.items))
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

### Pattern 4: Error Handling

```hoon
::  ✓ Good: Return result type
+$  result
  $%  [%ok value=@t]
      [%err message=@t]
  ==

++  parse-number
  |=  input=@t
  ^-  result
  =/  parsed  (rush input dem)
  ?~  parsed
    [%err 'Invalid number']
  [%ok (scot %ud u.parsed)]

::  ✗ Bad: Crash on error
++  parse-number-unsafe
  |=  input=@t
  (rash input dem)  ::  Crashes if invalid
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

### Anti-Pattern 2: Deep Nesting

```hoon
::  ✗ Bad: Deep nesting
++  process
  |=  data=@t
  =/  validated  (validate data)
  ?~  validated
    ~
  =/  parsed  (parse u.validated)
  ?~  parsed
    ~
  =/  processed  (process-data u.parsed)
  ?~  processed
    ~
  `u.processed

::  ✓ Good: Early returns
++  process
  |=  data=@t
  =/  validated  (validate data)
  ?~  validated  ~
  =/  parsed  (parse u.validated)
  ?~  parsed  ~
  =/  processed  (process-data u.parsed)
  ?~  processed  ~
  `u.processed
```

### Anti-Pattern 3: Overly Generic Names

```hoon
::  ✗ Bad
++  process
  |=  data=@t
  =/  result  (do-stuff data)
  result

::  ✓ Good
++  parse-json
  |=  json-text=@t
  =/  parsed  (parse json-text)
  parsed
```

### Anti-Pattern 4: Long Functions

```hoon
::  ✗ Bad: 100+ line function
++  handle-request
  |=  request=http-request
  ::  Validate (20 lines)
  ::  Parse (30 lines)
  ::  Process (40 lines)
  ::  Format (20 lines)
  ...

::  ✓ Good: Decomposed
++  handle-request
  |=  request=http-request
  =/  validated  (validate-request request)
  ?~  validated  (error-response 'Invalid')
  =/  parsed  (parse-request u.validated)
  =/  result  (process-request parsed)
  (format-response result)
```

### Anti-Pattern 5: Inconsistent Naming

```hoon
::  ✗ Bad: Mixed conventions
++  getUser      :: camelCase
++  save-user    :: kebab-case
++  Delete_User  :: snake_case with caps

::  ✓ Good: Consistent
++  get-user
++  save-user
++  delete-user
```

## 7. Testing and Examples

### Provide Examples

```hoon
::  ✓ Good: Include usage examples
::
::  Example:
::    =/  user  (create-user 'Alice' 'alice@example.com')
::    =/  saved  (save-user user)
::    (get-user id.user)
::
++  create-user
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

```hoon
::  ✓ Good: Use jetted stdlib functions
(turn items |=(n=@ud (mul n 2)))

::  ✗ Bad: Reinvent recursion
|-  ^-  (list @ud)
?~  items  ~
[(mul i.items 2) $(items t.items)]
```

## 9. Git and Version Control

### Commit Messages

```
feat: add user authentication system

Implements:
- Password hashing with bcrypt
- Session management
- Role-based access control
```

### File Headers with Authorship

```hoon
::  User Authentication Library
::  Author: ~sampel-palnet
::  Created: 2024-01-15
::  License: MIT
::
```

## 10. Hoon-Specific Conventions

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

## Resources

- [Official Style Guide](https://docs.urbit.org/language/hoon/style) - Urbit style guide
- [Community Examples](https://github.com/urbit/urbit/tree/master/pkg) - Real-world code
- [Code Review Guide](https://developers.urbit.org/guides/additional/code-review) - Review checklist

## Summary

Hoon style guide emphasizes:
1. **Kebab-case naming** for all identifiers
2. **Clear documentation** with examples
3. **Logical organization** from general to specific
4. **Idiomatic patterns** for common tasks
5. **Performance awareness** in complex code
6. **Consistency** across the codebase

Following these conventions makes code readable, maintainable, and idiomatic within the Urbit ecosystem.
