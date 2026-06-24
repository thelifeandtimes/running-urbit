---
name: data-structures
description: Master Hoon's built-in data structures including lists, sets, maps, mops (ordered maps), jars, jugs, and trees with their operations and performance characteristics. Use when choosing data structures, optimizing algorithms, building complex applications, or understanding standard library collections.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Data Structures Skill

Master Hoon's built-in data structures including lists, trees, sets, maps, mops
(ordered maps), queues, jars, and jugs. Use when choosing data structures,
optimizing algorithms, or building complex applications.

## Overview

Hoon provides functional data structures built on the noun foundation. This
skill covers the **eight standard containers** — `list`, `tree`, `set`, `map`,
`mop`, `qeu`, `jar`, `jug` — with their engine cores and conversions.

`set`, `map`, `qeu`, `mop`, `jar`, and `jug` are all **treap-shaped**: a treap
is a binary tree that is simultaneously a search tree (horizontally, by key) and
a heap (vertically, by the `+mug` hash of the key, via `+mor`). The validated
molds wrap a `tree` as `$|((tree …) …apt…)`. Each container has a door
(`+in`, `+by`, `+to`, `+on`, `+ja`, `+ju`) holding its operation arms.

Most stdlib containers live in `hoon.hoon` and are documented in the stdlib
pages (2h–2o). The **ordered map** (`+mop` / `+on`) is defined in Zuse and
documented in `hoon/zuse/2m.md`. That is purely a citation difference — `mop` is
a first-class container with the same standing as the others.

| Container | Mold | Engine door | Reference |
|-----------|------|-------------|-----------|
| list | `(list a)` | (list functions, 2b) | stdlib 2b |
| tree | `(tree a)` | — | stdlib 1c |
| set | `(set a)` | `+in` | stdlib 2h, 2o |
| map | `(map k v)` | `+by` | stdlib 2i, 2o |
| mop | `((mop k v) cmp)` | `+on` | zuse 2m |
| qeu | `(qeu a)` | `+to` | stdlib 2k, 2o |
| jar | `(jar k v)` | `+ja` | stdlib 2j, 2o |
| jug | `(jug k v)` | `+ju` | stdlib 2j, 2o |

## Learning Objectives

1. Choose appropriate data structures for tasks
2. Perform efficient operations on each structure
3. Understand performance trade-offs
4. Use standard library functions effectively
5. Convert between containers
6. Use ordered maps (`mop`) for ordered, historical, and range access

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

### Accessing i. and t. — CRITICAL RULE

`(list a)` is the fork `$@(~ [i=a t=(list a)])`. The faces `i` and `t` only
exist in the non-null branch. **The only rune that narrows a list to its
non-null variant and makes `i.` and `t.` accessible is `?~`.**

`lent` comparisons, `?=` assertions, and `?.` guards on `lent` do NOT narrow
the type. Using `i.` after any of these will produce a `find-fork` error.

```hoon
::  WRONG — lent does not narrow the type; find-fork on i.xs
?.  =(1 (lent xs))
  !!
=/  head  i.xs       ::  find-fork!

::  CORRECT — ?~ narrows to non-null; i. and t. are now valid
?~  xs
  ~|("empty" !!)
=/  head  i.xs       ::  ok

::  Exactly-one check: ?~ first, then check t. is ~
?~  xs
  ~|("empty" !!)
?.  =(~ t.xs)
  ~|("more than one" !!)
=/  only  i.xs       ::  ok — xs has exactly one element
```

#### Deep wings and find-fork

Even after `?~` narrows a list, accessing a face inside `i.` via a deep wing
path (e.g. `data.i.some-list`) can still produce `find-fork` when the
compiler encounters multiple `data` faces in the subject (e.g. if both
`indexed-row` and `joined-row` in scope both have a `data` field).

**Fix**: bind `i.xs` to an explicitly-typed intermediate first, then access
the face on that binding:

```hoon
::  WRONG — find-fork if 'data' appears in multiple types in scope
=/  val  (~(got by data.i.indexed-rows.st) col-name)

::  CORRECT — bind to typed intermediate; data.irow is unambiguous
=/  irow=indexed-row  i.indexed-rows.st
=/  val  (~(got by data.irow) col-name)
```

### Core Operations

