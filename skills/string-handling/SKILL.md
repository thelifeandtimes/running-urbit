---
name: string-handling
description: Master Hoon string types (cord @t, tape, term @tas, knot @ta), text manipulation, parsing, formatting, and conversions between types. Use when processing text, building UIs, parsing input, formatting output, or working with text data.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# String Handling Skill

Master Hoon string types (cord, tape, term, knot), text manipulation, parsing, formatting, and conversions. Use when processing text, building UIs, parsing input, or formatting output.

## Overview

Hoon has multiple string types optimized for different use cases. This skill covers cord (@t), tape, term (@tas), knot (@ta), text operations, and conversions between types.

## Learning Objectives

1. Understand Hoon's string type system
2. Choose appropriate string types for tasks
3. Convert between string types
4. Manipulate and transform text
5. Parse and validate strings
6. Format output and build strings
7. Optimize string operations

## 1. String Types

### Cord (`@t`)

**Atom (unsigned integer)** interpreted as UTF-8 text:
```hoon
'hello'              ::  @t cord
'Hello, world!'      ::  Multi-word
'emoji: 🚀'          ::  UTF-8 support

::  Cords are atoms
`@ud`'hello'         ::  478,560,413,032 (underlying number)
```

**Properties**:
- Immutable
- Efficient storage (single atom)
- O(1) comparison
- UTF-8 encoded
- Awkward to manipulate character-by-character

**Best for**: Storage, network transmission, identifiers

### Tape (`(list @t)`)

**List of single-character cords**:
```hoon
"hello"              ::  tape
~['h' 'e' 'l' 'l' 'o']  ::  Same

::  Head is first character
=/  t  "hello"
i.t                  ::  'h'
t.t                  ::  "ello"
```

**Properties**:
- Mutable structure (new lists)
- Easy character manipulation
- O(n) length, concatenation
- Can use list functions

**Best for**: Text processing, character manipulation, parsing

### Term (`@tas`)

**Symbol/constant**, URL-safe ASCII:
```hoon
%hello               ::  @tas term
%my-constant         ::  Hyphens allowed
%foo-bar-123         ::  Numbers allowed

::  Used for tags, actions, identifiers
%success
%error
%user-logged-in
```

**Properties**:
- Must start with lowercase letter
- Only lowercase, numbers, hyphen
- No spaces or special characters
- Efficient comparison

**Best for**: Tags, action types, constants, enum values

### Knot (`@ta`)

**URL-safe ASCII text**:
```hoon
~.hello              ::  @ta knot
~.my-url-safe-string
~.foo_bar            ::  Underscore allowed

::  Used in URLs and paths
/web/~.my-page
```

**Properties**:
- URL-safe subset of ASCII
- More flexible than term
- No spaces

**Best for**: URLs, paths, file names

## 2. String Conversions

### Cord ↔ Tape

```hoon
::  Cord → Tape (trip)
(trip 'hello')       ::  "hello"

::  Tape → Cord (crip)
(crip "hello")       ::  'hello'

::  Examples
=/  text  'Hello, world!'
=/  chars  (trip text)
(lent chars)         ::  13

=/  chars  "abc"
=/  text  (crip chars)
text                 ::  'abc'
```

### Term ↔ Tape

```hoon
::  Term → Tape
(trip %hello)        ::  "hello"

::  Tape → Term (via parser)
(scan "hello" sym)   ::  %hello
```

### Knot ↔ Tape

```hoon
::  Knot → Tape
(trip ~.hello)       ::  "hello"

::  Tape → Knot
`@ta`(crip "hello")  ::  ~.hello
```

### Number → String

```hoon
::  Number → Tape
(a-co:co 42)         ::  "42"

::  Number → Cord (via scot)
(scot %ud 42)        ::  '42'
(scot %ux 42)        ::  '0x2a'
(scot %p 42)         ::  '~nec'

::  Specific formatting
=/  num  255
(a-co:co num)        ::  "255" (decimal)
::  For hex/binary display, use scot:
(scot %ux num)       ::  '0xff'
(scot %ub num)       ::  '0b1111.1111'
```

