---
name: rune-reference
description: Complete reference guide for all ~90+ Hoon runes (operators) across 13 families, their syntax forms (tall/wide/irregular), usage patterns, and practical examples. Use when writing Hoon code, understanding existing code, choosing the right rune for a task, or debugging rune-related errors.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Rune Reference Skill

Complete reference guide for all Hoon runes (operators), their syntax forms, usage patterns, and practical examples. Use when writing Hoon code, understanding existing code, or choosing the right rune for a task.

## Overview

Runes are Hoon's fundamental operators, written as digraphs (two ASCII characters). This comprehensive reference covers all ~90+ runes across 13 families, their tall/wide/irregular forms, and practical usage patterns.

## Learning Objectives

1. Understand rune syntax (tall, wide, irregular forms)
2. Master core runes used in 90% of Hoon code
3. Know all rune families and their purposes
4. Apply runes effectively in real code
5. Debug rune-related errors
6. Choose optimal runes for specific tasks

## Rune Syntax Forms

### Three Forms

Every rune has up to three syntactic forms:

**Tall Form** - Multi-line, explicit structure:
```hoon
?:  test
  true-branch
false-branch
```

**Wide Form** - Single-line, parenthesized:
```hoon
?:(test true-branch false-branch)
```

**Irregular Form** - Syntactic sugar (not all runes):
```hoon
[a b c]  ::  Irregular for :*[a b c]
```

### Choosing a Form

- **Tall**: Complex expressions, multiple lines, readability
- **Wide**: Simple expressions, inline usage
- **Irregular**: Common patterns, concise code

## Rune Families (13 Total)

### 1. `|` - Bar Runes (Cores)

Create cores (code/data structures with multiple arms).

#### `|%` - Barcen - Dry Core
**Purpose**: Library of named functions (arms)

**Syntax**:
```hoon
::  Tall form
|%
++  arm-1  code-1
++  arm-2  code-2
--

::  Example
|%
++  double  |=(n=@ (mul 2 n))
++  triple  |=(n=@ (mul 3 n))
--
```

**When to use**: Building libraries, organizing related functions

#### `|=` - Bartis - Gate (Function)
**Purpose**: Create a function that takes arguments

**Syntax**:
```hoon
::  Tall form
|=  sample=type
body

::  Wide form
|=(sample=type body)

::  Example
|=  n=@ud
^-  @ud
(mul 2 n)
```

**When to use**: Every time you need a function/lambda

#### `|.` - Bardot - Trap (Lazy Computation)
**Purpose**: Defer computation until called

**Syntax**:
```hoon
::  Tall form
|.
code

::  Wide form
|.(code)

::  Example
=/  expensive-calc  |.((slow-function))
?:  need-result
  $:expensive-calc  ::  Only evaluate if needed
[~ ~]
```

**When to use**: Lazy evaluation, avoiding unnecessary computation

#### `|-` - Barhep - Trap Kick
**Purpose**: Create a trap and immediately run its `$` arm. Desugars to `=<($ |.(body))`.

**Syntax**:
```hoon
::  Tall form
|-
code

::  Example
=/  counter  10
|-
?:  =(counter 0)
  'done'
$(counter (dec counter))
```

**When to use**: Loops, recursion, iteration (creates a trap and immediately executes it)

#### `|^` - Barket - Multi-arm Core
**Purpose**: Core with a default `$` arm

**Syntax**:
```hoon
|^
main-code
++  helper-1  code-1
++  helper-2  code-2
--

::  Example
|^
(helper-1 (helper-2 10))
++  helper-1  |=(n=@ (mul 2 n))
++  helper-2  |=(n=@ (add n 5))
--
```

**When to use**: Complex logic with helper functions

#### `|*` - Bartar - Wet Gate (Generic Function)
**Purpose**: Polymorphic function (preserves input types)

**Syntax**:
```hoon
|*  sample=type
body

::  Example
|*  a=*
[a a]  ::  Works with any type, preserves it
```

**When to use**: Generic/polymorphic code, type preservation

#### `|$` - Barbuc - Mold Builder
**Purpose**: Create parameterized types (generics)

