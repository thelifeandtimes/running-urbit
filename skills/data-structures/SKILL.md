---
name: data-structures
description: Master Hoon's built-in data structures including lists, sets, maps, mops (ordered maps), jars, jugs, and trees with their operations and performance characteristics. Use when choosing data structures, optimizing algorithms, building complex applications, or understanding standard library collections.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Data Structures Skill

Master Hoon's built-in data structures including lists, sets, maps, trees, and specialized structures. Use when choosing data structures, optimizing algorithms, or building complex applications.

## Overview

Hoon provides functional data structures built on the noun foundation. This skill covers lists, sets, maps, mops (ordered maps), jars, jugs, and trees, along with their operations and performance characteristics.

## Learning Objectives

1. Choose appropriate data structures for tasks
2. Perform efficient operations on each structure
3. Understand performance trade-offs
4. Use standard library functions effectively
5. Build custom data structures when needed
6. Optimize data structure usage

## 1. Lists

### Structure

**Lists** are null-terminated linked lists:
```hoon
+$  list  [item]
  $@(~ [i=item t=(list item)])

::  Examples
~            ::  Empty list (null)
~[1]         ::  [i=1 t=~]
~[1 2 3]     ::  [i=1 t=[i=2 t=[i=3 t=~]]]
```

### Construction

```hoon
::  Empty list
~
*(list @ud)

::  From elements
~[1 2 3 4 5]

::  Cons (prepend)
[0 ~[1 2 3]]  ::  ~[0 1 2 3]

::  Convert from other structures
~(tap in (silt ~[3 1 2]))  ::  Set → list
~(tap by (my ~[[%a 1]]))   ::  Map → list of pairs
```

### Core Operations

```hoon
::  Head (first element)
++  head
  |*  items=(list)
  ^+  ?>(?=(^ items) i.items)
  ?>  ?=(^ items)
  i.items

(head ~[1 2 3])  ::  1

::  Tail (all but first)
++  tail
  |*  items=(list)
  ^+  items
  ?>  ?=(^ items)
  t.items

(tail ~[1 2 3])  ::  ~[2 3]

::  Length
(lent ~[1 2 3 4])  ::  4

::  Reverse
(flop ~[1 2 3])    ::  ~[3 2 1]

::  Concatenate
(weld ~[1 2] ~[3 4])  ::  ~[1 2 3 4]

::  Append (O(n) - avoid in loops!)
(snoc ~[1 2 3] 4)     ::  ~[1 2 3 4]

::  Take first N
(scag 2 ~[1 2 3 4])   ::  ~[1 2]

::  Drop first N
(slag 2 ~[1 2 3 4])   ::  ~[3 4]

::  Get element at index
(snag 2 ~[10 20 30 40])  ::  30 (0-indexed)
```

### Higher-Order Functions

```hoon
::  Map (transform each)
%+  turn  ~[1 2 3]
|=(n=@ud (mul n 2))
::  ~[2 4 6]

::  Filter (keep matching)
%+  skim  ~[1 2 3 4 5]
|=(n=@ud =(0 (mod n 2)))
::  ~[2 4]

::  Reject (remove matching)
%+  skip  ~[1 2 3 4 5]
|=(n=@ud =(0 (mod n 2)))
::  ~[1 3 5]

::  Fold left (accumulate)
%+  roll  ~[1 2 3 4]
|=([n=@ud acc=@ud] (add acc n))
::  10

::  Fold right
%+  reel  ~[1 2 3 4]
|=([n=@ud acc=@ud] (add n acc))
::  10

::  Find sublist in list (returns index as unit)
(find ~[2 3] ~[1 2 3 4])  ::  [~ 1]
(find ~[5 6] ~[1 2 3 4])  ::  ~ (not found)
```

### Performance

| Operation | Time Complexity |
|-----------|----------------|
| Prepend (cons) | O(1) |
| Head | O(1) |
| Tail | O(1) |
| Length | O(n) |
| Append | O(n) |
| Concatenate | O(n + m) |
| Index access | O(n) |
| Search | O(n) |

**Best for**: Sequential access, stacks, small collections

**Avoid for**: Random access, frequent appends, large datasets requiring fast lookup

## 2. Sets

### Structure

**Sets** are unordered collections of unique elements, implemented as balanced trees:
```hoon
+$  set  [item]
  (tree item)
```

### Construction

