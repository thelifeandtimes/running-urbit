---
name: functional-programming-patterns
description: Master functional programming patterns in Hoon including pure functions, immutability, higher-order functions, composition, recursion, and functional data transformation. Use when designing clean, maintainable, testable code or applying map/filter/fold operations.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Functional Programming Patterns Skill

Master functional programming patterns in Hoon including pure functions, immutability, higher-order functions, composition, recursion, and functional data transformation. Use when designing clean, maintainable, and testable Hoon code.

## Overview

Hoon is a pure functional language where all data is immutable and functions have no side effects. This skill covers essential FP patterns that make Hoon code elegant, composable, and correct.

## Learning Objectives

1. Write pure functions without side effects
2. Leverage immutability for correctness
3. Master higher-order functions and composition
4. Use recursion and tail-call optimization
5. Transform data functionally (map, filter, fold)
6. Apply functional patterns to real problems
7. Understand monadic patterns (unit, list)

## 1. Purity and Referential Transparency

### Pure Functions

A **pure function**:
1. Same inputs → same outputs (deterministic)
2. No side effects (no mutation, I/O, etc.)
3. No hidden dependencies

```hoon
::  ✓ Pure
++  add-ten
  |=  n=@ud
  (add n 10)

(add-ten 5)  ::  Always 15

::  ✓ Pure
++  double
  |=  n=@ud
  (mul n 2)

::  ✗ Impure (if it could modify state)
::  (Gall agents handle effects separately)
```

### Referential Transparency

Can replace function call with its result:

```hoon
=/  x  (add 2 3)
=/  y  (mul x 2)
y  ::  10

::  Same as:
=/  y  (mul (add 2 3) 2)
y  ::  10

::  Same as:
=/  y  (mul 5 2)
y  ::  10
```

### Benefits

1. **Testability**: No mocks needed, just inputs → outputs
2. **Reasoning**: Understand code by reading it
3. **Parallelization**: No race conditions
4. **Caching**: Same input = same output (memoizable)
5. **Debugging**: Reproducible behavior

## 2. Immutability

### Everything is Immutable

All Hoon data structures are immutable:

```hoon
=/  x  5
::  Cannot mutate x!
::  Must create new binding

=/  x  (add x 1)  ::  x is now 6 (new binding, not mutation)
```

### Structural Sharing

Hoon shares structure for efficiency:

```hoon
=/  list-a  ~[1 2 3 4 5]
=/  list-b  [0 list-a]    ::  Prepends 0, shares [1 2 3 4 5]

::  list-a: [1 2 3 4 5]
::  list-b: [0 1 2 3 4 5]
::  Only the head [0] is new memory
```

### Update Pattern

**Don't**: Try to mutate
```hoon
::  No mutation in Hoon!
```

**Do**: Create new with changes
```hoon
=/  point  [x=5 y=10]
=/  moved  point(x 20)  ::  New point: [x=20 y=10]
point  ::  Still [x=5 y=10]
```

### Benefits

1. **Safety**: No accidental mutation
2. **Concurrency**: No locks needed
3. **History**: Keep old versions
4. **Debugging**: Values don't change under you
5. **Reasoning**: Know data won't change

## 3. Higher-Order Functions

### Functions as Values

Functions are first-class values:

```hoon
=/  fn  |=(n=@ud (mul n 2))
(fn 5)  ::  10

::  Pass function as argument
++  apply-twice
  |=  [f=$-(@ @) n=@]
  (f (f n))

(apply-twice |=(n=@ (add n 1)) 5)  ::  7
```

### Common Higher-Order Patterns

#### Map - Transform Each Element

```hoon
::  map: (list a) → (list b)
%+  turn  ~[1 2 3]
|=(n=@ud (mul n 2))
::  ~[2 4 6]

::  Usage pattern
%+  turn  items
|=  item=@ud
(transform item)
```

#### Filter - Select Elements

