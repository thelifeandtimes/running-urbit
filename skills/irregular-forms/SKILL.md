---
name: irregular-forms
description: Master Hoon's irregular syntax - concise syntactic sugar for common patterns including cell construction, function calls, and list operations. Use when reading existing code, writing idiomatic Hoon, making code more readable, or understanding syntactic shortcuts.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen

---

# Irregular Forms Skill

Master Hoon's irregular syntax - concise syntactic sugar for common patterns. Use when reading existing code, writing idiomatic Hoon, or making code more readable through appropriate use of shortcuts.

## Overview

Irregular forms are syntactic shortcuts for frequently-used rune patterns. While every irregular form has a regular rune equivalent, idiomatic Hoon uses irregular forms for common operations to improve readability.

## Learning Objectives

1. Recognize all irregular forms in existing code
2. Know when to use irregular vs regular syntax
3. Master common irregular patterns
4. Understand which runes have irregular forms
5. Write idiomatic, readable Hoon

## 1. When to Use Irregular Forms

### Guidelines

**Use irregular forms for**:
- Common operations (function calls, lists, cell construction)
- Simple expressions
- Established conventions

**Use regular (tall) forms for**:
- Complex nested logic
- Multi-line expressions
- When clarity is more important than brevity

### Example

```hoon
::  ✓ Good: Irregular for simple operations
=/  point  [x=5 y=10]
=/  sum    (add x.point y.point)

::  ✓ Good: Regular for complex logic
?:  %+  gth
      (lent (trip input))
    max-length
  (handle-long-input input)
(process-normal input)

::  ✗ Too irregular (hard to read)
?:(%+(gth (lent (trip input)) max-length) (handle-long-input input) (process-normal input))
```

## 2. Cell Construction

### Pair `:-` → `[a b]`

```hoon
::  Regular
:-  'hello'
'world'

::  Irregular
['hello' 'world']

::  All equivalent
['hello' 'world']
:-(hello' 'world')
:-('hello' 'world')
```

### Inverted Pair `:_` → No Irregular

```hoon
::  Regular only
:_  this
cards

::  No irregular form exists
```

### N-tuple `:*` → `[a b c ...]`

```hoon
::  Regular
:*  1
    2
    3
==

::  Irregular
[1 2 3]

::  Triple :+ also uses []
:+(1 2 3)   ::  Regular wide
[1 2 3]     ::  Irregular (same as :*)
```

### Null-Terminated List `:~` → `~[...]`

```hoon
::  Regular
:~  1
    2
    3
==

::  Irregular
~[1 2 3]

::  All equivalent
~[1 2 3]
:~(1 2 3)
:~  1
    2
    3
==
```

## 3. Function Calls

### Basic Call `%-` → `(func arg)`

```hoon
::  Regular
%-  add
[2 3]

::  Irregular
(add 2 3)

::  With 1 argument
%-  double
5
::  Irregular
(double 5)
```

### Multi-Argument Calls

```hoon
::  2 arguments: %+
%+  add
  2
3
::  Irregular
(add 2 3)

::  3 arguments: %^
%^  function
  arg-1
  arg-2
arg-3
::  Irregular
(function arg-1 arg-2 arg-3)

::  N arguments: %:
%:  function
  arg-1
  arg-2
  arg-3
  arg-4
==
::  Irregular
(function arg-1 arg-2 arg-3 arg-4)
```

### Pulling Arm `%~` → No Simple Irregular

```hoon
::  Regular
%~  get  by  my-map

::  Irregular for common pattern
~(get by my-map)

::  Usage
(~(get by my-map) key)
```

## 4. Type Operations

### Cast `^-` → No Irregular

```hoon
::  Regular only
^-  @ud
42

::  No irregular form
```

### Name Type `^=` → `name=value`

```hoon
::  Regular
^=  x
5

::  Irregular (most common!)
x=5

::  In structures
[x=5 y=10]
::  vs
:*  ^=(x 5)
    ^=(y 10)
==
```

### Bunt `^*` → `*type`

```hoon
::  Regular
^*  @ud

::  Irregular
*@ud

::  Examples
*@ud        ::  0
*@t         ::  ''
*(list @)   ::  ~
*[@ @]      ::  [0 0]
```

## 5. Conditionals

### If-Then-Else `?:` → No Irregular

```hoon
::  Wide form only
?:(test true-branch false-branch)

::  Tall form
?:  test
  true-branch
false-branch

::  No special irregular
```

## 6. Equality and Comparison

### Equality `.=` → `=(a b)`

```hoon
::  Regular
.=  5
10

::  Irregular (most common!)
=(5 10)

::  Usage
?:  =(x 0)
  'zero'
'not zero'
```

### Increment `.+` → `+(n)`

```hoon
::  Regular
.+  5

::  Irregular
+(5)

::  Common usage
+(x)       ::  Increment x
+(+(x))    ::  Increment twice
```