### String → Number

```hoon
::  Tape → Number (via parser)
(scan "42" dem)      ::  42
(scan "2a" hex)      ::  42  :: hex parser doesn't handle 0x prefix

::  Cord → Number (via parser)
(rash '42' dem)      ::  42

::  Safe parsing (returns unit)
(rush '42' dem)      ::  `42
(rush 'abc' dem)     ::  ~
```

## 3. String Manipulation

### Concatenation

```hoon
::  Tape concat (weld)
(weld "hello " "world")  ::  "hello world"

::  Cord concat (cat)
(cat 3 'hello ' 'world')  ::  'hello world'
::  3 = UTF-8 byte granularity

::  Multiple tapes
:(weld "a" "b" "c")      ::  "abc"

::  Build cord from tapes
(crip (weld "hello " "world"))  ::  'hello world'

::  Dot syntax: adjacent tape literals separated by .
::  Each literal except the last ends with a dot.
::  Equivalent to weld but more readable for long strings.
"hello "."world"              ::  "hello world"

"INSERT INTO calendar ".      ::  multi-line form
"VALUES ".                    ::  (each non-final line ends with .)
"(~2023.12.21, 2023, 12)"     ::  final line has no dot
```

### Substrings

```hoon
::  Take first N characters
(scag 5 "hello world")   ::  "hello"

::  Drop first N characters
(slag 6 "hello world")   ::  "world"

::  Take last N
(scag 5 (flop "hello world"))  ::  "dlrow"

::  Slice (start, length)
++  slice
  |=  [start=@ud len=@ud text=tape]
  (scag len (slag start text))

(slice 6 5 "hello world")  ::  "world"
```

### Case Conversion

```hoon
::  Lowercase
(cass "HELLO")       ::  "hello"
(cass "HeLLo")       ::  "hello"

::  Uppercase
(cuss "hello")       ::  "HELLO"
(cuss "HeLLo")       ::  "HELLO"
```

### Trimming

```hoon
::  Trim leading whitespace
++  trim-left
  |=  text=tape
  ^-  tape
  ?~  text  ~
  ?:  =(' ' i.text)
    $(text t.text)
  text

::  Trim trailing whitespace
++  trim-right
  |=  text=tape
  (flop (trim-left (flop text)))

::  Trim both
++  trim
  |=  text=tape
  (trim-right (trim-left text))

(trim "  hello  ")   ::  "hello"
```

### Splitting

```hoon
::  Split on character
++  split-on
  |=  [delim=@t text=tape]
  ^-  (list tape)
  =/  acc  *(list tape)
  =/  current  *tape
  |-
  ?~  text
    (flop [(flop current) acc])
  ?:  =(i.text delim)
    $(text t.text, acc [(flop current) acc], current ~)
  $(text t.text, current [i.text current])

(split-on ',' "a,b,c")  ::  ~["a" "b" "c"]

::  Split on whitespace
++  words
  |=  text=tape
  ^-  (list tape)
  (rash text (more ace (star prn)))

(words "hello world foo")  ::  ~["hello" "world" "foo"]
```

### Joining

```hoon
::  Join list of tapes with delimiter
++  join
  |=  [delim=tape parts=(list tape)]
  ^-  tape
  ?~  parts  ~
  ?~  t.parts  i.parts
  :(weld i.parts delim $(parts t.parts))

(join ", " ~["a" "b" "c"])  ::  "a, b, c"
```

### Search and Replace

```hoon
::  Check if substring exists
++  contains
  |=  [needle=tape haystack=tape]
  ^-  ?
  ?~  haystack  %.n
  ?:  =(needle (scag (lent needle) haystack))
    %.y
  $(haystack t.haystack)

(contains "world" "hello world")  ::  %.y

::  Replace first occurrence
++  replace-first
  |=  [old=tape new=tape text=tape]
  ^-  tape
  =/  len  (lent old)
  |-  ^-  tape
  ?~  text  ~
  ?:  =(old (scag len text))
    (weld new (slag len text))
  [i.text $(text t.text)]