**Syntax**:
```hoon
|$  [type-param-1 type-param-2]
type-definition

::  Example
|$  [item]
$@(~ [i=item t=(list item)])  ::  Generic list
```

**When to use**: Generic type definitions (like `list`, `set`, `map`)

#### `|_` - Barcab - Door (Stateful Core)
**Purpose**: Core with sample (like object with state)

**Syntax**:
```hoon
|_  sample=type
++  method-1  code-1
++  method-2  code-2
--

::  Example
|_  counter=@ud
++  increment  +(counter)
++  decrement  (dec counter)
++  get       counter
--
```

**When to use**: Stateful APIs, method collections

### 2. `:` - Col Runes (Cells)

Build cells (pairs) and tuples.

#### `:*` - Coltar - N-tuple
**Purpose**: Build tuple of arbitrary size

**Syntax**:
```hoon
::  Tall form
:*  a
    b
    c
==

::  Wide form
:*(a b c)

::  Irregular form
[a b c]
```

**When to use**: Creating tuples (most common cell rune)

#### `:-` - Colhep - Pair
**Purpose**: Build 2-tuple (cell)

**Syntax**:
```hoon
::  Tall form
:-  head
tail

::  Wide form
:-(head tail)

::  Irregular form
[head tail]
```

**When to use**: Pairs, return values with state

#### `:_` - Colcab - Inverted Pair
**Purpose**: Build pair (tail first, head second)

**Syntax**:
```hoon
::  Tall form
:_  tail
head

::  Wide form
:_(tail head)

::  Example
:_  this
~[[%give %fact ~[/path] %noun !>('data')]]
```

**When to use**: Gall agents (cards before state), readability

#### `:+` - Collus - Triple
**Purpose**: Build 3-tuple

**Syntax**:
```hoon
::  Tall form
:+  a
  b
c

::  Wide form
:+(a b c)

::  Irregular form
[a b c]
```

**When to use**: 3-element structures

#### `:^` - Colket - Quadruple
**Purpose**: Build 4-tuple

**Syntax**:
```hoon
::  Tall form
:^  a
  b
  c
d

::  Wide form
:^(a b c d)

::  Irregular form
[a b c d]
```

**When to use**: 4-element structures

#### `:~` - Colsig - Null-terminated List
**Purpose**: Build list with `~` terminator

**Syntax**:
```hoon
::  Tall form
:~  a
    b
    c
==

::  Wide form
:~(a b c)

::  Irregular form
~[a b c]
```

**When to use**: Building lists

### 3. `.` - Dot Runes (Nock)

Low-level Nock operations and special forms.

#### `.+` - Dotlus - Increment
**Purpose**: Increment atom

**Syntax**:
```hoon
.+(5)  ::  6

::  Irregular form
+(5)   ::  6
```

**When to use**: Rarely (use `++  add` instead), Nock-level code

#### `.=` - Dottis - Test Equality
**Purpose**: Test if two nouns are equal

**Syntax**:
```hoon
::  Tall form
.=  a
b

::  Wide form
.=(a b)

::  Irregular form
=(a b)
```

**When to use**: Comparisons (irregular form most common)

#### `.^` - Dotket - Scry
**Purpose**: Read from Arvo namespace

**Syntax**:
```hoon
.^(type care /path)

::  Example
.^(arch %cy /===/gen)  ::  List generators
.^(@ud %gu /~sampel/base/1)  ::  Read from ship
```

**When to use**: Reading from filesystem, kernel, other ships

#### `.?` - Dotwut - Test for Cell
**Purpose**: Test if noun is a cell

**Syntax**:
```hoon
.?(noun)

::  Example
.?([1 2])  ::  %.y (yes, is cell)
.?(42)     ::  %.n (no, is atom)
```

**When to use**: Type testing, debugging

### 4. `=` - Tis Runes (Subject Modification)

Modify the subject (add bindings, compose context).

#### `=/` - Tisfas - Bind Name
**Purpose**: Add a named value to the subject

**Syntax**:
```hoon
::  Tall form
=/  name  value
code

::  Wide form
=/(name value code)

::  Example
=/  x  5
=/  y  10
(add x y)
```

**When to use**: Variable binding (most common!)

#### `=+` - Tislus - Add to Subject
**Purpose**: Add value to subject head (no name)