## 7. Subject Modification

### Bind `=/` → No Irregular

```hoon
::  Regular only
=/  x  5
code

::  No irregular form
```

### Modify `=.` → No Irregular

```hoon
::  Regular only
=.  x.point  20
point

::  No irregular form
```

### Wing Modification `%=` → `wing(face value, ...)`

```hoon
::  Regular
%=  point
  x  20
  y  30
==

::  Irregular (most common!)
point(x 20, y 30)

::  Single modification
point(x 20)

::  Usage
=/  moved  point(x (add x.point 10))
```

### Recursion with Changes `$` → `$(face value, ...)`

```hoon
::  Regular
%=  $
  counter  (dec counter)
  sum      (add sum counter)
==

::  Irregular (most common!)
$(counter (dec counter), sum (add sum counter))

::  Single change
$(counter (dec counter))
```

## 8. Core Construction

### Gate `|=` → No Irregular

```hoon
::  Regular only
|=  n=@ud
(mul n 2)

::  No irregular form
```

### Core `|%` → No Irregular

```hoon
::  Regular only
|%
++  func-1  ...
++  func-2  ...
--

::  No irregular form
```

## 9. Unit (Maybe) Operations

### Some Unit `[~ value]` → `` `value ``

```hoon
::  Regular
[~ 42]

::  Irregular
`42

::  Type casting
`(unit @ud)`42
::  is
^-  (unit @ud)
[~ 42]
```

### None Unit `~` → `~`

```hoon
::  Already the simplest form
~

::  Typed none
`(unit @ud)`~
::  is
^-  (unit @ud)
~
```

## 10. Term (Constant) Syntax

### Term Constant `%term` → Already Irregular

```hoon
::  The % form IS irregular
%hello
%my-constant
%foo-bar

::  Regular form rarely used
```

## 11. Text and Atoms

### Cord (Text) `'...'` → Already Irregular

```hoon
::  Already irregular
'hello'
'hello, world'

::  Literal @t atom
```

### Tape `"..."` → Already Irregular

```hoon
::  Already irregular (list of @t)
"hello"
"hello, world"

::  Equivalent to
~['h' 'e' 'l' 'l' 'o']
```

### Hexadecimal `0x...` → Already Irregular

```hoon
::  Hexadecimal @ux
0x2a        ::  42 in hex
0xff00      ::  65280

::  Regular cast would be
`@ux`42     ::  0x2a
```

### Binary `0b...` → Already Irregular

```hoon
::  Binary @ub
0b101010    ::  42 in binary
0b1111      ::  15

::  Regular cast
`@ub`42     ::  0b101010
```

## 12. Loobean (Boolean)

### Yes `%.y` → Already Irregular

```hoon
::  Yes/true
%.y

::  Equivalent to @f atom 0
```

### No `%.n` → Already Irregular

```hoon
::  No/false
%.n

::  Equivalent to @f atom 1
```

## 13. Common Patterns

### Pattern 1: List Construction

```hoon
::  Empty list
~

::  List with elements
~[1 2 3 4 5]

::  Nested lists
~[~[1 2] ~[3 4]]

::  List of pairs
~[[%a 1] [%b 2] [%c 3]]
```

### Pattern 2: Function Call Chain

```hoon
::  Nested calls
(add (mul 2 3) (sub 10 5))

::  vs. regular
%+  add
  (mul 2 3)
(sub 10 5)
```

### Pattern 3: Structure with Names

```hoon
::  Named tuple
[x=5 y=10 z=15]

::  vs. regular
:*  x=5
    y=10
    z=15
==
```

### Pattern 4: Conditional with Equality

```hoon
::  Common pattern
?:  =(status %active)
  'running'
'stopped'

::  All regular
?:  .=(status %active)
  'running'
'stopped'
```

### Pattern 5: Update Multiple Fields

```hoon
::  Update structure
=/  point  [x=5 y=10 z=15]
point(x 20, z 30)

::  vs. regular
%=  point
  x  20
  z  30
==
```

### Pattern 6: Recursion

```hoon
::  Common tail recursion
|-
?~  items
  acc
$(items t.items, acc (add i.items acc))

::  vs. all regular
|-
?~  items
  acc
%=  $
  items  t.items
  acc    (add i.items acc)
==
```

### Pattern 7: Map/Set Operations

```hoon
::  Using maps
=/  my-map  (my ~[[%a 1] [%b 2]])
(~(get by my-map) %a)
(~(put by my-map) %c 3)

::  Using sets
=/  my-set  (silt ~[1 2 3])
(~(has in my-set) 2)
(~(put in my-set) 4)
```

## 14. Anti-Patterns (Don't Overuse)

### Too Much Nesting

```hoon
::  ✗ Bad: Hard to read
(add (mul (sub 10 5) (div 20 4)) (mod 15 7))

