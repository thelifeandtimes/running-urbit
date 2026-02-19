---
name: parsing
description: Master parser combinators in Hoon including core parsers (ace, prn, dem, hex), combinators (star, plus, plug, pose, cook), building custom parsers, and parsing real-world formats. Use when processing user input, implementing DSLs, parsing structured data, or handling complex grammars.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Parsing Skill

Master parser combinators, building custom parsers, handling complex grammars, and parsing real-world formats in Hoon. Use when processing user input, implementing DSLs, or parsing structured data.

## Overview

Hoon uses parser combinators to build composable parsers. This skill covers core parsers, combinators, building custom parsers, and practical parsing patterns.

## Learning Objectives

1. Understand parser combinator fundamentals
2. Use built-in parsers effectively
3. Combine parsers with combinators
4. Build custom parsers for specific formats
5. Handle parsing errors gracefully
6. Parse real-world data formats

## 1. Parser Fundamentals

### What is a Parser?

A parser is a `rule` that consumes input and produces a result:

```hoon
::  +$rule is a gate from nail to edge: _|:($:nail $:edge)
+$  hair  [p=@ud q=@ud]  ::  Line and column
+$  nail  [p=hair q=tape]  ::  Position and remaining input
+$  edge  [p=hair q=(unit [p=* q=nail])]  ::  Parse result
```

### Running Parsers

```hoon
::  scan - Parse entire input or crash
(scan "hello" (star prn))  ::  "hello"
(scan "hello" dem)  ::  Crash (not a number)

::  rush - Parse entire input, return unit
(rush "42" dem)  ::  `42
(rush "abc" dem)  ::  ~

::  rash - Parse entire input or crash (for cords)
(rash '42' dem)  ::  42

::  rust - Parse entire input, return unit (for cords)
(rust '42' dem)  ::  `42
```

## 2. Core Parsers

### Character Parsers

```hoon
::  ace - Space
(scan " " ace)  ::  ' '

::  prn - Printable character
(scan "a" prn)  ::  'a'
(scan "Z" prn)  ::  'Z'

::  alf - Alphabetic
(scan "a" alf)  ::  'a'
(scan "5" alf)  ::  Crash

::  nud - Numeric digit
(scan "5" nud)  ::  '5'

::  low - Lowercase
(scan "a" low)  ::  'a'

::  hig - Uppercase
(scan "A" hig)  ::  'A'

::  alp - Alphanumeric AND hyphens
(scan "a" alp)  ::  'a'
(scan "5" alp)  ::  '5'
(scan "-" alp)  ::  '-'
```

### Whitespace Parsers

```hoon
::  gap - Whitespace (1+)
(scan "   " gap)  ::  ~ (produces null)

::  gon - Matches backslash-newline-slash sequence
::  Used in tall-form Hoon parsing, NOT general whitespace
```

### Number Parsers

```hoon
::  dem - Decimal number
(scan "42" dem)  ::  42
(scan "0" dem)  ::  0

::  hex - Hexadecimal
(scan "2a" hex)  ::  42
(scan "ff" hex)  ::  255

```

### Text Parsers

```hoon
::  sym - Symbol (%foo)
(scan "hello" sym)  ::  %hello

::  urs - Knot parser (inside the +so core, not top-level)
::  Access as urs:so
(scan "hello" urs:so)  ::  ~.hello
```

## 3. Parser Combinators

### Exact Match

```hoon
::  just - Match exact character
(scan "a" (just 'a'))  ::  'a'
(scan "b" (just 'a'))  ::  Crash

::  jest - Match exact string
(scan "hello" (jest 'hello'))  ::  'hello'
(scan "world" (jest 'hello'))  ::  Crash

::  shim - Match character in range
(scan "5" (shim '0' '9'))  ::  '5'
(scan "a" (shim 'a' 'z'))  ::  'a'
```

### Repetition