```hoon
::  filter: (list a) → (list a)
%+  skim  ~[1 2 3 4 5]
|=(n=@ud =(0 (mod n 2)))
::  ~[2 4]

::  Usage pattern
%+  skim  items
|=  item=@ud
(test item)
```

#### Fold - Reduce to Single Value

```hoon
::  fold-left: accumulate from left
%+  roll  ~[1 2 3 4]
|=  [n=@ud acc=@ud]
(add acc n)
::  10

::  fold-right: accumulate from right
%+  reel  ~[1 2 3 4]
|=  [n=@ud acc=@ud]
(add acc n)
::  10
```

#### Find - Locate Element

```hoon
::  find sublist in list (returns index as unit)
(find ~[3 4] ~[1 2 3 4 5])  ::  [~ 2]
(find ~[6 7] ~[1 2 3 4 5])  ::  ~ (not found)
```

## 4. Function Composition

### Composing Functions

**Mathematical**: `(f ∘ g)(x) = f(g(x))`

```hoon
++  double  |=(n=@ud (mul n 2))
++  add-ten |=(n=@ud (add n 10))

::  Compose manually
++  double-then-add-ten
  |=  n=@ud
  (add-ten (double n))

(double-then-add-ten 5)  ::  20

::  Pipeline style
=/  result
  %+  add-ten
  (double 5)
result  ::  20
```

### Compose with Nesting

Chain multiple transformations by nesting calls:

```hoon
::  Compose by nesting function calls:
(crip (cass (trip 'HELLO')))  ::  'hello'

::  Note: =~ chains expressions where each uses the previous as subject.
::  It does NOT work as a simple function pipeline like the above.
```

### Point-Free Style

Define functions without explicit parameters:

```hoon
::  Point-ful (explicit parameter)
++  double-all
  |=  items=(list @ud)
  (turn items |=(n=@ud (mul n 2)))

::  Point-free (no explicit items)
++  double-all
  (curr turn |=(n=@ud (mul n 2)))
```

## 5. Recursion

### Basic Recursion

```hoon
++  factorial
  |=  n=@ud
  ?:  =(n 0)
    1
  (mul n $(n (dec n)))

(factorial 5)  ::  120
```

### Tail Recursion

**Tail-call optimization** - last operation is recursive call:

```hoon
::  NOT tail-recursive (multiplication after recursion)
++  factorial-slow
  |=  n=@ud
  ?:  =(n 0)
    1
  (mul n $(n (dec n)))  ::  Multiply AFTER recursive call

::  Tail-recursive (accumulator pattern)
++  factorial-fast
  |=  n=@ud
  ^-  @ud
  =/  acc  1
  |-
  ?:  =(n 0)
    acc
  $(n (dec n), acc (mul n acc))  ::  Recursive call is LAST

(factorial-fast 5)  ::  120
```

**Benefits**:
- Constant stack space
- No stack overflow
- Compiler optimizes to loop

### Recursion Patterns

#### List Recursion
```hoon
++  sum-list
  |=  items=(list @ud)
  ^-  @ud
  ?~  items
    0
  (add i.items $(items t.items))

(sum-list ~[1 2 3 4])  ::  10
```

#### Tree Recursion
```hoon
++  tree-size
  |=  t=(tree @)
  ^-  @ud
  ?~  t
    0
  %+  add  1
  %+  add
    $(t l.t)
  $(t r.t)
```

#### Mutual Recursion
```hoon
++  even
  |=  n=@ud
  ?:  =(n 0)  %.y
  (odd (dec n))

++  odd
  |=  n=@ud
  ?:  =(n 0)  %.n
  (even (dec n))
```

## 6. Functional Data Transformation

### Map Pattern

Transform every element:

```hoon
::  Double all numbers
%+  turn  ~[1 2 3]
|=(n=@ud (mul n 2))
::  ~[2 4 6]

::  Extract field
=/  users  ~[[name='Alice' age=30] [name='Bob' age=25]]
%+  turn  users
|=(user=[name=@t age=@ud] name.user)
::  ~['Alice' 'Bob']
```

### Filter Pattern

Keep only matching elements:

