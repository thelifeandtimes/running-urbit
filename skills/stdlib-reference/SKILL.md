---
name: stdlib-reference
description: Comprehensive reference for Hoon's standard library (hoon.hoon) organized by sections 1-5, covering list operations, set/map functions, text processing, math, parsing, and jetted functions. Use when looking for built-in functions, learning standard library capabilities, or optimizing common operations.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Standard Library Reference Skill

Comprehensive reference for Hoon's standard library organized by sections covering list operations, set/map functions, text processing, math, parsing, and more. Use when looking for built-in functions or learning standard library capabilities.

## Overview

Hoon's standard library (`hoon.hoon`) provides hundreds of functions organized into sections by number prefix. This skill covers the most commonly used functions and patterns.

## Learning Objectives

1. Navigate standard library documentation
2. Use list manipulation functions effectively
3. Work with sets and maps
4. Perform text and number operations
5. Understand jetted vs non-jetted functions
6. Find the right function for common tasks

## 1. Library Organization

### Section Numbering

The stdlib is organized by leading number:
- **1**: Basic arithmetic and logic
- **2**: List operations (2a-2d), Set/Map (2h-2j)
- **3**: Tree operations
- **4**: Text processing (4a-4m)
- **5**: Parsing (5a-5d)
- **Others**: Various utilities

### Jetted Functions

Many stdlib functions have **jets** (C implementations) for performance:
- `add`, `mul`, `div` - Arithmetic
- `turn`, `roll` - List operations
- Parsing combinators
- Cryptographic functions

**Impact**: Jetted functions are orders of magnitude faster.

## 2. List Operations (Section 2)

### Basic List Functions

```hoon
::  ++  flop - Reverse list
(flop ~[1 2 3])  ::  ~[3 2 1]

::  ++  lent - Length
(lent ~[1 2 3 4])  ::  4

::  ++  weld - Concatenate
(weld ~[1 2] ~[3 4])  ::  ~[1 2 3 4]

::  ++  snoc - Append element (O(n))
(snoc ~[1 2 3] 4)  ::  ~[1 2 3 4]

::  ++  scag - Take first N elements
(scag 2 ~[1 2 3 4])  ::  ~[1 2]

::  ++  slag - Drop first N elements
(slag 2 ~[1 2 3 4])  ::  ~[3 4]

::  ++  snag - Get element at index
(snag 2 ~[10 20 30 40])  ::  30

::  ++  oust - Remove slice
(oust [1 2] ~[0 1 2 3 4])  ::  ~[0 3 4]

::  ++  reap - Repeat element N times
(reap 3 'x')  ::  ~['x' 'x' 'x']

::  ++  runt - Prepend character repeatedly to tape
::  Signature: |=([[a=@ b=@] c=tape])
(runt [3 'x'] "y")  ::  "xxxy"
```

### Higher-Order List Functions

```hoon
::  ++  turn - Map
%+  turn  ~[1 2 3]
|=(n=@ud (mul n 2))
::  ~[2 4 6]

::  ++  skim - Filter (keep matching)
%+  skim  ~[1 2 3 4 5]
|=(n=@ud =(0 (mod n 2)))
::  ~[2 4]

::  ++  skip - Filter (remove matching)
%+  skip  ~[1 2 3 4 5]
|=(n=@ud =(0 (mod n 2)))
::  ~[1 3 5]

::  ++  roll - Fold left
%+  roll  ~[1 2 3 4]
|=([n=@ud acc=@ud] (add acc n))
::  10

::  ++  reel - Fold right
%+  reel  ~[1 2 3 4]
|=([n=@ud acc=@ud] (add n acc))
::  10

::  ++  sort - Sort list
%+  sort  ~[3 1 4 1 5]
|=([a=@ud b=@ud] (lth a b))
::  ~[1 1 3 4 5]

::  ++  find - Find sublist in list
::  Signature: |=([nedl=(list) hstk=(list)]) returns (unit @ud)
(find ~[2 3] ~[1 2 3 4])  ::  [~ 1] (index where sublist starts)
(find ~[5 6] ~[1 2 3 4])  ::  ~ (not found)

::  ++  hunt - Pick first of two units based on ordering function
::  Signature: |*([ord=$-(^ ?) a=(unit) b=(unit)])
(hunt lth `3 `5)  ::  `3 (picks lesser)
```

### List Predicates

```hoon
::  ++  levy - All match predicate
%+  levy  ~[2 4 6]
|=(n=@ud =(0 (mod n 2)))
::  %.y (all even)

