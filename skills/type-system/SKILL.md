---
name: type-system
description: Master Hoon's powerful structural type system including auras, molds, validation, type inference, generics, and variance. Use when designing types, debugging type errors, building robust type-safe code, or working with nest-fail issues and type casting.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Type System Skill

Master Hoon's powerful structural type system including auras, molds, validation, type inference, generics, and variance. Use when designing types, debugging type errors, or building robust type-safe code.

## Overview

Hoon features a structural type system built on nouns, with compile-time type checking, type inference, and runtime validation. This skill covers the full spectrum from basic auras to advanced generic types and variance.

## Learning Objectives

1. Understand Hoon's structural typing philosophy
2. Master auras (atom types) and their conversions
3. Design effective molds (structural types)
4. Use type inference and explicit casts appropriately
5. Handle type errors and nest-fail issues
6. Build generic types and polymorphic functions
7. Understand variance and type nesting rules

## 1. Type System Philosophy

### Structural Typing

Hoon uses **structural typing**: types are determined by structure, not names.

```hoon
::  These are the SAME type structurally
+$  point-a  [x=@ud y=@ud]
+$  point-b  [x=@ud y=@ud]

::  They are interchangeable
=/  p1  ^-  point-a  [x=5 y=10]
=/  p2  ^-  point-b  p1  ::  Works!
```

**Contrast with nominal typing** (C, Java): names matter
```c
struct PointA { int x; int y; };
struct PointB { int x; int y; };
PointA a = {5, 10};
PointB b = a;  // ERROR: different types
```

### Key Principles

1. **Nouns first, types second**: All data is nouns; types validate/normalize
2. **Compile-time checking**: Type errors caught before execution
3. **Runtime normalization**: `^-` cast can transform values
4. **Type inference**: Compiler infers types when possible
5. **Explicit when needed**: Use `^-` for clarity and safety

## 2. Auras (Atom Types)

### What are Auras?

An **aura** gives meaning to an atom (unsigned integer). Same number, different interpretations:

```hoon
42           ::  @ud - Unsigned decimal
0x2a         ::  @ux - Hexadecimal
'*'          ::  @t  - Text (ASCII/UTF-8)
~nec         ::  @p  - Ship name
```

### Aura Hierarchy

Auras form a tree hierarchy. Child auras nest in parent auras:

```
@            (atom - any)
├── @u       (unsigned)
│   ├── @ud  (unsigned decimal)
│   ├── @ux  (unsigned hexadecimal)
│   ├── @uv  (base64)
│   └── @uw  (base64 URL-safe)
├── @s       (signed)
│   ├── @sd  (signed decimal)
│   └── @sx  (signed hexadecimal)
├── @t       (UTF-8 text)
├── @ta      (ASCII text, URL-safe)
├── @tas     (ASCII symbol/term)
├── @p       (ship name)
├── @da      (absolute date/time)
├── @dr      (relative time duration)
├── @rd      (IEEE 754 double)
├── @rs      (IEEE 754 single)
└── @rh      (IEEE 754 half)
```

### Nesting Rules

**More specific auras nest in less specific**:
```hoon
@ud nests in @u    ::  ✓ Decimal is unsigned
@u  nests in @     ::  ✓ Unsigned is atom
@ud nests in @     ::  ✓ Decimal is atom

@t  nests in @     ::  ✓ Text is atom
@ud nests in @t    ::  ✗ FAIL: decimal ≠ text
```

### Aura Conversion

**Lossless conversions** (same bits, different interpretation):
```hoon
`@ux`42       ::  0x2a (42 in hex)
`@t`97        ::  'a' (ASCII 97)
```

**Display conversions** (rendering):
```hoon
(scot %ud 42)    ::  '42' (returns @ta knot, not tape)
(scot %ux 42)    ::  '0x2a'
(scot %p 42)     ::  '~nec'
```

### Common Auras Reference