**Syntax**:
```hoon
::  Tall form
=+  value
code

::  Example
=+  5
.+  -  ::  Increment the head (5)
```

**When to use**: Rarely (use `=/` for named values)

#### `=<` - Tisgal - Compose Backward
**Purpose**: Evaluate right, then left (left uses right as context)

**Syntax**:
```hoon
::  Tall form
=<  result
context

::  Example
=<  (helper 10)  ::  Use core from below
|%
++  helper  |=(n=@ (mul 2 n))
--
```

**When to use**: Result-first code organization

#### `=>` - Tisgar - Compose Forward
**Purpose**: Evaluate left, then right (right uses left as context)

**Syntax**:
```hoon
::  Tall form
=>  context
result

::  Example
=>  |%
    ++  helper  |=(n=@ (mul 2 n))
    --
(helper 10)
```

**When to use**: Build library, then use it

#### `=;` - Tismic - Bind with Continuation
**Purpose**: Compute bottom, bind to name, use in top

**Syntax**:
```hoon
::  Tall form
=;  name
  body
value

::  Example
=;  result
  (mul 2 result)
(add 3 4)  ::  Compute 7, bind to 'result', then mul by 2
```

**When to use**: Inverted computation flow

#### `=.` - Tisdot - Modify Wing
**Purpose**: Modify part of subject

**Syntax**:
```hoon
::  Tall form
=.  wing  new-value
code

::  Example
=/  point  [x=5 y=10]
=.  x.point  20
point  ::  [x=20 y=10]
```

**When to use**: Updating nested structures

#### `=*` - Tistar - Alias
**Purpose**: Create an alias (macro substitution)

**Syntax**:
```hoon
::  Tall form
=*  alias  expression
code

::  Example
=/  long-variable-name  42
=*  x  long-variable-name
(add x x)
```

**When to use**: Shorthand, avoiding repetition

#### `=^` - Tisket - Pin to Head
**Purpose**: Run computation, pin result to name, modify wing

**Syntax**:
```hoon
::  Tall form
=^  name  wing  call
body

::  Example (Gall pattern)
=^  cards  state
  (handle-action action)
[cards this]
```

**When to use**: Gall agents, stateful computation

#### `=~` - Tissig - Compose Many
**Purpose**: Compose multiple expressions sequentially. Each expression's result becomes the subject for the next.

**Syntax**:
```hoon
::  Tall form
=~  expr-1
    expr-2
    expr-3
==

::  Example
=~  [42 "hello"]
    -.
==
::  Evaluates to 42 (the head of the cell).
::  [42 "hello"] becomes the subject, then -. takes the head.
```

**When to use**: Chaining subject transformations, composing cores

#### `=?` - Tiswut - Conditional Modify
**Purpose**: Conditionally modify wing

**Syntax**:
```hoon
::  Tall form
=?  wing  condition  new-value
code

::  Example
=/  x  5
=?  x  %.y  10  ::  If true, set x to 10
x  ::  10
```

**When to use**: Conditional updates

### 5. `?` - Wut Runes (Conditionals)

Branching and pattern matching.

#### `?:` - Wutcol - If-Then-Else
**Purpose**: Basic conditional

**Syntax**:
```hoon
::  Tall form
?:  test
  true-branch
false-branch

::  Wide form
?:(test true-branch false-branch)

::  Example
?:  (gth n 10)
  'big'
'small'
```

**When to use**: 2-way branching (most common conditional!)

#### `?-` - Wuthep - Switch on Type
**Purpose**: Pattern match on type (exhaustive)

**Syntax**:
```hoon
::  Tall form
?-  value
  %case-1  result-1
  %case-2  result-2
==

::  Example
=/  color  %red
?-  color
  %red    'stop'
  %yellow 'slow'
  %green  'go'
==
```

**When to use**: Handling tagged unions, action types

#### `?.` - Wutdot - Inverted If
**Purpose**: If-then-else with inverted test

**Syntax**:
```hoon
::  Tall form
?.  test
  false-branch
true-branch

::  Example
?.  (gth n 10)
  'small'
'big'
```

**When to use**: When false-first logic is clearer

