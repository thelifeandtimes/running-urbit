---
name: serialization
description: Master data serialization and deserialization in Hoon including JSON conversion, vases, jam/cue for nouns, and custom marks for type-safe data exchange. Use when handling external data, APIs, storage, inter-ship communication, or implementing data persistence.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Serialization Skill

Master data serialization and deserialization in Hoon including JSON, jammed nouns, marks, and custom formats. Use when handling external data, APIs, storage, or inter-ship communication.

## Overview

Hoon provides multiple serialization formats for different use cases: JSON for web APIs, jamming for efficient noun storage, and custom marks for type-safe data exchange.

## Learning Objectives

1. Convert between Hoon types and JSON
2. Use vases for runtime type information
3. Jam and cue nouns for storage/transmission
4. Design and implement custom marks
5. Handle serialization errors safely
6. Optimize serialization performance

## 1. JSON Serialization

### JSON Type

```hoon
+$  json
  $@  ~
  $%  [%a p=(list json)]         ::  Array
      [%b p=?]                    ::  Boolean
      [%n p=@ta]                  ::  Number (as text)
      [%o p=(map @t json)]        ::  Object
      [%s p=@t]                   ::  String
  ==
```

### Building JSON

```hoon
::  String
=/  str  [%s 'hello']

::  Number
=/  num  [%n '42']

::  Boolean
=/  bool-true   [%b %.y]
=/  bool-false  [%b %.n]

::  Null
~

::  Array
=/  arr  [%a ~[[%s 'a'] [%s 'b'] [%n '123']]]

::  Object
=/  obj
  :-  %o
  %-  my
  :~  ['name' [%s 'Alice']]
      ['age' [%n '30']]
      ['active' [%b %.y]]
  ==
```

### Encoding JSON to Text

```hoon
::  JSON → cord
(en:json:html obj)
::  '{"name":"Alice","age":30,"active":true}'
::  Note: en:json:html returns a cord (@t), not a tape
```

### Decoding JSON from Text

```hoon
::  Parse JSON from cord
=/  text  '{"name":"Alice","age":30}'
=/  parsed  (de:json:html text)
::  `json (parsed successfully)

::  Safe parsing with unit
?~  parsed
  ~&  "Failed to parse JSON"
  !!
u.parsed
```

### Converting Hoon → JSON

```hoon
::  Manual conversion
+$  user  [name=@t age=@ud active=?]

++  user-to-json
  |=  u=user
  ^-  json
  :-  %o
  %-  my
  :~  ['name' [%s name.u]]
      ['age' [%n (scot %ud age.u)]]
      ['active' [%b active.u]]
  ==

=/  alice  [name='Alice' age=30 active=%.y]
(user-to-json alice)
```

### Converting JSON → Hoon

```hoon
++  json-to-user
  |=  j=json
  ^-  (unit user)
  ?.  ?=([%o *] j)  ~
  =/  obj  p.j
  =/  name  (~(get by obj) 'name')
  ?~  name  ~
  ?.  ?=([%s *] u.name)  ~
  =/  age  (~(get by obj) 'age')
  ?~  age  ~
  ?.  ?=([%n *] u.age)  ~
  =/  age-num  (rush p.u.age dem)
  ?~  age-num  ~
  =/  active  (~(get by obj) 'active')
  ?~  active  ~
  ?.  ?=([%b *] u.active)  ~
  `[name=p.u.name age=u.age-num active=p.u.active]
```

### Using `dejs:format`

Standard library helpers for JSON decoding:

```hoon
=/  j  (need (de:json:html '{"x":5,"y":10}'))

::  Extract object
=,  dejs:format
=/  point
  %.  j
  %-  ot
  :~  [%x ni]  ::  Number
      [%y ni]  ::  Number
  ==
point  ::  [x=5 y=10]

::  Decoders
::  ni - number
::  so - string
::  bo - boolean
::  ot - object (specified keys)
::  of - tagged union
::  ar - array
::  at - array (tuple)
::  ou - object (optional keys)
```

### Using `enjs:format`

Standard library helpers for JSON encoding:

```hoon
=,  enjs:format
=/  json-obj
  %-  pairs
  :~  ['name' s+'Alice']
      ['age' (numb 30)]
      ['active' b+%.y]
      ['scores' a+~[(numb 10) (numb 20)]]
  ==

(en:json:html json-obj)
::  {"name":"Alice","age":30,"active":true,"scores":[10,20]}

::  Encoders
::  numb - number
::  pairs - object from list of key-json pairs
::  frond - single key-value object
::
::  Note: s+value, b+value, a+value are NOT enjs:format functions.
::  They are Hoon sugar for [%s value], [%b value], [%a value].
```

## 2. Vases (Runtime Types)

### What is a Vase?

A **vase** is a cell of type and value:
```hoon
+$  vase  [p=type q=*]  ::  [type noun]
```

### Creating Vases

```hoon
::  Wrap value with type (!>)
=/  v  !>([x=5 y=10])
p.v  ::  Type
q.v  ::  Noun (value)

::  Examples
!>(42)                     ::  [#t/@ud q=42]
!>('hello')                ::  [#t/@t q='hello']
!>(~[1 2 3])               ::  [#t/(list @ud) q=~[1 2 3]]
```