| Aura | Meaning | Example | Notes |
|------|---------|---------|-------|
| `@` | Atom (any) | `42` | Parent of all auras |
| `@ud` | Unsigned decimal | `42` | Most common numeric type |
| `@ux` | Unsigned hex | `0x2a` | Hexadecimal display |
| `@ub` | Unsigned binary | `0b101010` | Binary display |
| `@uv` | Base64 | `0v2a` | Compact encoding |
| `@uw` | Base64 URL-safe | `0w2a` | URL-safe encoding |
| `@sd` | Signed decimal | `--42` | Negative numbers |
| `@t` | UTF-8 text (cord) | `'hello'` | Atom as string |
| `@ta` | ASCII text | `~.hello` | URL-safe ASCII |
| `@tas` | ASCII symbol | `%hello` | Terms/tags |
| `@p` | Ship name | `~sampel-palnet` | Urbit identity |
| `@q` | Ship name (obfuscated) | Internal | Phonetic encoding |
| `@da` | Absolute date | `~2024.1.15..12.30.00` | Timestamp |
| `@dr` | Relative time | `~s10` | Duration (10 seconds) |
| `@rd` | IEEE double | `.~3.14` | 64-bit float |
| `@rs` | IEEE single | `.3.14` | 32-bit float |
| `@rh` | IEEE half | `.~~3.14` | 16-bit float |
| `@if` | IPv4 address | `.192.168.1.1` | IP address |
| `@is` | IPv6 address | `.0.0.0.0.0.0.0.1` | IPv6 |
| `@f` | Loobean flag | `%.y` / `%.n` | Boolean (yes/no) |

### Loobean (`?` / `@f`)

Special boolean type:
```hoon
%.y  ::  Yes (true) - 0
%.n  ::  No (false) - 1

::  Note: 0 is TRUE in Hoon!
?:  %.y
  'this runs'
'this does not'
```

### Text Types

**Three main text types**:

1. **`@t` (cord)** - UTF-8 atom, efficient:
```hoon
'hello'  ::  Single-quoted
'Hello, world!'
```

2. **`@ta` (knot)** - URL-safe ASCII:
```hoon
~.hello
~.my-url-safe-string
```

3. **`@tas` (term)** - Symbol/tag:
```hoon
%hello
%my-tag
```

4. **`tape`** - List of characters `(list @tD)`, flexible:
```hoon
"hello"  ::  Double-quoted
"Hello, world!"
```

**Conversions**:
```hoon
(trip 'hello')        ::  cord → tape: "hello"
(crip "hello")        ::  tape → cord: 'hello'
(scot %tas %hello)    ::  term → knot: ~.hello
```

## 3. Molds (Structural Types)

### What are Molds?

A **mold** is a type that:
1. **Validates** - Checks if a noun matches structure
2. **Normalizes** - Transforms noun to canonical form
3. **Bunts** - Produces default value

### Basic Molds

#### Atom Molds
```hoon
@          ::  Any atom
@ud        ::  Unsigned decimal
@t         ::  Text
```

#### Cell Molds
```hoon
[@ @]              ::  Pair of atoms
[@ud @t]           ::  Decimal and text
[x=@ud y=@ud]      ::  Named fields (faces)
```

#### Null
```hoon
~          ::  Null (only value: ~)
```

### Complex Molds

#### Tuple Mold (`$:`)
```hoon
+$  point
  $:  x=@ud
      y=@ud
  ==

::  Usage
=/  p  ^-  point  [x=5 y=10]
x.p  ::  5
```

#### Tagged Union (`$%`)
```hoon
+$  color
  $%  [%rgb r=@ud g=@ud b=@ud]
      [%hex value=@ux]
      [%named name=@tas]
  ==

::  Usage
=/  c  ^-  color  [%rgb r=255 g=0 b=0]
?-  -.c
  %rgb    "RGB color"
  %hex    "Hex color"
  %named  "Named color"
==
```

#### Untagged Union (`$?`)
```hoon
+$  primary-color
  $?  %red
      %green
      %blue
  ==

::  Usage
=/  c  ^-  primary-color  %red
```

#### Default Molds (`$@`)
```hoon
+$  maybe-number
  $@  ~               ::  Atom case (null)
  [value=@ud]         ::  Cell case

::  Examples
^-  maybe-number  ~           ::  Atom → ~
^-  maybe-number  [value=42]  ::  Cell → [value=42]
```

### Standard Library Molds

#### `unit` - Maybe Type
```hoon
+$  unit  [item]
  $@(~ [~ u=item])

::  Examples
`(unit @ud)`~         ::  None
`(unit @ud)`[~ 42]    ::  Some 42

::  Irregular syntax
~                      ::  None
`42                    ::  Some 42
```

#### `list` - Linked List
```hoon
+$  list  [item]
  $@(~ [i=item t=(list item)])