```hoon
::  Even numbers only
%+  skim  ~[1 2 3 4 5]
|=(n=@ud =(0 (mod n 2)))
::  ~[2 4]

::  Adults only
%+  skim  users
|=(user=[name=@t age=@ud] (gte age.user 18))
```

### Fold Pattern

Accumulate to single result:

```hoon
::  Sum
%+  roll  ~[1 2 3 4]
|=([n=@ud acc=@ud] (add acc n))
::  10

::  Product
%+  roll  ~[1 2 3 4]
|=([n=@ud acc=@ud] (mul acc n))
::  24

::  Build map
%+  roll  ~[[%a 1] [%b 2]]
|=  [[k=@tas v=@ud] acc=(map @tas @ud)]
(~(put by acc) k v)
::  Map: {[%a 1] [%b 2]}
```

### Map-Filter-Reduce Pipeline

```hoon
::  Sum of squares of even numbers
=/  numbers  ~[1 2 3 4 5 6]
%+  roll
  %+  turn
    %+  skim  numbers
    |=(n=@ud =(0 (mod n 2)))
  |=(n=@ud (mul n n))
|=([n=@ud acc=@ud] (add acc n))
::  Filter evens: ~[2 4 6]
::  Map squares: ~[4 16 36]
::  Reduce sum: 56
```

## 7. Currying and Partial Application

### Currying

Transform multi-argument function into chain of single-argument functions:

```hoon
::  Normal function
++  add
  |=  [a=@ b=@]
  (add a b)

::  Curried version
++  add-curried
  |=  a=@
  |=  b=@
  (add a b)

=/  add-5  (add-curried 5)
(add-5 10)  ::  15
```

### Partial Application with `cury`

Fix first (left) argument:

```hoon
::  cury: curry left (fix first argument)
=/  add-10  (cury add 10)
(add-10 5)  ::  15

::  Practical use
=/  double-all  (cury turn |=(n=@ud (mul n 2)))
(double-all ~[1 2 3])  ::  ~[2 4 6]
```

### Partial Application with `curr`

Fix last (right) argument:

```hoon
::  curr: curry right (fix second/last argument)
=/  add-to-10  (curr add 10)
(add-to-10 5)  ::  15
```

## 8. Monadic Patterns

### Unit (Maybe/Option)

Handle optional values functionally:

```hoon
::  unit: some or none
+$  unit  [item]
  $@(~ [~ u=item])

::  Example
=/  maybe-user  ^-  (unit @t)  `'Alice'
?~  maybe-user
  'No user'
u.maybe-user  ::  'Alice'
```

**Bind (flatMap)**:
```hoon
++  bind-unit
  |*  [m=(unit) f=$-(* (unit))]
  ?~  m  ~
  (f u.m)

::  Usage
=/  user-id  `42
=/  user  (bind-unit user-id get-user)
=/  posts  (bind-unit user get-user-posts)
posts
```

**Map (fmap)**:
```hoon
++  map-unit
  |*  [m=(unit) f=$-(* *)]
  ?~  m  ~
  `(f u.m)

::  Usage
=/  age  `30
=/  age-doubled  (map-unit age |=(n=@ud (mul n 2)))
age-doubled  ::  `60
```

### List

Monadic operations on lists:

**Bind (flatMap)**:
```hoon
++  bind-list
  |*  [items=(list) f=$-(* (list))]
  |-  ^+  items
  ?~  items  ~
  (weld (f i.items) $(items t.items))

::  Usage: get all words from all sentences
=/  sentences  ~["hello world" "foo bar"]
%+  bind-list  sentences
|=(s=tape (rash s (more ace (star alf))))
::  ~["hello" "world" "foo" "bar"]
```

**Map (fmap)**:
```hoon
::  Already exists as 'turn'
%+  turn  ~[1 2 3]
|=(n=@ud (mul n 2))
::  ~[2 4 6]
```

**Filter**:
```hoon
::  Already exists as 'skim'
%+  skim  ~[1 2 3 4 5]
|=(n=@ud =(0 (mod n 2)))
::  ~[2 4]
```

## 9. Lazy Evaluation

### Traps (`|.`)

Defer computation until needed:

```hoon
::  Lazy value
=/  expensive  |.((slow-computation))

