---
name: advanced-patterns
description: Advanced Hoon programming patterns including doors, cores, wet gates, mold builders, metaprogramming, performance optimization, and production-grade architectural patterns. Use when building complex libraries, optimizing performance, implementing advanced type system features, or creating reusable cores.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Advanced Patterns Skill

Advanced Hoon programming patterns including doors, cores, wet gates, mold builders, metaprogramming, performance optimization, and production-grade architectural patterns. Use when building complex libraries, optimizing performance, or implementing advanced type system features.

## Overview

This skill covers sophisticated Hoon patterns beyond basic functional programming, focusing on core manipulation, advanced type system usage, metaprogramming techniques, and performance optimization strategies for production systems.

## Learning Objectives

1. Master doors for stateful APIs
2. Build reusable cores and libraries
3. Create generic types with mold builders
4. Use wet gates for polymorphism
5. Apply metaprogramming techniques
6. Optimize code for performance
7. Implement production architectural patterns

## 1. Doors - Stateful Cores

### What is a Door?

A **door** is a core with a sample (like a class with state):

```hoon
|_  sample=type
++  method-1  code-1
++  method-2  code-2
--
```

### Basic Door Pattern

```hoon
::  Counter door
|_  count=@ud
++  increment
  ..$(count +(count))
++  decrement
  ..$(count (dec count))
++  get
  count
++  set
  |=  n=@ud
  ..$(count n)
--
```

**Usage**:
```hoon
=/  counter  ~(. (counter-door) 0)
=/  counter  ~(increment counter)
=/  counter  ~(increment counter)
~(get counter)  ::  2
```

### Door for Map Operations

```hoon
::  Map door (simplified standard library pattern)
|_  m=(map @tas @ud)
++  get
  |=  key=@tas
  (~(get by m) key)
++  put
  |=  [key=@tas val=@ud]
  ..$(m (~(put by m) key val))
++  del
  |=  key=@tas
  ..$(m (~(del by m) key))
++  has
  |=  key=@tas
  (~(has by m) key)
--
```

### Standard Library Door Pattern

This is how `++  by`, `++  in`, etc. work:

```hoon
::  Using standard library map door
=/  my-map  (my ~[[%a 1] [%b 2]])
=/  value   (~(get by my-map) %a)     ::  `1
=/  my-map  (~(put by my-map) %c 3)
my-map  ::  {[%a 1] [%b 2] [%c 3]}
```

### Builder Pattern with Doors

```hoon
::  Query builder
|_  query=$~([table='' fields=~] [table=@t fields=(list @t) where=(unit @t)])
++  from
  |=  table=@t
  ..$(query query(table table))
++  select
  |=  fields=(list @t)
  ..$(query query(fields fields))