(replace-first "world" "universe" "hello world")  ::  "hello universe"

::  Replace all occurrences
++  replace-all
  |=  [old=tape new=tape text=tape]
  ^-  tape
  =/  len  (lent old)
  |-  ^-  tape
  ?~  text  ~
  ?:  =(old (scag len text))
    (weld new $(text (slag len text)))
  [i.text $(text t.text)]
```

## 4. String Formatting

### Interpolation Pattern

```hoon
::  Tape interpolation (manual)
=/  name  "Alice"
=/  age  30
:(weld "Hello, " name "! You are " (a-co:co age) " years old.")

::  Cord interpolation
%+  cat  3
  'Hello, '
%+  cat  3
  (crip name)
'!'

::  Helper for common pattern
++  format
  |=  parts=(list cord)
  ^-  cord
  %+  roll  parts
  |=([part=cord acc=cord] (cat 3 acc part))

(format ~['Hello, ' (crip name) '!'])
```

### Number Formatting

```hoon
::  Decimal with separators
++  format-number
  |=  n=@ud
  ^-  tape
  =/  str  (a-co:co n)
  =/  len  (lent str)
  =/  mod  (mod len 3)
  ::  Add commas every 3 digits
  ...

::  Padding
++  pad-left
  |=  [width=@ud char=@t text=tape]
  ^-  tape
  =/  len  (lent text)
  ?:  (gte len width)  text
  (weld (reap (sub width len) char) text)

(pad-left 5 '0' "42")  ::  "00042"

::  Percentage
++  percentage
  |=  [value=@ud total=@ud]
  ^-  tape
  =/  pct  (div (mul value 100) total)
  (weld (a-co:co pct) "%")

(percentage 1 4)  ::  "25%"
```

### Template Rendering

```hoon
::  Simple template with placeholders
++  render-template
  |=  [template=tape vars=(map @tas tape)]
  ^-  tape
  ::  Replace {{key}} with values
  =/  result  *tape
  =/  mode  %text
  |-  ^-  tape
  ?~  template  (flop result)
  ?:  =(%text mode)
    ?:  =("{{" (scag 2 template))
      $(template (slag 2 template), mode %var)
    $(template t.template, result [i.template result])
  ::  %var mode
  ?:  =("}}" (scag 2 template))
    ::  End of variable, look up and insert
    ...
  $(template t.template)
```

## 5. String Validation

### Common Validators

```hoon
::  Email validation (simplified)
++  is-valid-email
  |=  email=tape
  ^-  ?
  =/  at-pos  (find "@" email)
  ?~  at-pos  %.n
  =/  dot-pos  (find "." (slag u.at-pos email))
  ?~  dot-pos  %.n
  &((gth u.at-pos 0) (gth u.dot-pos 1))

::  URL validation (basic)
++  is-url
  |=  url=tape
  ^-  ?
  ?|  =(~['http://'] (scag 7 url))
      =(~['https://'] (scag 8 url))
  ==

::  Alphanumeric only
++  is-alphanumeric
  |=  text=tape
  ^-  ?
  %+  levy  text
  |=  c=@t
  ?|  &((gte c 'a') (lte c 'z'))
      &((gte c 'A') (lte c 'Z'))
      &((gte c '0') (lte c '9'))
  ==

::  Length validation
++  valid-length
  |=  [min=@ud max=@ud text=tape]
  ^-  ?
  =/  len  (lent text)
  &((gte len min) (lte len max))
```

## 6. Advanced String Operations

### Levenshtein Distance

```hoon
::  Edit distance between strings
++  levenshtein
  |=  [a=tape b=tape]
  ^-  @ud
  ?~  a  (lent b)
  ?~  b  (lent a)
  ?:  =(i.a i.b)
    $(a t.a, b t.b)
  %+  add  1
  %+  min
    $(a t.a)
  %+  min
    $(b t.b)
  $(a t.a, b t.b)