#### `?+` - Wutlus - Switch with Default
**Purpose**: Pattern match with catch-all

**Syntax**:
```hoon
::  Tall form
?+  value  default
  pattern-1  result-1
  pattern-2  result-2
==

::  Example
?+  action  !!
  %add  (handle-add)
  %del  (handle-del)
==
```

**When to use**: Non-exhaustive matching, error on unknown

#### `?~` - Wutsig - If Null
**Purpose**: Test if null `~`, branch accordingly

**Syntax**:
```hoon
::  Tall form
?~  value
  null-branch
non-null-branch

::  Example
=/  maybe  `(unit @ud)`~
?~  maybe
  'nothing'
(a-co:co u.maybe)
```

**When to use**: Unit handling, list empty check

#### `?@` - Wutpat - If Atom
**Purpose**: Test if atom, branch accordingly

**Syntax**:
```hoon
::  Tall form
?@  value
  atom-branch
cell-branch

::  Example
=/  x  42
?@  x
  'is atom'
'is cell'
```

**When to use**: Type-based branching (atom vs cell)

#### `?^` - Wutket - If Cell
**Purpose**: Test if cell, branch accordingly

**Syntax**:
```hoon
::  Tall form
?^  value
  cell-branch
atom-branch

::  Example
=/  x  [1 2]
?^  x
  'is cell'
'is atom'
```

**When to use**: List processing, cell detection

#### `?<` - Wutgal - Assert False
**Purpose**: Assert condition is false, crash otherwise

**Syntax**:
```hoon
?<  condition
body

::  Example
?<  =(x 0)  ::  Crash if x is 0
(div 100 x)
```

**When to use**: Negative assertions, preconditions

#### `?>` - Wutgar - Assert True
**Purpose**: Assert condition is true, crash otherwise

**Syntax**:
```hoon
?>  condition
body

::  Example
?>  (gth x 0)  ::  Crash if x not positive
(div 100 x)
```

**When to use**: Preconditions, validation

#### `?=` - Wuttis - Test Structure
**Purpose**: Test if value matches structure

**Syntax**:
```hoon
?=([%tag *] value)

::  Example
=/  val  [%foo 42]
?:  ?=([%foo @] val)
  'matched foo'
'other'
```

**When to use**: Pattern testing (refines type)

#### `?|` - Wutbar - Logical OR
**Purpose**: Short-circuit OR (true if any true)

**Syntax**:
```hoon
::  Tall form
?|  test-1
    test-2
    test-3
==

::  Example
?|  =(x 0)
    =(x 1)
    =(x 2)
==
```

**When to use**: Multiple conditions, OR logic

#### `?&` - Wutpam - Logical AND
**Purpose**: Short-circuit AND (true if all true)

**Syntax**:
```hoon
::  Tall form
?&  test-1
    test-2
    test-3
==

::  Example
?&  (gth x 0)
    (lth x 100)
    =(0 (mod x 2))
==
```

**When to use**: Multiple conditions, AND logic

### 6. `!` - Zap Runes (Debugging & Printing)

Assertions, errors, and debugging output.

#### `!!` - Zapzap - Crash
**Purpose**: Unconditional crash

**Syntax**:
```hoon
!!

::  Example
?+  action  !!  ::  Crash on unknown action
  %known  (handle)
==
```

**When to use**: Unreachable code, unhandled cases

#### `!>` - Zapgar - Produce Vase
**Purpose**: Wrap value with type (create vase)

**Syntax**:
```hoon
!>(value)

::  Example
!>([%result 42])  ::  [#t/[@tas @ud] q=[%result 42]]
```

**When to use**: Gall cards, type-preserving serialization

#### `!<` - Zapgal - Extract from Vase
**Purpose**: Extract typed value from vase

**Syntax**:
```hoon
!<(type vase)

::  Example
=/  v  !>([%result 42])
!<([@tas @ud] v)  ::  [%result 42]
```

**When to use**: Unpacking Gall messages, deserializing

#### `!=` - Zaptis - Make Formula
**Purpose**: Compile Hoon to Nock formula

**Syntax**:
```hoon
!=(hoon-code)

::  Example
!=(add)  ::  Nock formula for add
```

**When to use**: Metaprogramming, Nock inspection