```hoon
(lent ~[1 2 3 4])     ::  4         length
(flop ~[1 2 3])       ::  ~[3 2 1]  reverse
(weld ~[1 2] ~[3 4])  ::  ~[1 2 3 4]  concatenate
(snoc ~[1 2 3] 4)     ::  ~[1 2 3 4]  append (O(n) — avoid in loops!)
(scag 2 ~[1 2 3 4])   ::  ~[1 2]    take first N
(slag 2 ~[1 2 3 4])   ::  ~[3 4]    drop first N
(snag 2 ~[10 20 30])  ::  30        element at index (0-indexed)
(find ~[2 3] ~[1 2 3 4])  ::  [~ 1]   index of sublist, as a unit
```

### Higher-Order Functions

```hoon
::  Map (transform each)
(turn ~[1 2 3] |=(n=@ud (mul n 2)))      ::  ~[2 4 6]
::  Filter (keep matching)
(skim ~[1 2 3 4 5] |=(n=@ud =(0 (mod n 2))))   ::  ~[2 4]
::  Reject (remove matching)
(skip ~[1 2 3 4 5] |=(n=@ud =(0 (mod n 2))))   ::  ~[1 3 5]
::  Fold left (accumulate)
(roll ~[1 2 3 4] |=([n=@ud acc=@ud] (add acc n)))   ::  10
::  Fold right
(reel ~[1 2 3 4] |=([n=@ud acc=@ud] (add n acc)))   ::  10
```

> **Prefer `turn`** to extract or transform a field across a list; never hand-roll
> `|-` recursion for that. Example: `(turn cases |=(c=case-when-then:ast when.c))`.

### Performance

| Operation | Cost |
|-----------|------|
| Prepend (cons) / head / tail | constant |
| Length / index / search / append | linear |
| Concatenate | linear in both inputs |

**Best for**: Sequential access, stacks, small collections.
**Avoid for**: Random access, frequent appends, large lookup-heavy datasets.

## 2. Trees

### Structure

The `tree` is the binary-tree foundation under sets, maps, queues, and mops:
```hoon
++  tree
  |$  [node]
  $@(~ [n=node l=(tree node) r=(tree node)])
```
A node `n`, with left `l` and right `r` subtrees, or `~` for empty.

You rarely build a bare `tree` directly. The standard containers wrap a tree
with a validating mold and an engine door, of the form
`$|((tree …) |=(a (tree)) …apt…)` — a tree plus a correctness check. Knowing
the shape helps read pretty-printed output and balance/ordering arms
(`+apt`, `+mor`).

## 3. Sets — `+in`

### Structure

A `+set` is an **unordered treap** of unique items:
```hoon
++  set  |$  [item]  $|((tree item) |=(a=(tree) ?:(=(~ a) & ~(apt in a))))
```

### Construction

```hoon
*(set @ud)              ::  empty
(silt ~[1 2 3 2 1])     ::  {1 2 3}  from list (dedups)
(~(put in *(set @ud)) 1)
```

### Core Operations (`+in`)

```hoon
=/  s  (silt ~[1 2 3 4 5])

(~(has in s) 3)          ::  %.y      membership
(~(put in s) 6)          ::  add element
(~(del in s) 3)          ::  remove element
~(tap in s)              ::  list (unordered)
~(wyt in s)              ::  5        size
(~(gas in s) ~[6 7])     ::  insert many

::  map / fold over a set
(~(run in s) |=(n=@ud (mul n 2)))                ::  {2 4 6 8 10}
(~(rep in s) |=([n=@ud acc=@ud] (add n acc)))    ::  15

::  set algebra
(~(int in (silt ~[1 2 3])) (silt ~[2 3 4]))  ::  {2 3}    intersection
(~(uni in (silt ~[1 2 3])) (silt ~[3 4 5]))  ::  {1..5}   union
(~(dif in (silt ~[1 2 3])) (silt ~[2 3 4]))  ::  {1}      difference
```

| Operation | Cost |
|-----------|------|
| has / put / del | logarithmic (treap) |
| uni / int / dif | linear in inputs |
| tap / wyt | linear |

**Best for**: Unique elements, membership testing, set algebra.
**Avoid for**: Associating data with keys (use `map`), ordered iteration, or
preserving insertion order — `~(tap in)` order is hash order, not insertion.

## 4. Maps — `+by`

### Structure