::  Examples
~[1 2 3]              ::  List
~                     ::  Empty list

::  Full form
[i=1 t=[i=2 t=[i=3 t=~]]]
```

#### `set` - Ordered Set
```hoon
+$  set  [item]
  (tree item)

::  Examples
(sy ~[1 2 3])         ::  Set of @ud
```

#### `map` - Key-Value Map
```hoon
+$  map  [key value]
  (tree [key value])

::  Examples
(my ~[[%a 1] [%b 2]])  ::  Map @tas → @ud
```

#### `tree` - Binary Tree
```hoon
+$  tree  [item]
  $@(~ [n=item l=(tree item) r=(tree item)])
```

### Custom Mold Patterns

#### Validated Type
```hoon
+$  positive
  @ud

++  make-positive
  |=  n=@ud
  ^-  positive
  ?>  (gth n 0)
  n
```

#### Recursive Type
```hoon
+$  json
  $@  ~
  $%  [%s p=@t]
      [%n p=@ta]
      [%b p=?]
      [%a p=(list json)]
      [%o p=(map @t json)]
  ==
```

#### Constrained Type
```hoon
+$  percentage
  @ud

++  validate-percentage
  |=  n=@ud
  ^-  percentage
  ?>  (lte n 100)
  n
```

## 4. Type Casting

### Why Cast?

1. **Type safety**: Ensure value matches expected type
2. **Documentation**: Make types explicit
3. **Validation**: Transform/normalize values
4. **Debugging**: Catch type errors early

### Cast Runes

#### `^-` (Kethep) - Type Assertion
**Most common cast**: Assert value has type

```hoon
^-  @ud
42

::  With computation
^-  @ud
(add 21 21)

::  Nested
^-  [x=@ud y=@ud]
[x=5 y=10]
```

**When to use**:
- Function return types
- Variable declarations
- Complex expressions
- Public APIs

#### `^+` (Ketlus) - Cast by Example
Cast to type of example value

```hoon
=/  template  *@ud
^+  template
42

::  Practical use
++  increment
  |=  n=@ud
  ^+  n
  (add n 1)
```

**When to use**:
- Matching existing value types
- Generic programming
- Type inference from examples

#### `^*` (Kettar) - Bunt (Default Value)
Produce default value for type

```hoon
^*  @ud        ::  0
^*  @t         ::  ''
^*  tape       ::  ""
^*  (list @)   ::  ~
^*  [@ @]      ::  [0 0]

::  Named type
+$  point  [x=@ud y=@ud]
^*  point      ::  [x=0 y=0]
```

**When to use**:
- Initialization
- Default values
- Testing

### Nest Failures (`nest-fail`)

Most common type error: **nest-fail**

```hoon
-need.@ud
-have.@t
nest-fail
```

**Reading nest-fail**:
- `-need`: Expected type
- `-have`: Actual type

**Common causes**:

1. **Type mismatch**:
```hoon
^-  @ud
'hello'  ::  FAIL: text is not number
```

2. **Aura incompatibility**:
```hoon
^-  @t
42  ::  FAIL: number is not text
```

3. **Structure mismatch**:
```hoon
^-  [@ @]
42  ::  FAIL: atom is not cell
```

**Solutions**:

1. **Fix the value**:
```hoon
^-  @ud
42  ::  ✓
```

2. **Convert the type**:
```hoon
^-  @t
(scot %ud 42)  ::  '42' (tape representation)
```

3. **Fix the cast**:
```hoon
^-  @
42  ::  ✓ (more general type)
```

## 5. Type Inference

### When Hoon Infers Types

Hoon infers types in many contexts:

```hoon
::  Function parameters
|=  n=@ud     ::  n has type @ud
(add n 1)     ::  Compiler knows n is @ud

::  Conditional branches
=/  x  ?:((gth n 10) 100 200)
::  x inferred as @ud

::  Function calls
(add 1 2)     ::  Returns @ud (inferred)
```

### When to Cast Explicitly

**Always cast**:
1. **Function returns**:
```hoon
++  double
  |=  n=@ud
  ^-  @ud     ::  Explicit!
  (mul 2 n)