#### `!?` - Zapwut - Version Check
**Purpose**: Assert minimum Hoon version. Crashes if hoon-version doesn't match.

**Syntax**:
```hoon
!?  [%hoon-version minimum]
code

::  Example
!?  [%hoon-version 140]
|%
++  my-gate  |=(a=@ a)
--
```

**When to use**: Enforcing minimum Hoon version at the top of a file

### 7. `^` - Ket Runes (Type Operations)

Type casting, conversion, and validation.

#### `^-` - Kethep - Cast (Type Assertion)
**Purpose**: Assert value has type, validate and cast

**Syntax**:
```hoon
::  Tall form
^-  type
value

::  Wide form
^-(type value)

::  Example
^-  @ud
42
```

**When to use**: Type safety, documentation, validation

#### `^+` - Ketlus - Cast by Example
**Purpose**: Cast to type of example value

**Syntax**:
```hoon
^+  example
value

::  Example
=/  template  *@ud
^+  template
42
```

**When to use**: Type matching, bunting

#### `^*` - Kettar - Produce Bunt (Default Value)
**Purpose**: Produce default value for type

**Syntax**:
```hoon
^*  type

::  Example
^*  @ud   ::  0
^*  tape  ::  ""
^*  (list @ud)  ::  ~
```

**When to use**: Default values, initialization

#### `^:` - Ketcol - Mold Gate
**Purpose**: Construct a normalizing gate from a type specification.

**Syntax**:
```hoon
^:  type

::  Example
^:  @ud  ::  Produces a gate that normalizes its sample to @ud
```

**When to use**: When you need a gate that normalizes/validates values to a given type

#### `^.` - Ketdot - Self-Cast
**Purpose**: Apply gate p to value q and cast q to the result's type. Desugars to `^+((p q) q)`.

**Syntax**:
```hoon
^.  p
q

::  Example
^.  |=(a=@ud a)
42  ::  Applies the gate to 42, then casts 42 to the result type (@ud)
```

**When to use**: When you want to cast a value by running it through a normalizer gate

#### `^=` - Kettis - Name Type
**Purpose**: Bind face (name) to typed value

**Syntax**:
```hoon
::  Tall form
^=  name
value

::  Irregular form
name=value
```

**When to use**: Never (use irregular `name=value`)

#### `^&` - Ketpam - Covariant
**Purpose**: Mark core as covariant (zinc variance).

**Syntax**:
```hoon
^&  core

::  Example
^&  |%
    ++  val  42
    --
```

**When to use**: Advanced type system usage to mark a core with zinc (covariant) variance

#### `^|` - Ketbar - Contravariant
**Purpose**: Mark core as contravariant (iron variance).

**Syntax**:
```hoon
^|  core

::  Example
^|  |=(a=@ a)  ::  Mark this gate as iron (contravariant)
```

**When to use**: Advanced type system usage to mark a core with iron (contravariant) variance

#### `^~` - Ketsig - Compile-time Evaluation
**Purpose**: Evaluate at compile time (constant fold)

**Syntax**:
```hoon
^~  expression

::  Example
^~  (mul 1.000 1.000)  ::  Computed at compile time
```

**When to use**: Constants, optimization

### 8. `~` - Sig Runes (Hints & Debugging)

Compiler hints and error messages.

#### `~|` - Sigbar - Trap Message
**Purpose**: Print message if code crashes

**Syntax**:
```hoon
~|  message
code

::  Example
~|  'division by zero!'
(div 100 x)
```

**When to use**: Error context, debugging crashes

#### `~_` - Sigcab - Print on Trace
**Purpose**: Add to stack trace

**Syntax**:
```hoon
~_  leaf+"message"
code

::  Example
~_  leaf+"processing item {<n>}"
(process-item n)
```

**When to use**: Detailed stack traces

#### `~>` - Siggar - Hint Forward
**Purpose**: Give hint to compiler/runtime

**Syntax**:
```hoon
~>  %hint
code

::  Example
~>  %bout  ::  Profiling hint
(expensive-function)
```

**When to use**: Performance hints, profiling

#### `~<` - Siggal - Hint Backward
**Purpose**: Hint with different evaluation order