```hoon
::  star - Zero or more
(scan "" (star prn))  ::  ""
(scan "aaa" (star (just 'a')))  ::  "aaa"

::  plus - One or more
(scan "a" (plus (just 'a')))  ::  "a"
(scan "" (plus (just 'a')))  ::  Crash

::  stir - Fold while parsing
::  dem parses complete decimal numbers, so "123" is parsed as 123
(scan "123" (stir 0 add dem))  ::  123
```

### Sequence and Choice

```hoon
::  plug - Sequence (and)
(scan "ab" ;~(plug (just 'a') (just 'b')))  ::  ['a' 'b']

::  pose - Choice (or)
(scan "a" ;~(pose (just 'a') (just 'b')))  ::  'a'
(scan "b" ;~(pose (just 'a') (just 'b')))  ::  'b'

::  glue - Sequence with separator
(scan "a,b" ;~((glue com) (just 'a') (just 'b')))  ::  ['a' 'b']

::  pfix - Parse and discard prefix
(scan "  hello" ;~(pfix gap (star prn)))  ::  "hello"

::  sfix - Parse and discard suffix
(scan "hello  " ;~(sfix (star prn) gap))  ::  "hello"
```

### Transformation

```hoon
::  cook - Transform result
(scan "42" (cook |=(n=@ud (mul n 2)) dem))  ::  84

::  stag - Tag result
(scan "42" (stag %number dem))  ::  [%number 42]

::  sear - Transform with unit (can fail)
++  even-only
  |=  n=@ud
  ^-  (unit @ud)
  ?:  =(0 (mod n 2))  `n  ~

(scan "42" (sear even-only dem))  ::  `42
(scan "43" (sear even-only dem))  ::  Crash (sear returns ~)
```

### Delimiters

```hoon
::  ifix - Parse between delimiters
(scan "(hello)" (ifix [pal par] (star prn)))  ::  "hello"
(scan "[42]" (ifix [sel ser] dem))  ::  42
(scan "\"text\"" (ifix [doq doq] (star prn)))  ::  "text"
```

## 4. Building Custom Parsers

### Simple Custom Parser

```hoon
::  Parse email address (simplified)
++  email
  ;~  plug
    (plus ;~(pose alf nud (just '-') (just '.')))
    (jest '@')
    (plus ;~(pose alf nud (just '-') (just '.')))
  ==

(scan "user@example.com" email)
::  ["user" '@' "example.com"]
```

### Recursive Parser

```hoon
::  Parse nested parentheses
++  parens
  %+  knee  *tape  |.  ~+
  ;~  pose
    ;~(plug pal parens par)
    (easy ~)
  ==

(scan "(())" parens)
```

### Stateful Parser

```hoon
::  Count characters while parsing
++  counted
  =/  count  0
  |=  input=tape
  ^-  [count=@ud result=tape]
  =/  result
    %+  scan  input
    %+  stir  [0 *tape]
    |=  [acc=[count=@ud text=tape] char=@t]
    [(add count.acc 1) (weld text.acc ~[char])]
    prn
  result
```

## 5. Practical Parsers

### URL Parser

```hoon
++  url-parser
  ;~  plug
    ::  Scheme
    ;~  sfix
      ;~  pose
        (jest 'http')
        (jest 'https')
      ==
      (jest '://')
    ==
    ::  Host
    (star ;~(pose alf nud (just '.') (just '-')))
    ::  Optional port
    ;~  pose
      ;~(pfix col dem)
      (easy 80)
    ==
    ::  Path
    (star ;~(pfix fas (star ;~(less fas prn))))
  ==

(scan "https://example.com:8080/path/to/resource" url-parser)
```

### JSON Parser (Simplified)