```hoon
::  Empty set
~
*(set @ud)
(silt ~)

::  From list
(silt ~[1 2 3 2 1])  ::  {1 2 3} (duplicates removed)

::  Using ~(in set)
=/  s  *(set @ud)
=/  s  (~(put in s) 1)
=/  s  (~(put in s) 2)
s  ::  {1 2}
```

### Core Operations

```hoon
=/  my-set  (silt ~[1 2 3 4 5])

::  Has (membership test)
(~(has in my-set) 3)     ::  %.y (true)
(~(has in my-set) 10)    ::  %.n (false)

::  Put (add element)
(~(put in my-set) 6)     ::  {1 2 3 4 5 6}

::  Del (remove element)
(~(del in my-set) 3)     ::  {1 2 4 5}

::  Tap (convert to list)
~(tap in my-set)         ::  ~[1 2 3 4 5] (unordered)

::  Run (map over set)
%~  run  in  my-set
|=(n=@ud (mul n 2))
::  {2 4 6 8 10}

::  Rep (fold over set)
%~  rep  in  my-set
|=([n=@ud acc=@ud] (add n acc))
::  15

::  Intersection (elements in both)
(~(int in (silt ~[1 2 3])) (silt ~[2 3 4]))  ::  {2 3}

::  Union (all elements)
(~(uni in (silt ~[1 2 3])) (silt ~[3 4 5]))  ::  {1 2 3 4 5}

::  Difference (in first but not second)
(~(dif in (silt ~[1 2 3])) (silt ~[2 3 4]))  ::  {1}

::  Size
~(wyt in my-set)         ::  5
```

### Performance

| Operation | Time Complexity |
|-----------|----------------|
| Has | O(log n) |
| Put | O(log n) |
| Del | O(log n) |
| Union/Intersection | O(n + m) |
| Size | O(n) |

**Best for**: Unique elements, membership testing, set operations

## 3. Maps

### Structure

**Maps** are key-value stores implemented as balanced trees:
```hoon
+$  map  [key value]
  (tree [p=key q=value])
```

### Construction

```hoon
::  Empty map
~
*(map @tas @ud)

::  From list of pairs
(my ~[[%a 1] [%b 2] [%c 3]])

::  Using ~(by map)
=/  m  *(map @tas @ud)
=/  m  (~(put by m) %a 1)
=/  m  (~(put by m) %b 2)
m
```

### Core Operations

```hoon
=/  my-map  (my ~[[%a 1] [%b 2] [%c 3]])

::  Get (lookup)
(~(get by my-map) %a)    ::  `1
(~(get by my-map) %z)    ::  ~ (not found)

::  Got (lookup, crash if missing)
(~(got by my-map) %a)    ::  1

::  Gut (get with default)
(~(gut by my-map) %z 0)  ::  0 (default)

::  Has (key exists?)
(~(has by my-map) %a)    ::  %.y
(~(has by my-map) %z)    ::  %.n

::  Put (insert/update)
(~(put by my-map) %d 4)  ::  Map with [%d 4]

::  Del (remove)
(~(del by my-map) %b)    ::  Map without %b

::  Tap (convert to list of pairs)
~(tap by my-map)         ::  ~[[%a 1] [%b 2] [%c 3]]

::  Run (map over values)
%~  run  by  my-map
|=(v=@ud (mul v 2))
::  {[%a 2] [%b 4] [%c 6]}

::  Urn (map over key-value pairs)
%~  urn  by  my-map
|=([k=@tas v=@ud] (add v 10))
::  {[%a 11] [%b 12] [%c 13]}

::  Rep (fold over map)
%~  rep  by  my-map
|=([[k=@tas v=@ud] acc=@ud] (add v acc))
::  6

::  Gas (insert multiple)
(~(gas by my-map) ~[[%d 4] [%e 5]])

::  Uni (union, right wins on conflict)
%+  ~(uni by (my ~[[%a 1]]))
(my ~[[%a 10] [%b 2]])
::  {[%a 10] [%b 2]}

::  Int (intersection)
%+  ~(int by (my ~[[%a 1] [%b 2]]))
(my ~[[%b 20] [%c 3]])
::  {[%b 2]}  ::  Left values kept

::  Dif (difference)
%+  ~(dif by (my ~[[%a 1] [%b 2]]))
(my ~[[%b 20]])
::  {[%a 1]}
```

### Performance

| Operation | Time Complexity |
|-----------|----------------|
| Get | O(log n) |
| Put | O(log n) |
| Del | O(log n) |
| Has | O(log n) |

**Best for**: Key-value storage, dictionaries, caches, indexed data

## 4. Mops (Ordered Maps)

### Structure

**Mops** are ordered maps that maintain key ordering:
```hoon
+$  mop  [key value]
  ::  Ordered map (keys comparable)