A `+map` is a **treap of key-value pairs**, ordered by `+mug` hash of the key:
```hoon
++  map
  |$  [key value]
  $|  (tree (pair key value))
  |=(a=(tree (pair)) ?:(=(~ a) & ~(apt by a)))
```

### Construction

```hoon
*(map @tas @ud)                  ::  empty
(my ~[[%a 1] [%b 2] [%c 3]])     ::  from a literal pair list
(malt key-value-list)            ::  from a (list [key value])
(~(put by *(map @tas @ud)) %a 1)
```

### Core Operations (`+by`)

```hoon
=/  m  (my ~[[%a 1] [%b 2] [%c 3]])

(~(get by m) %a)         ::  [~ 1]    lookup → unit
(~(got by m) %a)         ::  1        lookup, crash if missing
(~(gut by m) %z 0)       ::  0        lookup with default
(~(has by m) %a)         ::  %.y      key exists?
(~(put by m) %d 4)       ::  insert / update
(~(del by m) %b)         ::  remove
~(tap by m)              ::  ~[[%a 1] [%b 2] [%c 3]]  list of pairs
~(key by m)              ::  {%a %b %c}  set of keys
~(val by m)              ::  ~[1 2 3]    list of values
(~(gas by m) ~[[%d 4] [%e 5]])   ::  insert many

::  transform
(~(run by m) |=(v=@ud (mul v 2)))               ::  values → values
(~(urn by m) |=([k=@tas v=@ud] (add v 10)))     ::  over key+value
(~(rep by m) |=([[k=@tas v=@ud] acc=@ud] (add v acc)))   ::  fold

::  combine (right operand wins on key conflict for uni)
(~(uni by (my ~[[%a 1]])) (my ~[[%a 10] [%b 2]]))   ::  {[%a 10] [%b 2]}
(~(int by (my ~[[%a 1] [%b 2]])) (my ~[[%b 20]]))   ::  {[%b 2]} (left vals)
(~(dif by (my ~[[%a 1] [%b 2]])) (my ~[[%b 20]]))   ::  {[%a 1]}
```

| Operation | Cost |
|-----------|------|
| get / got / gut / has / put / del | logarithmic (treap) |
| tap / run / urn / rep / key / val | linear |

**Best for**: Key-value storage, dictionaries, caches, indexed data — when key
*ordering does not matter*.
**Avoid for**: Ordered iteration, ranges, min/max, or "as-of" lookups — `~(tap
by)` yields hash order, not key order. Use a `mop` for any of those.

## 5. Mops (Ordered Maps) — `+on`

A `+mop` is a **treap of key-value pairs ordered by a comparator gate of your
choosing**, rather than by the `+mug` hash of the key. It is defined in Zuse,
not the core stdlib; `+on` (alias `+ordered-map`) is its operation door.

### Why the comparator is part of construction

```hoon
++  mop
  |*  [key=mold value=mold]
  |=  ord=$-([key key] ?)            ::  comparator gate baked into the mold
  |=  a=*  ... ?>  (apt:((on key value) ord) b)  b
```

The comparator `$-([key key] ?)` returns `%.y` if its first argument should sort
**before** the second. It defines the tree's horizontal order, so it is supplied
both when building the mold *and* when building the operation door — and the two
**must be the same gate**. Construct with `((mop key value) cmp)` and operate
with `((on key value) cmp)`.

> **Warning:** a mop is corrupt if two keys can be unequal under noun equality
> yet equal under the comparator. The comparator must impose a strict total
> order on keys — total (any two distinct keys compare), and strict (never
> report `%.y` in both directions, i.e. no ties). A non-strict or partial
> comparator silently breaks lookups and traversal.

### Construction

```hoon
::  empty mop, ascending @ keys
*((mop @ @) lth)

::  operation door bound to the same comparator
=/  m-on  ((on @ @) lth)

::  build by inserting key^value pairs with gas (or put one at a time)
=/  m  (gas:m-on *((mop @ @) lth) ~[1^10 2^20 3^30])
(tap:m-on m)   ::  ~[[key=1 val=10] [key=2 val=20] [key=3 val=30]]  in key order
```

There is **no `+malt`-style constructor** for mops — ordinary map constructors
produce hash order and will fail the mop's `+apt` check. Build with `gas:on` /
`put:on`, and never read a mop with the `+by` map door.

### Core Operations (`+on`)