```

2. **Public APIs**:
```hoon
++  process
  |=  input=@t
  ^-  [result=@ud error=(unit @t)]
  ...
```

3. **Complex expressions**:
```hoon
^-  (list @ud)
%+  turn  data
|=(item=@ud (mul item 2))
```

**Optional (but recommended)**:
4. **Variable bindings**:
```hoon
=/  count  ^-  @ud  0
=/  name   ^-  @t  'Alice'
```

## 6. Generic Types (Polymorphism)

### Wet Gates (`|*`)

**Wet gates** preserve input types (polymorphic):

```hoon
|*  a=*
[a a]

::  Usage
((|*  a=*  [a a]) 42)       ::  [42 42] - type @ud preserved
((|*  a=*  [a a]) 'hello')  ::  ['hello' 'hello'] - type @t preserved
```

**Contrast with dry gates** (`|=`):
```hoon
|=  a=@
[a a]

::  Usage
((|=  a=@  [a a]) 42)       ::  [42 42] - type @ (generic atom)
((|=  a=@  [a a]) 'hello')  ::  ['hello' 'hello'] - type @ (loses @t)
```

### Mold Builders (`|$`)

Create parameterized types:

```hoon
::  Generic pair
|$  [a b]
[first=a second=b]

::  Usage
(pair @ud @t)  ::  Type: [first=@ud second=@t]
```

**Standard library examples**:

```hoon
::  list is a mold builder
+$  list  |$  [item]
  $@(~ [i=item t=(list item)])

::  unit is a mold builder
+$  unit  |$  [item]
  $@(~ [~ u=item])

::  map is a mold builder
+$  map  |$  [key value]
  (tree [p=key q=value])
```

### Building Generic Functions

```hoon
::  Generic identity
++  identity
  |*  a=*
  ^+  a
  a

::  Generic first element
++  head
  |*  [a=* b=*]
  ^+  a
  a

::  Generic list length
++  lent
  |*  a=(list)
  ^-  @ud
  ?~  a  0
  (add 1 $(a t.a))
```

## 7. Variance and Nesting

### What is Variance?

**Variance** determines how type hierarchies compose.

### Covariance (Outputs)

**Child can substitute for parent** in return types:

```hoon
::  @ud nests in @
++  get-number
  |=  ~
  ^-  @       ::  Returns generic atom
  ^-  @ud     ::  Can return @ud (more specific)
  42
```

### Contravariance (Inputs)

**Parent can substitute for child** in parameters:

```hoon
::  Function expects @ud
++  process-ud
  |=  n=@ud
  (mul n 2)

::  Can pass to function expecting @
++  process-atom
  |=  fn=$-(@ud @ud)
  (fn 42)

(process-atom process-ud)  ::  ✓ Works
```

### Nesting Rules

```hoon
::  Atoms
@ud nests in @u
@u  nests in @
@ud nests in @    ::  Transitive

::  Cells
[@ud @t] nests in [@ @]
[x=@ud y=@t] nests in [@ud @t]  ::  Faces ignored

::  Functions
$-(@ud @ud) nests in $-(@ @)    ::  Contravariant in input
$-(@ @ud)   nests in $-(@ @)    ::  Covariant in output
```

### Common Nesting Patterns

**Widening types** (always safe):
```hoon
=/  specific  ^-  @ud  42
=/  general   ^-  @    specific  ::  ✓ @ud → @
```

**Narrowing types** (requires validation):
```hoon
=/  general   ^-  @   42
=/  specific  ^-  @ud general     ::  ✓ @ → @ud (validated)
```

**Structural nesting**:
```hoon
=/  detailed  [x=5 y=10 z=15]
=/  simple    ^-  [x=@ y=@]  detailed  ::  ✓ Forgets z
```

## 8. Type-Driven Development

### Workflow

1. **Design types first**:
```hoon
+$  task
  $:  id=@ud
      title=@t
      completed=?
  ==

+$  state
  $:  tasks=(map @ud task)
      next-id=@ud
  ==
```

2. **Define type signatures**:
```hoon
++  add-task
  |=  [title=@t state=state-0]
  ^-  state-0
  ...

++  complete-task
  |=  [id=@ud state=state-0]
  ^-  [result=(unit task) state=state-0]
  ...