### Extracting from Vases

```hoon
::  Extract with type check (!<)
=/  v  !>([x=5 y=10])
!<([x=@ud y=@ud] v)        ::  [x=5 y=10]

::  Type mismatch crashes
!<(@t v)                   ::  CRASH: nest-fail

::  Safe extraction with try
=/  result
  %-  mule  |.
  !<(@t v)
?-  -.result
  %&  "Success: {<p.result>}"
  %|  "Error: type mismatch"
==
```

### Vase Operations

```hoon
::  Combine vases
++  vase-pair
  |=  [a=vase b=vase]
  ^-  vase
  !>([!<(* a) !<(* b)])

::  Map over vase
++  vase-map
  |=  [v=vase f=$-(* *)]
  ^-  vase
  !>((f !<(* v)))
```

## 3. Jam and Cue (Noun Serialization)

### Jamming Nouns

**Jam** serializes any noun to an atom:

```hoon
::  Jam (noun → atom)
(jam ~[1 2 3])             ::  Large atom
(jam [%hello 'world' 42])  ::  Encoded as atom

::  Vase + jam for typed serialization
(jam !>([x=5 y=10]))       ::  Includes type info
```

**Use cases**:
- Persistent storage
- Network transmission
- Caching

### Cueing Atoms

**Cue** deserializes atom back to noun:

```hoon
=/  original  [%data 'hello' 42]
=/  jammed  (jam original)
=/  restored  (cue jammed)
=(original restored)  ::  %.y

::  With vase
=/  original  !>([x=5 y=10])
=/  jammed  (jam original)
=/  restored  !<(vase (cue jammed))
```

### Jam/Cue Performance

```hoon
::  Jam is relatively expensive (tree traversal)
::  Cue is fast (single pass)

::  Good pattern: jam once, cue many times
=/  expensive-data  (build-big-structure)
=/  cached  (jam expensive-data)

::  Later, retrieve quickly
=/  data  (cue cached)
```

## 4. Marks (Type-Safe Serialization)

### What are Marks?

**Marks** are Urbit's MIME types with conversion rules:

```hoon
::  /mar/my-type.hoon
/-  *my-types
::
::::  Mark definition
::
|_  data=my-data
::
++  grab
  |%
  ++  noun  my-data       ::  From noun
  ++  json              ::  From JSON
    |=  j=json
    (json-to-my-data j)
  --
++  grow
  |%
  ++  noun  data          ::  To noun
  ++  json              ::  To JSON
    (my-data-to-json data)
  --
++  grad  %noun           ::  Revision control
--
```

### Example Mark Implementation

```hoon
::  /mar/user.hoon
+$  user  [name=@t age=@ud email=@t]
::
|_  u=user
++  grab
  |%
  ++  noun  user
  ++  json
    =,  dejs:format
    |=  j=json
    %.  j
    %-  ot
    :~  [%name so]
        [%age ni]
        [%email so]
    ==
  --
++  grow
  |%
  ++  noun  u
  ++  json
    =,  enjs:format
    %-  pairs
    :~  ['name' s+name.u]
        ['age' (numb age.u)]
        ['email' s+email.u]
    ==
  --
++  grad  %noun
--
```

### Using Marks

```hoon
::  In Gall agents
[%give %fact ~[/path] %user !>(user-data)]

::  Convert between marks
::  %user → %json (automatic conversion)
[%give %fact ~[/http-path] %json !>(user-json)]
```

## 5. Custom Serialization

### Binary Format

```hoon
::  Encode to bytes
++  encode-header
  |=  [version=@ud type=@ud length=@ud]
  ^-  @ux
  %+  can  3  ::  Concatenate bytes
  :~  [1 version]
      [1 type]
      [4 length]
  ==

::  Decode from bytes
++  decode-header
  |=  data=@ux
  ^-  [version=@ud type=@ud length=@ud]
  :-  (cut 3 [0 1] data)  ::  Byte 0
  :-  (cut 3 [1 1] data)  ::  Byte 1
  (cut 3 [2 4] data)      ::  Bytes 2-5
```

### CSV Format

```hoon
++  to-csv
  |=  rows=(list (list @t))
  ^-  @t
  %-  crip
  %+  join  "\n"
  %+  turn  rows
  |=  row=(list @t)
  (join "," (turn row trip))

++  from-csv
  |=  text=@t
  ^-  (list (list @t))
  =/  lines  (split-on '\n' (trip text))
  %+  turn  lines
  |=  line=tape
  (turn (split-on ',' line) crip)
```

### Protocol Buffers Style

```hoon
+$  message
  $:  tag=@ud
      wire-type=@ud
      value=*
  ==

++  encode-varint
  |=  n=@ud
  ^-  (list @ud)
  |-
  ?:  (lth n 128)  ~[n]
  [(add 128 (mod n 128)) $(n (div n 128))]

++  decode-varint
  |=  bytes=(list @ud)
  ^-  [@ud (list @ud)]  ::  [value rest]
  =/  acc  0
  =/  shift  0
  |-
  ?~  bytes  !!
  =/  byte  i.bytes
  =/  value  (add acc (lsh 0 shift (mod byte 128)))
  ?:  (lth byte 128)
    [value t.bytes]
  $(bytes t.bytes, acc value, shift (add shift 7))
```