::  Only compute if needed
?:  condition
  $:expensive  ::  Evaluate trap
default-value
```

### Lazy Lists (Streams)

```hoon
::  Infinite stream (conceptual - use carefully!)
++  nats
  |=  n=@ud
  ^-  (trap [@ $-(@ *)])
  |.
  [n $(n +(n))]

::  Take first N elements
++  take
  |=  [n=@ud stream=(trap [@ud $-(@ *)])]
  ^-  (list @ud)
  ?:  =(n 0)  ~
  =/  [val=@ud next=$-(@ *)]  $:stream
  [val $(n (dec n), stream next)]
```

## 10. Pattern Matching and Destructuring

### Pattern Matching with `?-`

```hoon
+$  shape
  $%  [%circle radius=@ud]
      [%rectangle width=@ud height=@ud]
      [%triangle base=@ud height=@ud]
  ==

++  area
  |=  s=shape
  ^-  @ud
  ?-  -.s
    %circle      (mul pi (mul radius.s radius.s))
    %rectangle   (mul width.s height.s)
    %triangle    (div (mul base.s height.s) 2)
  ==
```

### Destructuring in Function Parameters

```hoon
::  Destructure pair
++  add-point
  |=  [[x1=@ud y1=@ud] [x2=@ud y2=@ud]]
  ^-  [x=@ud y=@ud]
  [x=(add x1 x2) y=(add y1 y2)]

::  Destructure list
++  first-two
  |=  items=(list @)
  ^-  (unit [@ud @ud])
  ?~  items  ~
  ?~  t.items  ~
  `[i.items i.t.items]
```

## 11. Functional Pipelines

### Sequential Transformation

```hoon
++  process-user-input
  |=  input=@t
  ^-  @ud
  =/  text  (cass (trip input))
  (scan text dem)
```

### Error Handling Pipeline

```hoon
+$  result
  $%  [%ok value=@ud]
      [%err msg=@t]
  ==

++  bind-result
  |*  [r=result f=$-(* result)]
  ?-  -.r
    %ok   (f value.r)
    %err  r
  ==

::  Pipeline
=/  r1  (validate-input input)
=/  r2  (bind-result r1 parse-number)
=/  r3  (bind-result r2 process-number)
r3
```

## 12. Common Functional Patterns

### Pattern 1: Safe List Operations

```hoon
++  safe-head
  |*  items=(list)
  ^-  (unit _?>(?=(^ items) i.items))
  ?~  items  ~
  `i.items

++  safe-tail
  |*  items=(list)
  ^+  items
  ?~  items  ~
  t.items
```

### Pattern 2: Default Values

```hoon
++  default
  |*  [m=(unit) d=*]
  ?~  m  d
  u.m

=/  maybe-name  ~
(default maybe-name 'Unknown')  ::  'Unknown'
```

### Pattern 3: List Utilities

```hoon
::  Take first N elements
++  take
  |*  [n=@ items=(list)]
  ^+  items
  ?:  =(n 0)  ~
  ?~  items  ~
  [i.items $(n (dec n), items t.items)]

::  Drop first N elements
++  drop
  |*  [n=@ items=(list)]
  ^+  items
  ?:  =(n 0)  items
  ?~  items  ~
  $(n (dec n), items t.items)

::  Zip two lists
++  zip
  |*  [a=(list) b=(list)]
  ^-  (list _?>(?=([* *] [a b]) [i.a i.b]))
  ?~  a  ~
  ?~  b  ~
  [[i.a i.b] $(a t.a, b t.b)]
```

### Pattern 4: Function Composition Helpers

```hoon
++  compose
  |*  [f=$-(* *) g=$-(* *)]
  |*  x=*
  (f (g x))