```

### Usage

```hoon
::  Mops require defining a comparator; there is no `mo` constructor.
::  Use the +on core to create mop operations:
=/  compare  |=([a=@ud b=@ud] (lth a b))
=/  mop-on  ((on @ud @t) compare)

::  Build a mop by inserting entries
=/  m  *((mop @ud @t) compare)
=/  m  (put:mop-on m [1 'a'])
=/  m  (put:mop-on m [2 'b'])
~(tap by m)  ::  Returns in key order
```

### When to Use

- Need sorted keys
- Range queries
- Ordered iteration
- Time-series data

## 5. Jars and Jugs

### Jar (Map of Lists)

**Jar**: Map from key to list of values
```hoon
+$  jar  [key value]
  (map key (list value))

::  Usage
=/  j  *(jar @tas @ud)
=/  j  (~(add ja j) %group 1)
=/  j  (~(add ja j) %group 2)
=/  j  (~(add ja j) %other 3)
j  ::  {[%group ~[2 1]] [%other ~[3]]}

::  Get all values for key
(~(get ja j) %group)  ::  ~[2 1]
```

**Best for**: Multi-valued mappings, grouping, inverted indexes

### Jug (Map of Sets)

**Jug**: Map from key to set of values
```hoon
+$  jug  [key value]
  (map key (set value))

::  Usage
=/  j  *(jug @tas @ud)
=/  j  (~(put ju j) %group 1)
=/  j  (~(put ju j) %group 2)
=/  j  (~(put ju j) %group 1)  ::  Duplicate ignored
j  ::  {[%group {1 2}]}

::  Has value for key?
(~(has ju j) %group 1)  ::  %.y
```

**Best for**: Many-to-many relationships, tagging, categorization

## 6. Mips

### Structure

**Mips** are maps of maps as balanced trees:
:: note that mip is in its own non-standard file
:: using any mip arm requires qualifying the arm bi:mip with the file
:: for example: mip:mip
```hoon
|%
++  mip                                                 ::  map of maps
  |$  [kex key value]
  (map kex (map key value))
```

### Construction

```hoon
::  Empty mip
*(mip:mip @p @tas typ-addr)

::  From list of pairs
(my ~[[%a 1] [%b 2] [%c 3]])

::  Using ~(bi mip)
=/  m  *(mip:mip @p @tas @ud)
=.  m  %^  ~(put bi:mip lookup)  ~sampel-palnet
                                 'word'
                                 42
```

### Core Operations

```hoon
=/  my-mip  *(mip:mip @tas @tas @ud)

::  Del (remove)
(~(del bi:mip my-mip) %a %b)

::  Get (lookup)
(~(get bi:mip my-mip) %a %b)    ::  `1
(~(get bi:mip my-mip) %z %d)    ::  ~ (not found)

::  Got (lookup, crash if missing)
(~(got bi:mip my-mip) %a %b)    ::  1

::  Gut (get with default)
(~(gut bi:mip my-mip) %z %d 42)  ::  42 (default)

::  Has (key exists?)
(~(has bi:mip my-mip) %a %b)    ::  %.y
(~(has bi:mip my-mip) %z %d)    ::  %.n

:: Key (returns the set of second keys referenceb by first key)
(~(key bi:mip my-mip) %a)       :: {%b}
(~(key bi:mip my-mip) %z)       ::  ~
                       
::  Put (insert/update)
(~(put bi:mip my-mip) %a %b 4)

::  Tap (convert to list of pairs)
~(tap bi:mip my-mip)         ::  ~[[%a %b 1] [%aa %b 2] [%aaa %c 3]]

```

## 7. Custom Data Structures

### Queue (FIFO)