```hoon
++  json-value
  %+  knee  *json  |.  ~+
  ;~  pose
    json-null
    json-bool
    json-number
    json-string
    json-array
    json-object
  ==

++  json-null
  (cold ~ (jest 'null'))

++  json-bool
  ;~  pose
    (cold %.y (jest 'true'))
    (cold %.n (jest 'false'))
  ==

++  json-number
  (stag %n (cook |=(n=@ud (scot %ud n)) dem))

++  json-string
  %+  stag  %s
  (ifix [doq doq] (star ;~(less doq prn)))

++  json-array
  %+  stag  %a
  %+  ifix  [sel ser]
  %+  more  (ifix [. gon .] com)
  json-value

++  json-object
  %+  stag  %o
  %+  ifix  [kel ker]
  %-  my
  %+  more  (ifix [gon gon] com)
  ;~  plug
    (ifix [doq doq] (star ;~(less doq prn)))
    ;~(pfix col json-value)
  ==
```

### CSV Parser

```hoon
++  csv-field
  ;~  pose
    ::  Quoted field
    (ifix [doq doq] (star ;~(less doq prn)))
    ::  Unquoted field
    (star ;~(less ;~(pose com (just '\n')) prn))
  ==

++  csv-row
  (more com csv-field)

++  csv-file
  (more (just '\n') csv-row)

(scan "name,age,city\nAlice,30,NYC\nBob,25,LA" csv-file)
::  ~[~["name" "age" "city"] ~["Alice" "30" "NYC"] ~["Bob" "25" "LA"]]
```

### Command Parser

```hoon
++  command
  ;~  plug
    ::  Command name
    (star alf)
    ::  Arguments
    (star ;~(pfix ace (star ;~(less ace prn))))
  ==

(scan "create user alice" command)
::  ["create" ~["user" "alice"]]
```

## 6. Error Handling

### Providing Context

```hoon
++  parse-with-context
  |=  input=tape
  ^-  (unit @ud)
  =/  result
    (rush input dem)
  ?~  result
    ~&  >>>  "Failed to parse number from: {<input>}"
    ~
  result
```

### Try Multiple Parsers

```hoon
++  flexible-number
  ;~  pose
    dem          ::  Try decimal
    (cook |=(h=@ux `@ud`h) hex)  ::  Try hex
    (easy 0)     ::  Default to 0
  ==

(scan "42" flexible-number)    ::  42
(scan "2a" flexible-number)    ::  42
(scan "xyz" flexible-number)   ::  0
```

### Partial Parsing

```hoon
::  Parse as much as possible
++  partial-parse
  |=  input=tape
  ^-  [@ud tape]  ::  [parsed-number remaining-input]
  =/  result
    %+  scan  input
    ;~  plug
      dem
      (star prn)
    ==
  result

(partial-parse "42 extra text")  ::  [42 " extra text"]
```

## 7. Advanced Patterns

### Left-Recursive Grammar

```hoon
::  Expression parser (avoids left recursion)
++  expr
  %+  knee  *@ud  |.  ~+
  ;~  pose
    ::  Number
    dem
    ::  Addition
    ;~  plug
      dem
      ;~(pfix (just '+') expr)
    ==
  ==
```

### Whitespace Handling

```hoon
++  token
  |*  parser=rule
  ;~(sfix parser gon)

++  expression
  ;~  plug
    (token dem)
    (token (just '+'))
    (token dem)
  ==

(scan "  42  +  10  " expression)  ::  [42 '+' 10]
```

### Comments

```hoon
++  line-comment
  ;~(pfix (jest '::') (star ;~(less (just '\n') prn)))

++  with-comments
  |*  parser=rule
  ;~  pose
    parser
    ;~(sfix line-comment parser)
  ==
```

## 8. Testing Parsers

### Unit Tests

```hoon
++  test-email-parser
  =/  tests
    :~  ["user@example.com" %.y]
        ["invalid" %.n]
        ["@example.com" %.n]
        ["user@" %.n]
    ==
  %+  turn  tests
  |=  [input=tape expected=?]
  =/  result  (rush input email)
  ?.  ?=(^ result)  =(expected %.n)
  =(expected %.y)
```

### Property Testing

```hoon
++  test-number-roundtrip
  |=  n=@ud
  ^-  ?
  =/  text  (a-co:co n)
  =/  parsed  (scan text dem)
  =(n parsed)
```

## 9. Performance Considerations

### Memoization with `~+`