```

### String Similarity

```hoon
::  Jaccard similarity (character n-grams)
++  similarity
  |=  [a=tape b=tape n=@ud]
  ^-  @rd
  =/  a-grams  (ngrams n a)
  =/  b-grams  (ngrams n b)
  =/  intersection  ~(wyt in (~(int in a-grams) b-grams))
  =/  union  ~(wyt in (~(uni in a-grams) b-grams))
  ?:  =(union 0)  .~0
  (div:rd (sun:rd intersection) (sun:rd union))
```

### Fuzzy Matching

```hoon
::  Find closest match in list
++  find-closest
  |=  [query=tape options=(list tape)]
  ^-  (unit tape)
  =/  best  *tape
  =/  best-dist  1.000.000
  |-  ^-  (unit tape)
  ?~  options  ?:(=(best-dist 1.000.000) ~ `best)
  =/  dist  (levenshtein query i.options)
  ?:  (lth dist best-dist)
    $(options t.options, best i.options, best-dist dist)
  $(options t.options)
```

## 7. Performance Optimization

### Cord vs Tape Trade-offs

```hoon
::  ✗ Bad: Convert repeatedly
++  process-bad
  |=  items=(list cord)
  %+  turn  items
  |=  item=cord
  =/  t  (trip item)
  =/  upper  (cuss t)
  (crip upper)

::  ✓ Good: Work in tape, convert once
++  process-good
  |=  items=(list cord)
  %+  turn  items
  |=  item=cord
  (crip (cuss (trip item)))
```

### String Building

```hoon
::  ✗ Bad: Repeated concatenation (O(n²))
++  build-bad
  |=  parts=(list tape)
  =/  result  *tape
  |-
  ?~  parts  result
  $(parts t.parts, result (weld result i.parts))

::  ✓ Good: Collect then weld once (O(n))
++  build-good
  |=  parts=(list tape)
  %-  zing
  parts
```

### Caching Conversions

```hoon
::  Cache converted strings
|_  $:  cache=(map cord tape)
        cord-input=cord
    ==
++  get-tape
  ^-  tape
  =/  cached  (~(get by cache) cord-input)
  ?^  cached  u.cached
  =/  converted  (trip cord-input)
  converted  ::  Could update cache here
--
```

## 8. Common Patterns

### Pattern 1: Parse and Validate

```hoon
++  parse-email
  |=  input=cord
  ^-  (unit [local=@t domain=@t])
  =/  text  (trip input)
  =/  at-pos  (find "@" text)
  ?~  at-pos  ~
  =/  local  (scag u.at-pos text)
  =/  domain  (slag +(u.at-pos) text)
  ?:  |((gth 1 (lent local)) (gth 3 (lent domain)))
    ~
  `[(crip local) (crip domain)]
```

### Pattern 2: Build Formatted Output

```hoon
++  format-user
  |=  user=[name=@t age=@ud email=@t]
  ^-  cord
  %-  crip
  :(weld (trip name.user) " (" (a-co:co age.user) ") - " (trip email.user))
```

### Pattern 3: Safe String Operations

```hoon
++  safe-substring
  |=  [start=@ud len=@ud text=tape]
  ^-  tape
  =/  max-start  (lent text)
  ?:  (gte start max-start)  ~
  =/  available  (sub max-start start)
  (scag (min len available) (slag start text))
```

## Resources

- [String Reference](https://docs.urbit.org/language/hoon/reference/stdlib/4b) - Cord/tape functions
- [Parsing Guide](https://docs.urbit.org/language/hoon/guides/parsing) - Text parsing
- [Formatting](https://docs.urbit.org/language/hoon/reference/stdlib/4j) - Number formatting

## Summary

Hoon string handling:
1. **Cord (@t)** - Efficient storage and transmission
2. **Tape** - Flexible character manipulation
3. **Term (@tas)** - Constants and tags
4. **Conversions** - trip/crip for cord↔tape
5. **Operations** - Split, join, replace, validate
6. **Performance** - Choose right type, minimize conversions
7. **Safety** - Validate input, handle edge cases

Mastering string types and operations enables robust text processing in Hoon applications.