=/  double  |=(n=@ud (mul n 2))
=/  add-ten |=(n=@ud (add n 10))
=/  pipeline  (compose add-ten double)
(pipeline 5)  ::  20
```

### Pattern 5: Memoization Pattern

```hoon
++  memoize
  |*  [cache=(map * *) f=$-(* *) arg=*]
  ^-  [result=* cache=(map * *)]
  =/  cached  (~(get by cache) arg)
  ?^  cached
    [u.cached cache]
  =/  result  (f arg)
  [result (~(put by cache) arg result)]
```

## 13. Best Practices

### 1. Prefer Pure Functions
```hoon
::  ✓ Good: Pure
++  calculate-total
  |=  items=(list @ud)
  ^-  @ud
  (roll items add)

::  ✗ Avoid: Side effects (Gall handles these)
```

### 2. Use Descriptive Names
```hoon
::  ✓ Good
++  filter-active-users
  |=  users=(list user)
  (skim users |=(u=user active.u))

::  ✗ Bad
++  f
  |=  us=(list user)
  (skim us |=(u=user active.u))
```

### 3. Compose Small Functions
```hoon
::  ✓ Good: Small, composable
++  is-even  |=(n=@ud =(0 (mod n 2)))
++  square   |=(n=@ud (mul n n))
++  sum      |=(ns=(list @ud) (roll ns add))

++  sum-of-squares-of-evens
  |=  numbers=(list @ud)
  %:  sum
    %+  turn
      (skim numbers is-even)
    square
  ==

::  ✗ Bad: Monolithic
++  sum-of-squares-of-evens
  |=  numbers=(list @ud)
  =/  acc  0
  |-  ^-  @ud
  ?~  numbers  acc
  ?:  =((mod i.numbers 2) 0)
    $(numbers t.numbers, acc (add acc (mul i.numbers i.numbers)))
  $(numbers t.numbers)
```

### 4. Leverage Type System
```hoon
::  ✓ Good: Types document intent
++  process-user
  |=  user=[name=@t age=@ud]
  ^-  [greeting=@t can-vote=?]
  :_  (gte age.user 18)
  (cat 3 'Hello, ' name.user)
```

### 5. Use Standard Library
```hoon
::  ✓ Good: Use 'turn'
(turn ~[1 2 3] |=(n=@ud (mul n 2)))

::  ✗ Bad: Reinvent recursion
|-  ^-  (list @ud)
?~  items  ~
[(mul i.items 2) $(items t.items)]
```

## 14. Performance Considerations

### Tail Call Optimization

```hoon
::  ✓ Optimized: Tail-recursive
++  sum-tail
  |=  items=(list @ud)
  ^-  @ud
  =/  acc  0
  |-
  ?~  items  acc
  $(items t.items, acc (add i.items acc))

::  ✗ Slow: Non-tail-recursive
++  sum-slow
  |=  items=(list @ud)
  ^-  @ud
  ?~  items  0
  (add i.items $(items t.items))
```

### Avoid Repeated Traversals

```hoon
::  ✗ Bad: Multiple passes
=/  evens  (skim numbers is-even)
=/  count  (lent evens)
=/  sum    (roll evens add)
[count sum]

::  ✓ Good: Single pass
%+  roll  numbers
|=  [n=@ud [count=@ud sum=@ud]]
?:  (is-even n)
  [(add count 1) (add sum n)]
[count sum]
```

## Resources

- [Hoon School - Functional Programming](https://developers.urbit.org/guides/core/hoon-school/F-func) - FP in Hoon
- [Standard Library](https://docs.urbit.org/hoon/stdlib) - Functional utilities
- [Recursion Patterns](https://developers.urbit.org/guides/core/hoon-school/G-loop) - Loops and recursion

## Summary

Functional programming in Hoon provides:
1. **Purity** for predictability and testability
2. **Immutability** for safety and reasoning
3. **Higher-order functions** for abstraction
4. **Composition** for modularity
5. **Pattern matching** for expressiveness
6. **Monadic patterns** for chaining operations

Mastering these patterns leads to elegant, maintainable, and correct Hoon code.