::  ++  lien - Any match predicate
%+  lien  ~[1 3 5 7 8]
|=(n=@ud =(0 (mod n 2)))
::  %.y (at least one even)
```

### List Utilities

```hoon
::  ++  gulf - Range (inclusive)
(gulf 1 5)  ::  ~[1 2 3 4 5]

::  ++  zing - Flatten one level
(zing ~[~[1 2] ~[3 4] ~[5]])  ::  ~[1 2 3 4 5]

::  ++  spin - Map with state threading
%+  spin  ~[1 2 3]
|=  [n=@ud state=@ud]
[(mul n 2) (add state n)]
::  [~[2 4 6] 6]  ::  [results final-state]

::  ++  spun - Spin variant (takes gate-building gate)
::  Gate takes (item, state) same as spin
%+  spun  ~[1 2 3]
|=  [n=@ud state=@ud]
[(mul n 2) (add state n)]
::  [~[2 4 6] 6]  ::  [results final-state]
```

## 3. Set Operations (Section 2h)

### Core `in` Door

```hoon
=/  my-set  (silt ~[1 2 3 4 5])

::  ++  put:in - Add element
(~(put in my-set) 6)

::  ++  del:in - Remove element
(~(del in my-set) 3)

::  ++  has:in - Membership test
(~(has in my-set) 3)  ::  %.y

::  ++  tap:in - Convert to list
~(tap in my-set)  ::  ~[1 2 3 4 5]

::  ++  wyt:in - Cardinality
~(wyt in my-set)  ::  5

::  ++  uni:in - Union
(~(uni in (silt ~[1 2 3])) (silt ~[3 4 5]))
::  {1 2 3 4 5}

::  ++  int:in - Intersection
(~(int in (silt ~[1 2 3])) (silt ~[2 3 4]))
::  {2 3}

::  ++  dif:in - Difference
(~(dif in (silt ~[1 2 3])) (silt ~[2 3 4]))
::  {1}

::  ++  run:in - Map over set
%~  run  in  my-set
|=(n=@ud (mul n 2))
::  {2 4 6 8 10}

::  ++  rep:in - Fold over set
%~  rep  in  my-set
|=([n=@ud acc=@ud] (add n acc))
::  15
```

## 4. Map Operations (Section 2h)

### Core `by` Door

```hoon
=/  my-map  (my ~[[%a 1] [%b 2] [%c 3]])

::  ++  get:by - Lookup (returns unit)
(~(get by my-map) %a)  ::  `1

::  ++  got:by - Lookup (crashes if not found)
(~(got by my-map) %a)  ::  1

::  ++  gut:by - Lookup with default
(~(gut by my-map) %z 0)  ::  0

::  ++  has:by - Key exists
(~(has by my-map) %a)  ::  %.y

::  ++  put:by - Insert/update
(~(put by my-map) %d 4)

::  ++  del:by - Delete
(~(del by my-map) %b)

::  ++  tap:by - Convert to list of pairs
~(tap by my-map)  ::  ~[[%a 1] [%b 2] [%c 3]]

::  ++  gas:by - Insert multiple pairs
(~(gas by my-map) ~[[%d 4] [%e 5]])

::  ++  run:by - Map over values
%~  run  by  my-map
|=(v=@ud (mul v 2))

::  ++  urn:by - Map over key-value pairs
%~  urn  by  my-map
|=([k=@tas v=@ud] (add v 10))

::  ++  rep:by - Fold over map
%~  rep  by  my-map
|=([[k=@tas v=@ud] acc=@ud] (add v acc))

::  ++  uni:by - Union (right wins on conflict)
%+  ~(uni by (my ~[[%a 1]]))
(my ~[[%a 10] [%b 2]])
::  {[%a 10] [%b 2]}

::  ++  int:by - Intersection (left values kept)
%+  ~(int by (my ~[[%a 1] [%b 2]]))
(my ~[[%b 20] [%c 3]])
::  {[%b 2]}

::  ++  dif:by - Difference
%+  ~(dif by (my ~[[%a 1] [%b 2]]))
(my ~[[%b 20]])
::  {[%a 1]}
```

## 5. Text Processing (Section 4)

### Cord/Tape Conversion

```hoon
::  ++  trip - Cord → tape
(trip 'hello')  ::  "hello"

::  ++  crip - Tape → cord
(crip "hello")  ::  'hello'

::  ++  cass - Lowercase
(cass "HELLO")  ::  "hello"

::  ++  cuss - Uppercase
(cuss "hello")  ::  "HELLO"
```

### String Utilities