## 6. Error Handling

### Safe JSON Parsing

```hoon
++  safe-json-parse
  |=  text=@t
  ^-  (unit json)
  (de:json:html text)

++  safe-decode-user
  |=  j=json
  ^-  (unit user)
  =/  result
    %-  mule  |.
    (json-to-user j)
  ?-  -.result
    %&  `p.result
    %|  ~
  ==
```

### Validation

```hoon
++  validate-user
  |=  u=user
  ^-  (unit @t)  ::  Error message or ~
  ?:  (gth 0 (lent (trip name.u)))
    `'Name required'
  ?:  (lth age.u 18)
    `'Must be 18 or older'
  ?:  !(valid-email email.u)
    `'Invalid email'
  ~
```

### Versioned Serialization

```hoon
+$  versioned-data
  $%  [%0 data-v0]
      [%1 data-v1]
      [%2 data-v2]
  ==

++  serialize
  |=  data=data-v2
  ^-  @
  (jam [%2 data])

++  deserialize
  |=  jammed=@
  ^-  data-v2
  =/  versioned  !<(versioned-data (cue jammed))
  ?-  -.versioned
    %2  +.versioned
    %1  (migrate-1-to-2 +.versioned)
    %0  (migrate-0-to-2 +.versioned)
  ==
```

## 7. Performance Optimization

### Lazy Serialization

```hoon
::  Serialize on demand
|_  data=large-structure
++  to-json-cached
  =/  cached  *( unit json)
  |.
  ?^  cached  u.cached
  =/  result  (to-json data)
  =.  cached  `result
  result
--
```

### Streaming Serialization

```hoon
::  Process large lists incrementally
++  serialize-stream
  |=  items=(list item)
  ^-  (list @ux)
  %+  turn  items
  |=(i=item (jam i))
```

### Batch Operations

```hoon
::  Serialize multiple items efficiently
++  batch-serialize
  |=  items=(list item)
  ^-  @
  (jam items)  ::  More efficient than individual jams
```

## 8. Common Patterns

### Pattern 1: API Response

```hoon
+$  api-response
  $%  [%success data=json]
      [%error code=@ud message=@t]
  ==

++  response-to-json
  |=  r=api-response
  ^-  json
  ?-  -.r
    %success
      %-  pairs:enjs:format
      ~[['status' s+'success'] ['data' data.r]]
    %error
      %-  pairs:enjs:format
      :~  ['status' s+'error']
          ['code' (numb:enjs:format code.r)]
          ['message' s+message.r]
      ==
  ==
```

### Pattern 2: Persistent State

```hoon
++  save-state
  |=  state=state-type
  ^-  @
  (jam !>(state))

++  load-state
  |=  jammed=@
  ^-  state-type
  !<(state-type (cue jammed))
```

### Pattern 3: Network Messages

```hoon
+$  network-message
  $:  version=@ud
      timestamp=@da
      payload=*
  ==

++  encode-message
  |=  msg=network-message
  ^-  @
  (jam msg)

++  decode-message
  |=  data=@
  ^-  (unit network-message)
  =/  result  (mule |.(!<(network-message (cue data))))
  ?-  -.result
    %&  `p.result
    %|  ~
  ==
```

## 9. Testing Serialization

### Round-Trip Tests

```hoon
++  test-round-trip
  |=  original=user
  ^-  ?
  =/  json  (user-to-json original)
  =/  restored  (json-to-user json)
  ?~  restored  %.n
  =(original u.restored)

++  test-all-users
  =/  users  ~[[name='Alice' age=30 email='a@example.com']]
  %+  levy  users
  test-round-trip
```

### Property Testing

```hoon
++  gen-user
  |=  seed=@
  ^-  user
  :*  name=(scot %ud seed)
      age=(mod seed 100)
      email=(cat 3 (scot %ud seed) '@example.com')
  ==

++  test-many-round-trips
  =/  seeds  (gulf 1 1.000)
  %+  levy  seeds
  |=  s=@
  (test-round-trip (gen-user s))
```

## Resources

- [JSON (zuse 2d)](https://docs.urbit.org/hoon/zuse/2d_1-5) - JSON functions
- [Marks Guide](https://developers.urbit.org/guides/core/app-school/types) - Mark system
- [Vases](https://docs.urbit.org/hoon/vases) - Runtime types

## Summary

Hoon serialization:
1. **JSON** - Web APIs and external data
2. **Vases** - Runtime type information
3. **Jam/Cue** - Efficient noun storage
4. **Marks** - Type-safe conversions
5. **Custom formats** - Specialized needs
6. **Error handling** - Safe parsing and validation
7. **Performance** - Caching and batching

Mastering serialization enables robust data exchange with external systems and efficient persistence.