```hoon
=/  on  ((on @ @) gth)                          ::  descending keys
=/  m   (gas:on *((mop @ @) gth) ~[1^1 2^2 3^3 4^4 5^5])

::  lookup
(get:on m 3)         ::  [~ 3]     value at key → unit
(got:on m 3)         ::  3         crash if missing
(has:on m 3)         ::  %.y

::  insert / delete
(put:on m 7 7)       ::  add/replace one pair
(gas:on m ~[6^6 7^7])  ::  add many
(del:on m 2)         ::  [(unit val) mop]  produces deleted value + new mop

::  ends and ordered traversal
(pry:on m)           ::  (unit item)  leftmost (head) item
(ram:on m)           ::  (unit item)  rightmost (tail) item
(pop:on m)           ::  [head=item rest=mop]  pop leftmost, crash if empty
(tap:on m)           ::  (list item)  left-to-right
(bap:on m)           ::  (list item)  right-to-left

::  range / window
(lot:on m `4 ~)      ::  subset with keys strictly past `4` (start/end exclusive)
(lot:on m `3 `7)     ::  subset strictly between 3 and 7
(tab:on m `4 100)    ::  up to N items starting after key `4

::  bulk
(run:on m succ)      ::  transform every value in place
(all:on m |=([k=@ v=@] (gte 3 v)))    ::  logical AND over items
(any:on m |=([k=@ v=@] =(1 v)))       ::  logical OR over items
```

`lot` and `tab` give range/window access — the reason to reach for a mop over a
map. `pry`/`pop`/`ram` give cheap min/max/head-pop because items are kept in
comparator order.

| Operation | Cost |
|-----------|------|
| get / got / has / put / del | logarithmic (treap) |
| pry / ram / pop | logarithmic (descend one edge) |
| lot / tab / tap / bap / run / all / any | linear in the range or map |

### When to use `mop` instead of `map`

- **Ordered keys** — you need to iterate or output in key order.
- **Historical / time-travel lookup** — key by `@da`; fetch "the latest at or
  before T" with a range query.
- **Index structures** — secondary indexes keyed by composite sort keys.
- **Time series** — append-ordered events, scanned by time window.
- **Range-adjacent access** — "next/previous", "first N after K", min/max.

If you only ever look up by exact key and never care about order, a plain `map`
is simpler.

### Obelisk pattern: rebuilding a primary-key index

Real-world (`desk/lib/crud.hoon`, generalized). The primary index is a
`((mop (list @) (map @tas @)) comparator)` whose comparator is derived per-table
from the key columns via `~(order idx-comp …)`. To re-key after a mutation, build
an empty mop with that comparator and `gas` the row pairs in:

```hoon
::  comparator built from the table's key-column descriptors
=/  comparator
  ~(order idx-comp `(list [@ta ?])`(reduce-key key.pri-indx.table))
::  pri-key wraps ((on (list @tas) (map @tas @)) comparator)
=/  primary-key  (pri-key key.pri-indx.table)
=.  pri-idx.file
  %+  gas:primary-key  *((mop (list @) (map @tas @)) comparator)
                       (turn indexed-rows.file |=(a=indexed-row +.a))
```

Key points: the *same* comparator builds the empty `*((mop …) comparator)` and
backs the `gas:primary-key` door; rows become `[key value]` pairs via `turn`.

### Obelisk pattern: historical lookup and a view cache

Real-world (`desk/lib/selections.hoon`, generalized). Schema versions are stored
in a mop keyed by `@da`, ordered descending (`gth`). "Get the schema effective at
`time`" is a range query: trim everything after `time` with `lot`, then take the
head with `pop`:

```hoon
++  get-schema
  |=  [sys=((mop @da schema) gth) time=@da]
  ^-  schema
  =/  time-key  (add time 1)
  ->:(pop:schema-key (lot:schema-key sys `time-key ~))
```

A view cache keyed by a composite `ns-rel-key` uses `tab` to read the most
recent entry and `put:on` to write:

```hoon
::  read: most-recent cache entry at or before the key's time
(tab:view-cache-key q `[ns.key rel.key (add time.key 1)] 1)

::  write: insert with the door bound to the cache's comparator
=/  gate  put:((on ns-rel-key cache) ns-rel-comp)
db(view-cache (gate view-cache.db [key value]))
```

These illustrate the standard idioms: keep the comparator with the mold, use
`lot`/`tab` for "as-of" range reads, and `pop`/`pry` to take the boundary item.

## 6. Queues — `+to`

### Structure

A `+qeu` is an **ordered treap** used as a FIFO queue:
```hoon
++  qeu  |$  [item]  $|((tree item) |=(a=(tree) ?:(=(~ a) & ~(apt to a))))
```
Prefer this standard queue over hand-rolled front/back-list queues.

### Operations (`+to`)

```hoon
=/  q  (~(gas to *(qeu @ud)) ~[1 2 3 4 5])   ::  insert a list

~(top to q)        ::  produces the head item
~(get to q)        ::  [head rest]  head-rest pair
(~(put to q) 6)    ::  insert a new tail
~(nap to q)        ::  remove the root/head, producing the rest
~(tap to q)        ::  convert to list
```

**Best for**: FIFO processing, work queues, breadth-first traversal.
**Avoid for**: Random access or lookup by value (no membership arm); keyed
storage (use `map`). For a plain LIFO stack a bare `list` with cons/`?~` is
simpler.

## 7. Jars and Jugs

### Jar (Map of Lists) — `+ja`

```hoon
++  jar  |$  [key value]  (map key (list value))

=/  j  *(jar @tas @ud)
=/  j  (~(add ja j) %group 1)   ::  prepend to the list at %group
=/  j  (~(add ja j) %group 2)
(~(get ja j) %group)            ::  ~[2 1]   all values for key (empty list if none)
```

`~(get ja j)` returns the empty list `~` for an absent key (never crashes), so
no `unit` to unwrap. `~(add ja j)` prepends, so the value list is in
reverse-insertion order.

**Best for**: Multi-valued mappings, grouping, inverted indexes (ordered, dups
allowed).
**Avoid for**: Membership/dedup of values (use `jug`); single-valued keys (use
`map`).

### Jug (Map of Sets) — `+ju`

```hoon
++  jug  |$  [key value]  (map key (set value))

=/  j  *(jug @tas @ud)
=/  j  (~(put ju j) %group 1)
=/  j  (~(put ju j) %group 2)
=/  j  (~(put ju j) %group 1)   ::  duplicate ignored
(~(has ju j) %group 1)          ::  %.y
(~(get ju j) %group)            ::  {1 2}
(~(del ju j) %group 1)          ::  remove one value from the set
(~(gas ju j) ~[[%a 1] [%a 2]])  ::  insert many
```

`~(get ju j)` returns the empty set for an absent key. `~(put ju j)` dedups
within the value set.

**Best for**: Many-to-many relationships, tagging, categorization (unique values).
**Avoid for**: Preserving order or duplicates among values (use `jar`);
single-valued keys (use `map`).

## 8. Conversions

```hoon
::  list → set
(silt ~[1 2 3 2 1])             ::  {1 2 3}

::  list → map
(malt ~[[%a 1] [%b 2]])         ::  from a (list [key value])
(molt ~[[%a 1] [%b 2]])         ::  from a (list (pair …)); +malt's helper

::  raw/literal noun → container (no explicit (list …) cast needed)
(my ~[[%a 1] [%b 2]])           ::  map from a literal pair list
(sy ~[1 2 3])                   ::  set from a literal list
(ly ~[1 2 3])                   ::  list from a raw noun (see caveat below)

::  container → list
~(tap in some-set)              ::  set → list (unordered)
~(tap by some-map)              ::  map → list of [key value] pairs
(tap:on some-mop)               ::  mop → list of items, in key order
```

`+nl` is the noun-to-container helper core behind these literal builders.

> **`+ly` caveat:** `+ly` uses the *crash* type for the empty list, so
> `(scag 0 (ly ~))` produces a `find-fork`/`mull-grow` error where
> `(scag 0 ((list @) ~))` is fine. Prefer `limo`/an explicit `(list …)` cast for
> lists you will pattern-match on.

Mops have **no list-based constructor** — see §5; build them with `gas:on`.

## 9. Which structure should I use?

| Need | Use |
|------|-----|
| Sequential access, stack, small collection | `list` |
| Unique elements, membership, set algebra | `set` |
| Lookup by key, order irrelevant | `map` |
| Lookup by key **in key order**, ranges, head/tail, time-travel | `mop` |
| FIFO queue, breadth-first | `qeu` |
| One key → many values (ordered, dups) | `jar` |
| One key → set of values (unique) | `jug` |

Decision shortcuts:

- **Ordered processing?** `list` for sequential; `mop` for sorted/ranged keys.
- **`map` vs `mop`?** Exact-key lookup only → `map`. Need order, ranges,
  min/max, or "as-of" history → `mop`.
- **Multi-valued keys?** `jar` (lists) or `jug` (sets).

## 10. Common Patterns

### Convert between structures

```hoon
(silt ~[1 2 3 2 1])               ::  list → set
~(tap by (my ~[[%a 1] [%b 2]]))   ::  map → list of pairs
~(tap in (silt ~[1 2 3]))         ::  set → list
```

### Count occurrences (roll + map)

```hoon
++  count-occurrences
  |=  items=(list @t)
  ^-  (map @t @ud)
  %+  roll  items
  |=  [item=@t counts=(map @t @ud)]
  (~(put by counts) item +((~(gut by counts) item 0)))
```

### Group by property (roll + jar)

```hoon
++  group-by-age
  |=  users=(list [name=@t age=@ud])
  ^-  (jar @ud @t)
  %+  roll  users
  |=  [[name=@t age=@ud] groups=(jar @ud @t)]
  (~(add ja groups) age name)
```

### Build an inverted index (roll + jug)

```hoon
++  build-index
  |=  documents=(list [id=@ud words=(list @t)])
  ^-  (jug @t @ud)
  %+  roll  documents
  |=  [[id=@ud words=(list @t)] index=(jug @t @ud)]
  %+  roll  words
  |=  [word=@t idx=(jug @t @ud)]
  (~(put ju idx) word id)
```

## 11. Non-standard: `mip` (map of maps)

> `mip` is **not** part of the stdlib. It is a separate library; in Obelisk it is
> imported as `mip` and its arms must be qualified with the file, e.g. `bi:mip`,
> `mip:mip`. Use only where that library is in scope.

```hoon
++  mip  |$  [kex key value]  (map kex (map key value))
```

```hoon
=/  m  *(mip:mip @tas @tas @ud)
(~(put bi:mip m) %a %b 4)        ::  insert by outer+inner key
(~(get bi:mip m) %a %b)          ::  [~ 4]   lookup → unit
(~(got bi:mip m) %a %b)          ::  4       crash if missing
(~(gut bi:mip m) %z %d 42)       ::  42      default
(~(has bi:mip m) %a %b)          ::  %.y
(~(key bi:mip m) %a)             ::  {%b}    inner keys under an outer key
(~(del bi:mip m) %a %b)          ::  remove
~(tap bi:mip m)                  ::  list of [outer inner value]
```

## Resources

- [Standard Library](https://docs.urbit.org/hoon/stdlib) — overview
- [stdlib 1c](https://docs.urbit.org/hoon/stdlib/1c) — trees / molds
- [stdlib 2b](https://docs.urbit.org/hoon/stdlib/2b) — list functions
- [stdlib 2h / 2i / 2j / 2k](https://docs.urbit.org/hoon/stdlib/2h) — `+in` / `+by` / `+ja`+`+ju` / `+to`
- [stdlib 2l](https://docs.urbit.org/hoon/stdlib/2l) — `silt` / `malt` / `molt`
- [stdlib 2o](https://docs.urbit.org/hoon/stdlib/2o) — container molds (set/map/qeu/jar/jug)
- [zuse 2m](https://docs.urbit.org/hoon/zuse/2m) — `+mop` / `+on` ordered maps

## Summary

Hoon's standard containers:
1. **list** — sequential, constant-time prepend, good for small collections
2. **tree** — binary-tree foundation under the treap containers
3. **set** (`+in`) — unique elements, logarithmic membership
4. **map** (`+by`) — key-value, hash-ordered, logarithmic lookup
5. **mop** (`+on`) — key-value ordered by a comparator; ordered/range/history
6. **qeu** (`+to`) — FIFO queue
7. **jar** (`+ja`) / **jug** (`+ju`) — one key to a list / set of values
8. **Convert** with `silt`, `malt`, `molt`, `my`, `sy`, `ly`, `nl`; build mops
   with `gas:on`
9. **Choose** by access pattern: exact-key → `map`; ordered/ranged/historical
   keys → `mop`

Mastering data structure selection and usage is key to writing efficient Hoon.