```hoon
::  ++  cat - Concatenate atoms
(cat 3 'hello ' 'world')  ::  'hello world'
::  3 = byte (UTF-8) granularity

::  ++  cut - Extract slice from atom
(cut 3 [0 5] 'hello world')  ::  'hello'

::  ++  end - Take last N bits/bytes (modern 2-arg bite syntax)
(end [3 5] 'hello world')  ::  'hello'

::  ++  met - Measure size
(met 3 'hello')  ::  5 (bytes)

::  ++  rap - Join list of atoms
(rap 3 ~['a' 'b' 'c'])  ::  'abc'

::  ++  rip - Split atom into list
(rip 3 'abc')  ::  ~['a' 'b' 'c']
```

### Number Formatting

```hoon
::  ++  scot - Atom → cord (with aura)
(scot %ud 42)    ::  '42'
(scot %ux 42)    ::  '0x2a'
(scot %p 42)     ::  '~nec'
(scot %da now)   ::  '~2024.1.15..12.30.00'

::  ++  scow - Atom → tape (with aura)
(scow %ud 42)    ::  "42"

::  ++  slaw - Cord → atom (parse with aura)
(slaw %ud '42')  ::  `42
(slaw %ud 'abc') ::  ~

::  ++  slat - Parser for aura
=/  parse-num  (slat %ud)
(parse-num '42')  ::  `42

::  ++  slav - Parse or crash
(slav %ud '42')  ::  42

::  ++  slay - General parse
(slay '~sampel-palnet')  ::  [~ [%p 1.624.961.343]]
```

### Formatting Helpers (`co` core)

```hoon
::  ++  a-co:co - @ud → tape
(a-co:co 42)  ::  "42"

::  ++  r-co:co - Render floating-point or formatted number to tape
::  Used internally by the co core for rendering

::  ++  v-co:co - @uv → tape
(v-co:co `@uv`42)  ::  "0v2a"
```

## 6. Arithmetic (Section 1)

### Basic Operations

```hoon
::  ++  add - Addition
(add 2 3)  ::  5

::  ++  sub - Subtraction
(sub 10 3)  ::  7

::  ++  mul - Multiplication
(mul 4 5)  ::  20

::  ++  div - Division (integer)
(div 10 3)  ::  3

::  ++  mod - Modulo
(mod 10 3)  ::  1

::  ++  dvr - Division with remainder
(dvr 10 3)  ::  [p=3 q=1]
```

### Comparison

```hoon
::  ++  gth - Greater than
(gth 5 3)  ::  %.y

::  ++  gte - Greater than or equal
(gte 5 5)  ::  %.y

::  ++  lth - Less than
(lth 3 5)  ::  %.y

::  ++  lte - Less than or equal
(lte 5 5)  ::  %.y

::  ++  max - Maximum
(max 5 3)  ::  5

::  ++  min - Minimum
(min 5 3)  ::  3
```

### Bit Operations

```hoon
::  ++  lsh - Left shift (modern 2-arg bite syntax)
(lsh [0 3] 1)  ::  8 (1 << 3)

::  ++  rsh - Right shift (modern 2-arg bite syntax)
(rsh [0 2] 8)  ::  2 (8 >> 2)

::  ++  con - Bitwise OR
(con 0b1100 0b1010)  ::  0b1110

::  ++  dis - Bitwise AND
(dis 0b1100 0b1010)  ::  0b1000

::  ++  mix - Bitwise XOR
(mix 0b1100 0b1010)  ::  0b0110

::  ++  not - Bitwise NOT (specific size, modern bite syntax)
(not 0 3 0b101)  ::  0b010
::  Note: 'not' still uses 3-argument syntax
```

## 7. Parsing (Section 5)

### Core Parsers

```hoon
::  ++  ace - Space
(scan " " ace)  ::  ' '

::  ++  bar - | character
(scan "|" bar)  ::  '|'

::  ++  cab - _ character
(scan "_" cab)  ::  '_'

::  ++  cen - % character
(scan "%" cen)  ::  '%'

::  ++  col - : character
(scan ":" col)  ::  ':'

::  ++  tar - * character
(scan "*" tar)  ::  '*'

::  ++  gap - Whitespace (1+ spaces/newlines)
(scan "   " gap)  ::  ~ (produces null)

::  ++  gon - Matches backslash-newline-slash sequence
::  Used in tall-form Hoon parsing, NOT general whitespace

::  ++  prn - Printable character
(scan "a" prn)  ::  'a'

::  ++  dem - Decimal number
(scan "42" dem)  ::  42

::  ++  hex - Hexadecimal number
(scan "2a" hex)  ::  42

::  ++  sym - Symbol
(scan "hello" sym)  ::  %hello
```

### Parser Combinators