::  ✓ Better: Break it up
=/  difference  (sub 10 5)
=/  quotient    (div 20 4)
=/  product     (mul difference quotient)
=/  remainder   (mod 15 7)
(add product remainder)
```

### Unclear Structure

```hoon
::  ✗ Bad: What are these values?
[42 'Alice' %.y 100]

::  ✓ Better: Named fields
[id=42 name='Alice' active=%.y balance=100]
```

### Excessive Irregularity in Complex Code

```hoon
::  ✗ Bad: Complex logic in irregular form
?:(%+((gth(lent(trip input)))max-length)(handle(input))(process(input)))

::  ✓ Better: Use regular form for clarity
?:  %+  gth
      (lent (trip input))
    max-length
  (handle input)
(process input)
```

## 15. Complete Irregular Form Reference

| Regular | Irregular | Example |
|---------|-----------|---------|
| `:-` | `[a b]` | `[5 10]` |
| `:*` | `[a b c ...]` | `[1 2 3]` |
| `:~` | `~[...]` | `~[1 2 3]` |
| `%-` | `(func arg)` | `(add 2 3)` |
| `.=` | `=(a b)` | `=(x 0)` |
| `.+` | `+(n)` | `+(5)` |
| `^=` | `name=value` | `x=5` |
| `^*` | `*type` | `*@ud` |
| `%=` | `wing(a x, b y)` | `point(x 10)` |
| `$` | `$(a x, b y)` | `$(n (dec n))` |
| `[~ value]` | `` `value `` | `` `42 `` |
| N/A | `%term` | `%hello` |
| N/A | `'text'` | `'hello'` |
| N/A | `"tape"` | `"hello"` |
| N/A | `0x...` | `0x2a` |
| N/A | `0b...` | `0b101010` |
| N/A | `%.y` `%.n` | `%.y` |
| `%~` | `~(arm core sample)` | `~(get by map)` |

## 16. Reading Code with Irregular Forms

### Strategy

1. **Recognize patterns**: `[a b]`, `(func arg)`, `=(a b)`
2. **Know expansions**: Mentally expand to regular form
3. **Understand nesting**: Track parentheses and brackets
4. **Check types**: Irregular forms often imply types

### Example Code Walk-Through

```hoon
=/  users  ~[[id=1 name='Alice'] [id=2 name='Bob']]
=/  user-map  (my users)
=/  alice  (~(get by user-map) 1)
?~  alice
  'User not found'
(cat 3 'Hello, ' name.u.alice)
```

**Expansion**:
```hoon
=/  users
  :~  :*  ^=(id 1)
          ^=(name 'Alice')
      ==
      :*  ^=(id 2)
          ^=(name 'Bob')
      ==
  ==
=/  user-map  (my users)
=/  alice
  %-  %~(get by user-map)
  1
?~  alice
  'User not found'
%-  cat
:*  3
    'Hello, '
    name.u.alice
==
```

## 17. Best Practices

### 1. Use Irregular for Common Operations

```hoon
::  ✓ Idiomatic
=/  point  [x=5 y=10]
=/  sum    (add x y)
?:  =(sum 15)
  'correct'
'wrong'
```

### 2. Regular for Complex Expressions

```hoon
::  ✓ Clear
?:  %+  gte
      (lent (trip input))
    minimum-length
  (process-input input)
(error 'Input too short')
```

### 3. Consistent Style

```hoon
::  ✓ Consistent
=/  a  10
=/  b  20
=/  c  30

::  ✗ Inconsistent
=/  a  10
=/  b
  20
=/  c  30
```

### 4. Named Fields in Structures

```hoon
::  ✓ Descriptive
[id=42 name='Alice' age=30]

::  ✗ Unclear
[42 'Alice' 30]
```

### 5. Break Up Long Irregular Forms

```hoon
::  ✗ Too long
(add (mul (sub (div 100 5) 10) 3) (mod 25 7))

::  ✓ Readable
=/  quotient    (div 100 5)
=/  difference  (sub quotient 10)
=/  product     (mul difference 3)
=/  remainder   (mod 25 7)
(add product remainder)
```

## Resources

- [Irregular Forms Reference](https://docs.urbit.org/hoon/irregular) - Complete list
- [Hoon Style Guide](https://docs.urbit.org/hoon/style) - When to use irregular
- [Hoon Syntax](https://docs.urbit.org/build-on-urbit/hoon-school/b-syntax) - Syntax overview

## Summary

Irregular forms in Hoon:
1. **Syntactic sugar** for common operations
2. **Improve readability** when used appropriately
3. **Have regular equivalents** (can always expand)
4. **Most common**: `[a b]`, `(func arg)`, `=(a b)`, `+(n)`, `name=value`
5. **Use wisely**: Irregular for simple, regular for complex

Mastering irregular forms enables reading and writing idiomatic Hoon code while maintaining clarity.