**Syntax**:
```hoon
~<  %hint
code
```

**When to use**: Rarely (use `~>` instead)

#### `~$` - Sigbuc - Profiler Hit
**Purpose**: Label for profiling. Provides a profiler label hint.

**Syntax**:
```hoon
~$  %label
code

::  Example
~$  %my-function
(expensive-computation x)
```

**When to use**: Profiling and performance analysis, labeling code sections for the profiler

#### `~+` - Siglus - Memoize
**Purpose**: Cache/memoize the result of a computation.

**Syntax**:
```hoon
~+  code

::  Example
~+  (big-computation)  ::  Result is cached; subsequent calls return cached value
```

**When to use**: Expensive pure computations that may be called repeatedly with the same subject

#### `~&` - Sigpam - Print Debug
**Purpose**: Print to console and continue

**Syntax**:
```hoon
~&  message
code

::  Example
~&  >>  x
~&  "Value of x: {<x>}"
(continue)
```

**When to use**: Debug printing (most common debug rune!)

#### `~?` - Sigwut - Conditional Print
**Purpose**: Print if condition true

**Syntax**:
```hoon
~?  condition  message
code

::  Example
~?  (gth x 100)  "Big value: {<x>}"
(process x)
```

**When to use**: Conditional debugging

#### `~/` - Sigfas - Jet Hint
**Purpose**: Hint function has jet acceleration

**Syntax**:
```hoon
~/  %jet-name
code
```

**When to use**: Standard library (system code only)

### 9. `;` - Mic Runes (Make)

Miscellaneous construction runes.

#### `;:` - Miccol - Call Function N-ary
**Purpose**: Call function with many arguments

**Syntax**:
```hoon
;:  function
  arg-1
  arg-2
  arg-3
==

::  Example
;:  weld
  "hello "
  "beautiful "
  "world"
==
```

**When to use**: Reducing lists with binary function

#### `;~` - Micsig - Compose Parsers
**Purpose**: Compose parsers sequentially

**Syntax**:
```hoon
;~  combinator
  parser-1
  parser-2
==

::  Example
;~  plug
  (jest 'hello')
  ace
  (jest 'world')
==
```

**When to use**: Parser composition

### 10. `$` - Buc Runes (Molds/Types)

Type definitions and structures.

#### `$:` - Buccol - Form Mold (Tuple Type)
**Purpose**: Define tuple/structure type

**Syntax**:
```hoon
$:  a=type-a
    b=type-b
==

::  Example
+$  point
  $:  x=@ud
      y=@ud
  ==
```

**When to use**: Struct/tuple types

#### `$_` - Buccab - Mold from Example
**Purpose**: Create mold from example value

**Syntax**:
```hoon
$_  example-value

::  Example
+$  my-type  $_([x=0 y=0])
```

**When to use**: Inferring types from examples

#### `$?` - Bucwut - Union Type
**Purpose**: Define tagged union (one of many)

**Syntax**:
```hoon
$?  type-1
    type-2
    type-3
==

::  Example
+$  color
  $?  %red
      %green
      %blue
  ==
```

**When to use**: Enums, variant types

#### `$%` - Buccen - Tagged Union
**Purpose**: Discriminated union with tag

**Syntax**:
```hoon
$%  [%tag-1 data-1]
    [%tag-2 data-2]
==

::  Example
+$  action
  $%  [%add task=@t]
      [%delete id=@ud]
  ==
```

**When to use**: Action types, message types

#### `$@` - Bucpat - Default Case
**Purpose**: Type with default for atom

**Syntax**:
```hoon
$@  atom-case
cell-case

::  Example
$@(~ [i=item t=(list item)])  ::  List (null or cell)
```

**When to use**: List-like recursive types

#### `$^` - Bucket - Default for Cell
**Purpose**: Type with default for cell

**Syntax**:
```hoon
$^  cell-case
atom-case
```

**When to use**: Rarely (inverse of `$@`)

#### `$-` - Buchep - Function Type
**Purpose**: Define function signature

**Syntax**:
```hoon
$-(input output)

::  Example
+$  incrementer  $-(@ud @ud)
```

**When to use**: Function type signatures