++  where
  |=  condition=@t
  ..$(query query(where `condition))
++  build
  query
--

::  Usage
=/  q  ~(. query-builder *query)
=/  q  (~(from q) 'users')
=/  q  (~(select q) ~['name' 'email'])
=/  q  (~(where q) 'age > 18')
~(build q)
```

## 2. Core Manipulation

### Building Library Cores

```hoon
::  Math library core
=<
|%
++  square  |=(n=@ud (mul n n))
++  cube    |=(n=@ud (mul n (mul n n)))
++  pow
  |=  [base=@ud exp=@ud]
  ?:  =(exp 0)  1
  (mul base $(exp (dec exp)))
--
```

### Multi-Arm Cores with `|^`

```hoon
::  Main computation with helpers
|^
=/  data  (load-data)
=/  processed  (process data)
(format-output processed)
::
++  load-data
  ::  Load and validate data
  ...
++  process
  |=  data=@t
  ::  Process logic
  ...
++  format-output
  |=  result=@ud
  ::  Format for output
  ...
--
```

### Nested Cores

```hoon
=>  ::  Outer context
|%
++  constants
  |%
  ++  pi  314
  ++  e   271
  --
++  math
  |%
  ++  area-circle
    |=  r=@ud
    (mul pi:constants (mul r r))
  --
--
=<  ::  Use the library
(area-circle:math 10)
```

### Core Composition

```hoon
::  Compose cores
=>  core-1  ::  First library
=>  core-2  ::  Second library
=<  main    ::  Main program (has access to both)
|%
++  main
  ::  Use functions from core-1 and core-2
  ...
--
```

## 3. Wet Gates - Polymorphism

### Wet vs Dry Gates

**Dry gate** (`|=`): Type-generic (loses specific type):
```hoon
=/  dry-identity
  |=  a=*
  a

(dry-identity 42)      ::  Returns * (generic)
(dry-identity 'text')  ::  Returns * (generic)
```

**Wet gate** (`|*`): Type-preserving (keeps specific type):
```hoon
=/  wet-identity
  |*  a=*
  a

(wet-identity 42)      ::  Returns @ud
(wet-identity 'text')  ::  Returns @t
```

### Polymorphic List Functions

```hoon
::  Generic first element
++  head
  |*  items=(list)
  ^+  ?>(?=(^ items) i.items)
  ?>  ?=(^ items)
  i.items

(head ~[1 2 3])      ::  1 (@ud)
(head ~['a' 'b'])    ::  'a' (@t)
```

### Generic Data Structures

```hoon
::  Generic pair
++  pair
  |*  [a=* b=*]
  ^+  [a b]
  [a b]

(pair 42 'text')           ::  [42 'text'] - preserves types
(pair [1 2] 'hello')       ::  [[1 2] 'hello']
```

### Conditional Type Preservation

```hoon
::  Preserve type through conditional
++  default-or
  |*  [m=(unit) d=*]
  ^+  ?~(m d u.m)
  ?~  m  d
  u.m

(default-or `42 0)         ::  42 (@ud)
(default-or ~ 'default')   ::  'default' (@t)
```

## 4. Mold Builders (Generic Types)

### Basic Mold Builder

```hoon
::  Generic pair type
+$  pair
  |$  [a b]
  [first=a second=b]

::  Usage
(pair @ud @t)         ::  [first=@ud second=@t]
(pair @t (list @ud))  ::  [first=@t second=(list @ud)]
```

### Standard Library Mold Builders

```hoon
::  list is a mold builder
+$  list
  |$  [item]
  $@(~ [i=item t=(list item)])

::  unit is a mold builder
+$  unit
  |$  [item]
  $@(~ [~ u=item])

::  map is a mold builder
+$  map
  |$  [key value]
  (tree [p=key q=value])
```

### Custom Generic Types

```hoon
::  Generic tree
+$  binary-tree
  |$  [item]
  $@  ~
  [node=item left=(binary-tree item) right=(binary-tree item)]

::  Usage
=/  int-tree  ^-  (binary-tree @ud)
  [node=10 left=~ right=[node=20 left=~ right=~]]
```

### Either Type (Sum Type)

```hoon
::  Generic either/result type
+$  either
  |$  [left right]
  $%  [%left value=left]
      [%right value=right]
  ==

::  Usage
+$  result  (either @t @ud)  ::  Error or Success
=/  success  ^-  result  [%right 42]
=/  error    ^-  result  [%left 'failed']
```

### Validation Wrapper

```hoon
::  Non-empty list
+$  non-empty-list
  |$  [item]
  [i=item t=(list item)]

++  make-non-empty
  |*  items=(list)
  ^-  (unit (non-empty-list _?>(?=(^ items) i.items)))
  ?~  items  ~
  `items
```

## 5. Metaprogramming

### Compile-Time Evaluation

```hoon
::  Constant folding with ^~
=/  big-constant  ^~((mul 1.000.000 1.000.000))
::  Computed at compile time, not runtime

::  Useful for lookup tables
=/  lookup-table  ^~
  %-  my
  :~  [%red 0xff0000]
      [%green 0x00ff00]
      [%blue 0x0000ff]
  ==
```

### Code Generation Patterns

```hoon
::  Generate repetitive code
=,  format
|^
:~  (make-accessor %name @t)
    (make-accessor %age @ud)
    (make-accessor %email @t)
==
++  make-accessor
  |=  [field=@tas type=*]
  ^-  [term=@tas gate=$-(* *)]
  :-  field
  |=  record=*
  ;;(type (slot field record))
--
```

### Macro-like Aliases with `=*`

```hoon
::  Create readable aliases
++  process-data
  |=  very-long-descriptive-name=@t
  =*  data  very-long-descriptive-name
  ::  Use 'data' instead of long name
  =/  len  (lent (trip data))
  =/  upper  (cuss (trip data))
  [len upper]
```

### Hoon to Nock Inspection

```hoon
::  View compiled Nock
!=(add)               ::  See Nock formula for add
!=(|=(n=@ (mul n 2))) ::  See compiled gate

::  Useful for understanding performance
::  and jet acceleration patterns
```

## 6. Performance Optimization

### Tail Call Optimization

```hoon
::  ✗ Bad: Non-tail-recursive
++  sum-slow
  |=  items=(list @ud)
  ?~  items  0
  (add i.items $(items t.items))

::  ✓ Good: Tail-recursive with accumulator
++  sum-fast
  |=  items=(list @ud)
  =/  acc  0
  |-
  ?~  items  acc
  $(items t.items, acc (add i.items acc))
```

### Data Structure Selection

```hoon
::  ✗ Slow: O(n) list lookup
=/  items  ~[1 2 3 4 5 ... 1000]
%+  find  items
|=(n=@ud =(n 500))

::  ✓ Fast: O(log n) set lookup
=/  items  (silt ~[1 2 3 4 5 ... 1000])
(~(has in items) 500)

::  ✗ Slow: O(n) list search
=/  users  ~[[id=1 name='Alice'] [id=2 name='Bob'] ...]
%+  find  users
|=(u=[id=@ud name=@t] =(id.u 500))

::  ✓ Fast: O(log n) map lookup
=/  users  (my ~[[1 'Alice'] [2 'Bob'] ...])
(~(get by users) 500)
```

### Avoid Repeated Computation

```hoon
::  ✗ Bad: Recompute length each time
++  process-bad
  |=  items=(list @ud)
  ?:  (gth (lent items) 100)
    'big'
  ?:  (gth (lent items) 50)
    'medium'
  'small'

::  ✓ Good: Compute once
++  process-good
  |=  items=(list @ud)
  =/  len  (lent items)
  ?:  (gth len 100)  'big'
  ?:  (gth len 50)   'medium'
  'small'
```

### Single-Pass Algorithms

```hoon
::  ✗ Bad: Multiple passes
=/  evens  (skim numbers |=(n=@ud =(0 (mod n 2))))
=/  count  (lent evens)
=/  sum    (roll evens add)

::  ✓ Good: Single pass
%+  roll  numbers
|=  [n=@ud acc=[count=@ud sum=@ud]]
?:  =(0 (mod n 2))
  [+(count.acc) (add n sum.acc)]
acc
```

### Memoization

```hoon
::  Memoized Fibonacci
++  fib-memo
  |=  n=@ud
  ^-  @ud
  =/  cache  *(map @ud @ud)
  =<  result
  %+  compute  n  cache
::
++  compute
  |=  [n=@ud cache=(map @ud @ud)]
  ^-  [result=@ud cache=(map @ud @ud)]
  ?:  (lte n 1)  [n cache]
  =/  cached  (~(get by cache) n)
  ?^  cached  [u.cached cache]
  =^  r1  cache  (compute (sub n 1) cache)
  =^  r2  cache  (compute (sub n 2) cache)
  =/  result  (add r1 r2)
  [result (~(put by cache) n result)]
```

## 7. Production Architectural Patterns

### State Versioning

```hoon
::  Always version state for migrations
+$  versioned-state
  $%  [%0 state-0]
      [%1 state-1]
      [%2 state-2]
  ==
::
+$  state-0
  $:  users=(map @ud user-0)
  ==
::
+$  state-1
  $:  users=(map @ud user-1)
      settings=settings
  ==

::  Migration path
++  migrate
  |=  old=versioned-state
  ^-  state-2
  ?-  -.old
    %2  +.old
    %1  (migrate-1-to-2 +.old)
    %0  (migrate-0-to-2 +.old)
  ==
```

### Error Handling Pattern

```hoon
::  Result type with errors
+$  result
  |$  [ok err]
  $%  [%ok value=ok]
      [%err error=err]
  ==

::  Bind for chaining
++  bind-result
  |*  [r=result f=$-(* result)]
  ?-  -.r
    %ok   (f value.r)
    %err  r
  ==

::  Usage
=/  r1  (validate-input input)
=/  r2  (bind-result r1 parse-data)
=/  r3  (bind-result r2 process-data)
r3
```

### Circuit Breaker Pattern

```hoon
+$  circuit-state
  $%  [%closed failures=@ud]
      [%open opened-at=@da]
      [%half-open ~]
  ==

|_  state=circuit-state
++  record-success
  ..$(state [%closed failures=0])
++  record-failure
  ^-  _..record-success
  ?-  -.state
    %closed
      ?:  (gte +(failures.state) threshold)
        ..$(state [%open opened-at=now])
      ..$(state [%closed failures=+(failures.state)])
    %open       ..record-failure
    %half-open  ..$(state [%open opened-at=now])
  ==
++  should-attempt
  ?-  -.state
    %closed      %.y
    %half-open   %.y
    %open        (gte (sub now opened-at.state) timeout)
  ==
--
```

### Caching Layer Pattern

```hoon
|_  $:  cache=(map key value)
        ttl=@dr
        timestamps=(map key @da)
    ==
++  get
  |=  k=key
  ^-  (unit value)
  =/  cached  (~(get by cache) k)
  ?~  cached  ~
  =/  ts  (~(got by timestamps) k)
  ?:  (gth (sub now ts) ttl)
    ~  ::  Expired
  cached
++  put
  |=  [k=key v=value]
  %=  ..put
    cache       (~(put by cache) k v)
    timestamps  (~(put by timestamps) k now)
  ==
++  invalidate
  |=  k=key
  %=  ..invalidate
    cache       (~(del by cache) k)
    timestamps  (~(del by timestamps) k)
  ==
--
```

### Rate Limiting Pattern

```hoon
+$  rate-limit
  $:  max-requests=@ud
      window=@dr
      requests=(list @da)
  ==

|_  rl=rate-limit
++  check-limit
  ^-  [allowed=? _..check-limit]
  =/  cutoff  (sub now window.rl)
  =/  recent  (skim requests.rl |=(t=@da (gte t cutoff)))
  ?:  (gte (lent recent) max-requests.rl)
    [%.n ..check-limit(requests.rl recent)]
  [%.y ..check-limit(requests.rl [now recent])]
--
```

## 8. Advanced Type Patterns

### Phantom Types

```hoon
::  Compile-time only type information
+$  validated  @t
+$  unvalidated  @t

++  validate
  |=  input=unvalidated
  ^-  (unit validated)
  ?:  (valid-format input)
    `input
  ~

++  use-safe
  |=  input=validated
  ::  Know input is validated!
  (process input)
```

### Type-Level State Machine

```hoon
::  Connection states
+$  disconnected  @
+$  connected  @
+$  error  @

::  State transitions enforced by types
++  connect
  |=  state=disconnected
  ^-  (either connected error)
  ...

++  send
  |=  [state=connected data=@t]
  ^-  (either connected error)
  ...

++  disconnect
  |=  state=connected
  ^-  disconnected
  ...
```

### Branded Types

```hoon
::  User ID (can't mix with other IDs)
+$  user-id
  $@  @ud
  @ud

::  Post ID (different brand)
+$  post-id
  $@  @ud
  @ud

++  get-user
  |=  id=user-id
  ^-  (unit user)
  ...

::  Type error if you pass post-id to get-user
```

## 9. Testing Patterns

### Property-Based Testing Setup

```hoon
::  Generator for test inputs
++  gen-list
  |=  [max-len=@ud max-val=@ud seed=@]
  ^-  (list @ud)
  =/  len  (mod seed max-len)
  =/  values  *(list @ud)
  |-
  ?:  =(len 0)  values
  =/  val  (mod (add seed len) max-val)
  $(len (dec len), values [val values])

::  Property: reverse of reverse is identity
++  test-reverse-identity
  |=  seed=@
  =/  input  (gen-list 100 1.000 seed)
  =/  reversed  (flop input)
  =/  double-reversed  (flop reversed)
  .=(input double-reversed)
```

### Test Fixture Pattern

```hoon
::  Reusable test data
++  fixtures
  |%
  ++  sample-user
    [id=1 name='Alice' age=30]
  ++  sample-users
    ~[sample-user [id=2 name='Bob' age=25]]
  ++  empty-state
    [users=*(map @ud user) next-id=0]
  --

::  Use in tests
=/  state  empty-state:fixtures
=/  user   sample-user:fixtures
(test-add-user state user)
```

## 10. Library Design Patterns

### Fluent API Pattern

```hoon
::  Chainable operations
|_  query=[select=(list @t) from=@t where=(unit @t)]
++  select
  |=  fields=(list @t)
  ..$(query query(select fields))
++  from
  |=  table=@t
  ..$(query query(from table))
++  where
  |=  condition=@t
  ..$(query query(where `condition))
++  execute
  query
--

::  Usage
~(execute :(where (from (select query-builder ~['*']) 'users')) 'age > 18')
```

### Dependency Injection

```hoon
::  Injectable dependencies
|_  $:  logger=$-([@t *] *)
        db=$-([%get @t] *)
        cache=$-([%get @t] *)
    ==
++  process
  |=  input=@t
  (logger 'Processing' input)
  =/  cached  (cache [%get input])
  ?^  cached
    u.cached
  =/  from-db  (db [%get input])
  (cache [%put input from-db])
  from-db
--
```

## Resources

- [Cores](https://docs.urbit.org/build-on-urbit/hoon-school/f-cores) - Advanced core patterns
- [Standard Library](https://docs.urbit.org/hoon/stdlib) - Standard library doors
- [Performance Guide](https://developers.urbit.org/guides/additional/performance) - Optimization techniques

## Summary

Advanced Hoon patterns enable:
1. **Doors** for stateful APIs and builders
2. **Wet gates** for type-preserving polymorphism
3. **Mold builders** for generic types
4. **Metaprogramming** for code generation
5. **Performance optimization** through algorithmic improvements
6. **Production patterns** for robust systems
7. **Advanced types** for compile-time guarantees
8. **Testing strategies** for quality assurance

Mastering these patterns distinguishes advanced Hoon developers and enables building production-grade systems.