```

3. **Implement with type safety**:
```hoon
++  add-task
  |=  [title=@t s=state-0]
  ^-  state-0
  =/  new-task  ^-  task
    [id=next-id.s title=title completed=%.n]
  s(tasks (~(put by tasks.s) next-id.s new-task), next-id +(next-id.s))
```

### Benefits

1. **Compiler catches errors**
2. **Self-documenting code**
3. **Refactoring confidence**
4. **API contracts**

## 9. Advanced Patterns

### Phantom Types

Types with information only at compile time:

```hoon
::  Validated string (phantom type)
+$  validated  @t

++  validate
  |=  raw=@t
  ^-  validated
  ?>  (gte (lent (trip raw)) 3)
  raw

++  use-validated
  |=  v=validated
  ::  Know v is validated!
  ...
```

### Type-Level Computation

```hoon
::  Compute type from value
++  either
  |$  [a b]
  $%  [%left p=a]
      [%right p=b]
  ==

::  Usage
=/  result  ^-  (either @ud @t)
  ?:  condition
    [%left 42]
  [%right 'error']
```

### Dependent Types (Limited)

Hoon has limited dependent types:

```hoon
::  List of known length (simulated)
+$  vec
  |$  [n item]
  (list item)  ::  TODO: validate length = n

::  Better: use validation
++  make-vec
  |*  [n=@ud items=(list)]
  ?>  =((lent items) n)
  items
```

## 10. Working with `*`-Typed Nouns

Code that processes untyped nouns (e.g., `|=  parsed=*` in cook functions,
vase payloads, or poke data) requires specific patterns to cast back into
typed values. The three casting mechanisms behave very differently with `*`.

### Casting Mechanisms

#### `^-` / backtick — Compile-Time Assertion
`` `@tas`value `` is sugar for `^-(@ value)`. It checks at **compile time**
that the value's type nests in the target type. Fails with nest-fail when
the value is `*`, because `*` doesn't nest in any specific type:

```hoon
|=  parsed=*
`@tas`parsed        ::  nest-fail: -have.* -need.@tas

::  Also fails for structured types:
`qualified-column:ast`parsed  ::  nest-fail
```

**Use when**: the compiler already knows the value has a compatible type.

#### `;;` (micmic) — Runtime Normalization
`;;(type value)` validates the noun structure at **runtime** and produces a
typed result. Crashes if the noun doesn't match:

```hoon
|=  parsed=*
;;(@tas parsed)                 ::  ✓ works if parsed is an atom
;;(qualified-column:ast parsed) ::  ✓ works if structure matches
```

**Use when**: you have a `*`-typed noun and need a fully typed value.
Appropriate for complex structured types.

#### Extract + Narrow with `?=`
For extracting fields from a `*`-typed noun, extract the field into a face,
then narrow it with `?=` or `?>`:

```hoon
|=  parsed=*
?:  ?=([%my-tag *] parsed)
  =/  name  +>-.parsed       ::  type is still *
  ?>  ?=(@ name)             ::  narrows to @
  [%result name=name]        ::  @ nests freely in @tas, @t, etc.
...
```

**Use when**: you need specific fields from a partially-typed noun.
After `?=(@ x)`, the atom `x` nests freely into any aura (`@tas`, `@t`,
`@ud`, etc.) — Hoon is permissive with atom aura nesting.

### `?=` Type Narrowing on `*`

`?=` checks structure and produces a loobean (`?`), but inner `*` stays `*`:

```hoon
|=  parsed=*
?:  ?=([%my-tag *] parsed)
  ::  HERE: parsed is [%my-tag *]
  ::  -.parsed is %my-tag (narrowed)
  ::  +.parsed is still * (NOT narrowed)
  `@tas`+.parsed             ::  nest-fail! still *
  ...
```

**Fix**: extract and narrow inner fields separately:
```hoon
?:  ?=([%my-tag *] parsed)
  =/  val  +.parsed
  ?>  ?=(@ val)              ::  now val is @
  val                        ::  nests in @tas, @t, etc.
```

### `?=` Cannot Match Specific Values Deep in `*`

You **cannot** put specific atom values in nested positions of a `?=`
pattern when the subject is `*`:

```hoon
|=  parsed=*
::  FAILS: nest-fail -have.* -need.?(%.y %.n)
?:  ?=([%tag [%inner 'specific-value' @ *] *] parsed)
  ...