#### `$+` - Buclus - Define Type Arm
**Purpose**: Named type constructor

**Syntax**:
```hoon
$+  name  type
```

**When to use**: Exported type definitions

#### `$~` - Bucsig - Custom Default Value
**Purpose**: Define a mold with a custom default (bunt) value

**Syntax**:
```hoon
$~  default-value  mold

::  Example
+$  my-counter  $~(1 @ud)  ::  @ud that defaults to 1 instead of 0
```

**When to use**: When you need a type whose default value differs from the standard bunt. Note: there is no `$*` rune; use `$~` for custom defaults and `^*` to produce the bunt of a type.

#### `$=` - Buctis - Name Mold
**Purpose**: Bind face to mold

**Syntax**:
```hoon
$=  name
mold

::  Irregular form
name=mold
```

**When to use**: Never (use irregular `name=mold`)

### 11. `%` - Cen Runes (Calling)

Function calls and arm invocation.

#### `%-` - Cenhep - Call Function
**Purpose**: Call gate with sample

**Syntax**:
```hoon
::  Tall form
%-  function
argument

::  Wide form
%-(function argument)

::  Irregular form
(function argument)
```

**When to use**: Never tall/wide (always use irregular!)

#### `%+` - Cenlus - Call with 2 Args
**Purpose**: Call gate with 2 arguments

**Syntax**:
```hoon
%+  function
  arg-1
arg-2

::  Irregular form
(function arg-1 arg-2)
```

**When to use**: Rarely tall (use irregular)

#### `%^` - Cenket - Call with 3 Args
**Purpose**: Call gate with 3 arguments

**Syntax**:
```hoon
%^  function
  arg-1
  arg-2
arg-3

::  Irregular form
(function arg-1 arg-2 arg-3)
```

**When to use**: Rarely tall (use irregular)

#### `%:` - Cencol - Call with N Args
**Purpose**: Call gate with many arguments

**Syntax**:
```hoon
%:  function
  arg-1
  arg-2
  arg-3
==

::  Irregular form
(function arg-1 arg-2 arg-3)
```

**When to use**: Many arguments, vertical alignment

#### `%~` - Censig - Pull Arm
**Purpose**: Call arm with custom sample

**Syntax**:
```hoon
%~  arm  core  sample

::  Example
%~  get  by  map  ::  Call 'get' arm of 'by' core with 'map'
```

**When to use**: Door operations (map, set operations)

#### `%*` - Centar - Modify Core
**Purpose**: Call with modified core

**Syntax**:
```hoon
%*  arm  core
  face-1  value-1
  face-2  value-2
==

::  Example
%*  $  some-gate
  sample  new-value
==
```

**When to use**: Complex core manipulation

#### `%.` - Cendot - Inverted Call
**Purpose**: Inverted function call: sample first, gate second. `%.  sample  gate`

**Syntax**:
```hoon
::  Tall form
%.  sample
gate

::  Example
%.  42
|=(a=@ud (mul 2 a))  ::  Produces 84
```

**When to use**: When you want to emphasize the argument over the function, or for pipeline-style code

#### `%=` - Centis - Eval with Changes
**Purpose**: Recursion with modified subject

**Syntax**:
```hoon
%=  wing
  face-1  value-1
  face-2  value-2
==

::  Irregular form
wing(face-1 value-1, face-2 value-2)
```

**When to use**: Recursion, loop updates

Note: `$` is not a rune — it is a wing name referring to the default arm of a core. Use `%=` (centis) or its irregular form `$(...)` to recurse with modified values.

### 12. `+` - Lus Runes (Arms)

Arm definitions in cores.

#### `++` - Luslus - Arm (Public)
**Purpose**: Define public arm

**Syntax**:
```hoon
|%
++  arm-name
  code
--
```

**When to use**: Public functions/methods

#### `+$` - Lusbuc - Type Definition
**Purpose**: Define type arm

**Syntax**:
```hoon
|%
+$  type-name  mold
--
```

**When to use**: Type definitions in libraries

#### `+*` - Lustar - Alias Arm
**Purpose**: Create alias in arm

**Syntax**:
```hoon
++  arm-name
  +*  alias  expression
  code
```

**When to use**: Local aliases, macros