```hoon
::  Cache parser results
++  expensive-parser
  %+  knee  *result  |.  ~+
  (complex-parsing-logic)
```

### Avoiding Backtracking

```hoon
::  ✗ Bad: Excessive backtracking
;~  pose
  (jest 'hello world')
  (jest 'hello')
==

::  ✓ Good: Factor common prefix
;~  plug
  (jest 'hello')
  ;~  pose
    (jest ' world')
    (easy ~)
  ==
==
```

## 10. Common Parsing Patterns

### Pattern 1: Key-Value Pairs

```hoon
++  key-value
  ;~  plug
    (star alf)
    ;~(pfix (just '=') (star prn))
  ==

++  config-file
  (more (just '\n') key-value)
```

### Pattern 2: Lists

```hoon
++  comma-list
  %+  more  com
  (star ;~(less com prn))

(scan "a,b,c,d" comma-list)  ::  ~["a" "b" "c" "d"]
```

### Pattern 3: Nested Structures

```hoon
++  s-expr
  %+  knee  *s-expr  |.  ~+
  ;~  pose
    ::  Atom
    (stag %atom (star ;~(less ;~(pose pal par ace) prn)))
    ::  List
    (stag %list (ifix [pal par] (star ;~(sfix s-expr gon))))
  ==
```

### Pattern 4: Normalizing Duplicate Parsers

When two `;~ pose` parsers match identical input but produce different
intermediate tuples (e.g., one for direct use, one for cooking into a typed
AST), unify them by normalizing the intermediate form.

**Problem**: two parsers for qualified names with different output shapes:
```hoon
::  Parser A: preserves raw dots for double-dot syntax
;~(plug sym dot ;~(pfix dot sym) ;~(pfix dot sym))
::  output: [db '.' obj col]  -- ambiguous: is '.' a namespace or a gap?

::  Parser B: uses ~ for missing parts
;~(plug sym (cold ~ dot) ;~(pfix dot sym) ;~(pfix dot sym))
::  output: [db ~ obj col]  -- clear: namespace is missing
```

**Solution**: use `(cold ~ dot)` and `(stag ~)` to normalize missing parts
into `~`, then use `?~` in the cook function:

```hoon
++  parse-name  ~+
  ;~  pose
    ;~((glue dot) sym sym sym sym)                 ::  [db ns obj col]
    ;~(plug sym (cold ~ dot) ;~(pfix dot sym) ;~(pfix dot sym))
    ::                                                [db ~  obj col]
    (stag ~ ;~((glue dot) sym sym sym))            ::  [~  ns obj col]
    ;~(plug mixed-case-symbol ;~(pfix dot sym))    ::  [alias col]
    sym                                             ::  col
  ==

++  cook-name
  |=  a=*
  ?:  ?=([@ @ @ @] a)
    ::  4-item: db or ns may be ~
    [?~(-.a default-db -.a) ?~(+<.a 'dbo' +<.a) +>-.a +>+.a]
  ...
```

This eliminates the need for fragile `?:  =(+<.a '.')` disambiguation
and ensures a single source of truth for the parsing patterns.

## Resources

- [Parsing Guide](https://developers.urbit.org/guides/core/hoon-school/J-stdlib-text) - Hoon School parsing
- [Parser Reference](https://docs.urbit.org/language/hoon/reference/stdlib/4f) - Standard library parsers
- [Rule Builders](https://docs.urbit.org/language/hoon/reference/stdlib/4e) - Combinator reference

## Summary

Hoon parsing:
1. **Parser combinators** - Compose small parsers into complex ones
2. **Core parsers** - Characters, numbers, whitespace
3. **Combinators** - Sequence, choice, repetition, transformation
4. **Custom parsers** - Build domain-specific parsers
5. **Error handling** - Graceful failures, context
6. **Real-world formats** - JSON, CSV, URLs, commands
7. **Performance** - Memoization, avoid backtracking
8. **Testing** - Unit and property tests

Mastering parser combinators enables building robust input processors and DSLs in Hoon.