```hoon
::  ++  just - Match exact character
(scan "a" (just 'a'))  ::  'a'

::  ++  jest - Match exact string
(scan "hello" (jest 'hello'))  ::  'hello'

::  ++  shim - Match character in range
(scan "5" (shim '0' '9'))  ::  '5'

::  ++  star - 0 or more
(scan "aaaa" (star (just 'a')))  ::  "aaaa"

::  ++  plus - 1 or more
(scan "aaa" (plus (just 'a')))  ::  "aaa"

::  ++  stir - Fold with parser
::  dem parses complete decimal numbers, so each parse consumes "123" as 123
(scan "123" (stir 0 add dem))  ::  123

::  ++  cook - Transform result
(scan "42" (cook |=(n=@ud (mul n 2)) dem))  ::  84

::  ++  ifix - Parse between delimiters
(scan "(hello)" (ifix [pal par] (star prn)))  ::  "hello"

::  ++  plug - Sequence (tuple)
(scan "ab" ;~(plug (just 'a') (just 'b')))  ::  ['a' 'b']

::  ++  pose - Alternative
(scan "a" ;~(pose (just 'a') (just 'b')))  ::  'a'

::  ++  glue - Sequence with separator
(scan "a,b" ;~((glue com) (just 'a') (just 'b')))  ::  ['a' 'b']
```

## 8. Utilities

### Maybe (Unit) Operations

```hoon
::  ++  need - Extract or crash
(need `42)  ::  42
(need ~)    ::  Crash

::  ++  bind - Map over unit
(bind `42 |=(n=@ud (mul n 2)))  ::  `84

::  ++  fall - Default value
(fall `42 0)  ::  42
(fall ~ 0)    ::  0

::  ++  some - Wrap in unit
(some 42)  ::  `42
```

### Hashing and Crypto

```hoon
::  ++  mug - 32-bit hash
(mug 'hello')  ::  3.736.752.863

::  ++  sham - 128-bit noun hash (@uvH)
(sham 'hello')  ::  @uvH hash

::  ++  shax - SHA-256 hash
(shax 'hello')  ::  @ux hash

::  ++  shas - Salted hash (NOT HMAC)
(shas 'key' 'message')  ::  @ux

::  ++  shal - SHA-512 hash (takes length and data)
(shal (met 3 'hello') 'hello')  ::  @ux
```

## 9. Finding Functions

### By Task

**Need to process lists?** → Section 2a-2d
**Need sets or maps?** → Section 2h
**Need text manipulation?** → Section 4b-4m
**Need parsing?** → Section 5a-5d
**Need math?** → Section 1a-1c

### Search Strategies

1. **Browse stdlib docs**: https://docs.urbit.org/language/hoon/reference/stdlib
2. **Search in hoon.hoon**: `/sys/hoon.hoon`
3. **Check section headers**: Look for `+|` comments
4. **Ask in ~bitbet-bolbel/urbit-community**

## 10. Common Patterns

### Pattern 1: Safe List Access

```hoon
:: the list constructor, limo, turns a null-terminated tuple into a list.
=/  items  (limo ~[1 2 3])
:: validate a list to be not empty before i, the head indicator, or t the tail indicator can be used
=/  first  ?~(items ~ `i.items)  ::  Safe head
=/  at-idx  (snag 5 items)       ::  Crashes if out of bounds

::  Better:
++  safe-snag
  |=  [idx=@ud items=(list)]
  ^-  (unit _?>(?=(^ items) i.items))
  ?:  (gte idx (lent items))  ~
  `(snag idx items)
```

### Pattern 2: Map Lookup with Fallback

```hoon
=/  config  (my ~[[%timeout ~s30] [%retries 3]])
=/  timeout  (~(gut by config) %timeout ~s10)
```

### Pattern 3: Parse and Process

```hoon
=/  input  "42"
=/  parsed  (rush input dem)
?~  parsed
  'Invalid number'
(process-number u.parsed)
```

## Resources

- [Standard Library Reference](https://docs.urbit.org/language/hoon/reference/stdlib) - Full documentation
- [Stdlib Source](https://github.com/urbit/urbit/blob/master/pkg/arvo/sys/hoon.hoon) - Read the source
- [Jets List](https://docs.urbit.org/language/hoon/reference/stdlib/jets) - Performance-critical functions

## Summary

The Hoon standard library provides:
1. **Comprehensive list operations** - map, filter, fold, sort
2. **Set and map functions** - efficient lookups and set operations
3. **Text processing** - conversion, formatting, parsing
4. **Arithmetic and logic** - basic math, comparisons, bit ops
5. **Parsing combinators** - build complex parsers
6. **Utilities** - hashing, crypto, maybe operations

Learning the stdlib enables writing concise, idiomatic Hoon code.