### 13. `&` - Pam Runes (Deprecated)

Mostly deprecated runes (use alternatives).

#### `&=` - Pamtis - Unused
**Purpose**: Deprecated

**When to use**: Never

## Common Usage Patterns

### Pattern 1: Basic Function
```hoon
|=  n=@ud
^-  @ud
(mul 2 n)
```
**Runes**: `|=` (function), `^-` (type cast)

### Pattern 2: Recursion/Loop
```hoon
=/  count  10
|-
?:  =(count 0)
  'done'
$(count (dec count))
```
**Runes**: `=/` (bind), `|-` (recursion point), `?:` (if), `$` (recurse)

### Pattern 3: Library Core
```hoon
|%
++  add-ten  |=(n=@ (add n 10))
++  mul-two  |=(n=@ (mul n 2))
--
```
**Runes**: `|%` (core), `++` (arms), `|=` (gates)

### Pattern 4: Type Definition
```hoon
+$  person
  $:  name=@t
      age=@ud
  ==
```
**Runes**: `+$` (type arm), `$:` (tuple mold)

### Pattern 5: Pattern Matching
```hoon
?-  -.action
  %add     (handle-add +.action)
  %delete  (handle-delete +.action)
==
```
**Runes**: `?-` (switch)

### Pattern 6: Unit Handling
```hoon
?~  result
  [~ state]
`[u.result state]
```
**Runes**: `?~` (if null), `` ` `` (irregular `unit`)

### Pattern 7: Gall Agent Pattern
```hoon
=^  cards  state
  (handle-action action)
:_  this
cards
```
**Runes**: `=^` (pin to head), `:_` (inverted pair)

## Debugging Rune Errors

### Common Error Patterns

**`mint-nice` - Type Mismatch**
```
-need.@ud
-have.@t
```
**Solution**: Check `^-` casts, ensure value matches type

**`mint-vain` - Unused Value**
```
mint-vain
```
**Solution**: Use value or remove it

**`find-fork` - Pattern Match Failed**
```
-need.?(%a %b)
-have.%c
```
**Solution**: Check `?-` switch covers all cases

## Quick Reference Table

| Family | Purpose | Most Common Runes |
|--------|---------|-------------------|
| `\|` Bar | Cores | `\|=` `\|%` `\|-` `\|^` |
| `:` Col | Cells | `:-` `:*` `:_` `:~` |
| `.` Dot | Nock | `.=` `.^` |
| `=` Tis | Subject | `=/` `=<` `=>` `=^` |
| `?` Wut | Branch | `?:` `?-` `?~` `?^` |
| `!` Zap | Debug | `!!` `!>` `!<` |
| `^` Ket | Types | `^-` `^+` `^*` |
| `~` Sig | Hints | `~\|` `~&` `~_` |
| `;` Mic | Make | `;:` `;~` |
| `$` Buc | Molds | `$:` `$%` `$?` `$-` |
| `%` Cen | Call | `%-` `%~` `%=` `$` |
| `+` Lus | Arms | `++` `+$` |

## Irregular Forms Quick Reference

```hoon
[a b c]           ::  :*[a b c]
~[a b c]          ::  :~(a b c)
`value            ::  [~ value]
=(a b)            ::  .=(a b)
(func arg)        ::  %-(func arg)
+(5)              ::  .+(5)
name=value        ::  ^=(name value)
^-(type val)      ::  Cast
$(x new-x)        ::  %=($ x new-x)
```

## Resources

- [Rune Reference](https://docs.urbit.org/hoon/rune) - Official documentation
- [Hoon School](https://developers.urbit.org/guides/core/hoon-school) - Rune tutorials
- [Irregular Forms](https://docs.urbit.org/hoon/irregular) - All irregular syntax

## Summary

Mastering runes is essential to Hoon fluency. Focus on:
1. **Core runes** (90% of code): `=/`, `?:`, `|-`, `|=`, `^-`, `?-`, `?~`
2. **Irregular forms** for common patterns: `[a b]`, `(func arg)`, `=(a b)`
3. **Reading patterns** in existing code
4. **Choosing appropriate forms** (tall vs wide vs irregular)

With these runes internalized, you can read and write any Hoon code fluently.