```

**Fix**: check structure first, then use `=` for value checks:
```hoon
?:  ?=([%tag [%inner *] *] parsed)
  ?:  =('specific-value' +<+<.parsed)
    ::  matched
  ...
```

## 11. Common Type Patterns

### Pattern 1: Optional Value
```hoon
+$  maybe-user
  (unit user)

?~  maybe-user
  'no user'
(display-user u.maybe-user)
```

### Pattern 2: Result Type
```hoon
+$  result
  $%  [%ok value=@t]
      [%err error=@t]
  ==

=/  res  ^-  result  (do-operation)
?-  -.res
  %ok   "Success: {<value.res>}"
  %err  "Error: {<error.res>}"
==
```

### Pattern 3: State Machine
```hoon
+$  connection-state
  $%  [%disconnected ~]
      [%connecting timeout=@dr]
      [%connected since=@da]
      [%error msg=@t]
  ==
```

### Pattern 4: Builder Pattern
```hoon
+$  query-builder
  $:  table=@t
      fields=(list @t)
      where=(unit @t)
  ==

++  from
  |=  table=@t
  ^-  query-builder
  [table=table fields=~ where=~]

++  select
  |=  [fields=(list @t) qb=query-builder]
  ^-  query-builder
  qb(fields fields)
```

### Pattern 5: Type-Safe IDs
```hoon
+$  user-id  @ud
+$  post-id  @ud

::  Type alias helps documentation
++  get-user
  |=  id=user-id
  ^-  (unit user)
  ...
```

## 12. Debugging Type Errors

### Strategy

1. **Read the error**:
```
-need.@ud
-have.@t
nest-fail
```
→ "Need @ud, have @t"

2. **Find the line** (look for `fish:`)
```
/gen/example/hoon:<line>:<column>
```

3. **Check types**:
```hoon
~&  >  value     ::  Print value
~&  >  `@`value  ::  Print as atom
!>  value        ::  Inspect type
```

4. **Verify casts**:
```hoon
^-  @ud
value  ::  Does value match @ud?
```

5. **Simplify**:
```hoon
::  Break into steps
=/  step-1  (first-operation)
=/  step-2  (second-operation step-1)
step-2
```

### Common Fixes

**Problem**: `nest-fail`
**Solution**: Check `^-` cast matches actual type

**Problem**: `find-fork`
**Solution**: Check `?-` covers all cases

**Problem**: `find-limb.x`
**Solution**: Variable `x` not in scope

**Problem**: `mint-vain`
**Solution**: Remove unused value

## 13. Best Practices

### 1. Always Cast Function Returns
```hoon
++  process
  |=  input=@t
  ^-  @ud        ::  ✓ Explicit
  (lent (trip input))
```

### 2. Use Descriptive Type Names
```hoon
+$  user-id  @ud           ::  ✓ Clear
+$  timestamp  @da         ::  ✓ Clear
+$  x  @ud                 ::  ✗ Unclear
```

### 3. Prefer Tagged Unions
```hoon
+$  result
  $%  [%success data=@t]
      [%failure error=@t]
  ==
```

### 4. Document Complex Types
```hoon
::  Recursive JSON structure
::  Supports: string, number, bool, array, object
+$  json
  $@  ~
  $%  [%s p=@t]
      [%n p=@ta]
      [%b p=?]
      [%a p=(list json)]
      [%o p=(map @t json)]
  ==
```

### 5. Use Units for Optional Values
```hoon
+$  config
  $:  required=@t
      optional=(unit @t)
  ==
```

## Resources

- [Type System Reference](https://docs.urbit.org/language/hoon/reference/type) - Official docs
- [Aura List](https://docs.urbit.org/language/hoon/reference/auras) - All auras
- [Mold Reference](https://docs.urbit.org/language/hoon/reference/mold) - Mold patterns
- [Advanced Types](https://docs.urbit.org/language/hoon/guides/advanced) - Advanced patterns

## Summary

Hoon's type system provides:
1. **Compile-time safety** through structural typing
2. **Auras** for atom interpretation
3. **Molds** for structural validation
4. **Type inference** with explicit casts when needed
5. **Generics** via wet gates and mold builders
6. **Variance** for safe type composition

Mastering these concepts enables building robust, type-safe Hoon applications with confidence.