```hoon
+$  queue  [item]
  $:  front=(list item)
      back=(list item)
  ==

++  enqueue
  |*  [q=queue item=*]
  q(back [item back.q])

++  dequeue
  |*  q=queue
  ^-  [(unit _?>(?=(^ front.q) i.front.q)) queue]
  ?^  front.q
    [`i.front.q q(front t.front.q)]
  ?~  back.q
    [~ q]
  =.  front.q  (flop back.q)
  =.  back.q   ~
  [`i.front.q q(front t.front.q)]
```

### Priority Queue (Heap)

```hoon
+$  heap  [item]
  $@  ~
  [value=item size=@ud left=(heap item) right=(heap item)]

++  insert-heap
  |*  [h=heap item=*]
  ::  Insert with heap property
  ...

++  extract-min
  |*  h=heap
  ::  Remove minimum element
  ...
```

### Trie (Prefix Tree)

```hoon
+$  trie  [value]
  $:  value=(unit value)
      children=(map @t (trie value))
  ==

++  trie-insert
  |*  [t=trie key=tape value=*]
  ::  Insert key-value into trie
  ...

++  trie-lookup
  |*  [t=trie key=tape]
  ::  Lookup value by key
  ...
```

## 8. Choosing Data Structures

### Decision Guide

**Need fast lookup by key?**
- Use `map` (O(log n) lookup)

**Need unique elements only?**
- Use `set` (O(log n) membership)

**Need ordered processing?**
- Use `list` for sequential
- Use `mop` for sorted keys

**Need multi-valued keys?**
- Use `jar` for lists
- Use `jug` for unique sets

**Need fast prepend/pop?**
- Use `list` as stack (O(1))

**Need fast enqueue/dequeue?**
- Use custom `queue` (amortized O(1))

### Performance Comparison

| Structure | Lookup | Insert | Delete | Memory |
|-----------|--------|--------|--------|--------|
| list | O(n) | O(1) prepend | O(n) | O(n) |
| set | O(log n) | O(log n) | O(log n) | O(n log n) |
| map | O(log n) | O(log n) | O(log n) | O(n log n) |
| jar/jug | O(log n) | O(log n) | O(log n) | O(n log n) |

## 9. Common Patterns

### Pattern 1: Convert Between Structures

```hoon
::  List → Set
(silt ~[1 2 3 2 1])  ::  {1 2 3}

::  List → Map (with indexing)
%+  roll  ~['a' 'b' 'c']
|=  [item=@t [idx=@ud m=(map @ud @t)]]
[(add idx 1) (~(put by m) idx item)]

::  Map → List
~(tap by (my ~[[%a 1] [%b 2]]))  ::  ~[[%a 1] [%b 2]]

::  Set → List
~(tap in (silt ~[1 2 3]))  ::  ~[1 2 3]
```

### Pattern 2: Aggregate Operations

```hoon
::  Count occurrences
++  count-occurrences
  |=  items=(list @t)
  ^-  (map @t @ud)
  %+  roll  items
  |=  [item=@t counts=(map @t @ud)]
  =/  current  (~(gut by counts) item 0)
  (~(put by counts) item +(current))

::  Group by property
++  group-by-age
  |=  users=(list [name=@t age=@ud])
  ^-  (jar @ud @t)
  %+  roll  users
  |=  [[name=@t age=@ud] groups=(jar @ud @t)]
  (~(add ja groups) age name)
```

### Pattern 3: Caching

```hoon
|_  cache=(map @t @ud)
++  get-or-compute
  |=  [key=@t compute=$-(@ @ud)]
  ^-  [@ud _..get-or-compute]
  =/  cached  (~(get by cache) key)
  ?^  cached
    [u.cached ..get-or-compute]
  =/  result  (compute)
  [result ..get-or-compute(cache (~(put by cache) key result))]
--
```

### Pattern 4: Index Building

```hoon
::  Build inverted index
++  build-index
  |=  documents=(list [id=@ud words=(list @t)])
  ^-  (jug @t @ud)
  %+  roll  documents
  |=  [[id=@ud words=(list @t)] index=(jug @t @ud)]
  %+  roll  words
  |=  [word=@t idx=(jug @t @ud)]
  (~(put ju idx) word id)
```

## Resources

- [Standard Library](https://docs.urbit.org/language/hoon/reference/stdlib) - Data structure docs
- [2a-2d Reference](https://docs.urbit.org/language/hoon/reference/stdlib/2a) - List functions
- [2h Reference](https://docs.urbit.org/language/hoon/reference/stdlib/2h) - Set/map functions

## Summary

Hoon data structures:
1. **Lists** - Sequential, O(1) prepend, good for small collections
2. **Sets** - Unique elements, O(log n) operations
3. **Maps** - Key-value, O(log n) lookup
4. **Mops** -  (Ordered Maps)
5. **Jars/Jugs** - Multi-valued mappings
6. **Mips** - maps of maps
7. **Choose based on** access patterns and performance needs
8. **Custom structures** for specialized requirements

Mastering data structure selection and usage is key to writing efficient Hoon code.
