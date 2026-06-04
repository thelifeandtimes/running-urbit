---
name: debugging-specialist-assistant
description: Hoon error diagnosis expert for systematic debugging, error interpretation, and root cause analysis. Use when encountering compilation errors, runtime failures, type mismatches, or cryptic Hoon error messages.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Hoon Debugging Specialist

Systematic diagnostics for Hoon compilation errors, runtime issues, and logic bugs. Translates cryptic error messages into actionable fixes.

## Error Types & Solutions

### Type Errors

#### nest-fail (Type Mismatch)
```
nest-fail
ford: %slim failed:
dojo: hoon expression failed
```
**Cause**: Attempting to fit a value of one type into another incompatible type.

**Debugging steps**:
1. Check the expression causing the error
2. Verify type casts (`^-`) are correct
3. Examine mold structure for exact field matching
4. Use `!>` in dojo to inspect inferred types

**Common fixes**:
```hoon
::  Wrong: direct cast between incompatible types
=/  num  5
^-  @t  num  ::  nest-fail

::  Fix: use conversion function
=/  num  5
(scot %ud num)  ::  Produces @t (tape)
```

#### nest-fail with `*`-Typed Nouns
```
nest-fail
-have.*
-need.?(%.y %.n)
```
**Cause**: Using specific atom values in nested positions of a `?=` pattern
when the subject is `*`-typed (e.g., `|=  parsed=*`).

**Example**:
```hoon
|=  parsed=*
::  FAILS: compiler can't resolve ?= to a loobean against *
?:  ?=([%tag [%inner 'specific' @ *] *] parsed)
  ...
```

**Fix**: check structure with `?=` first, then use `=` for value checks:
```hoon
?:  ?=([%tag [%inner *] *] parsed)
  ?:  =('specific' +<+<.parsed)
    ...
```

---

```
nest-fail
-have.[%my-tag name=* alias=%~]
-need.some-type
```
**Cause**: After `?=([%my-tag *] parsed)`, the inner fields are still `*`.
Using `` `@tas`+>-.parsed `` (backtick cast) fails because `*` doesn't nest
in `@tas`.

**Fix**: extract the field and narrow with `?=`:
```hoon
?:  ?=([%my-tag *] parsed)
  =/  val  +>-.parsed
  ?>  ?=(@ val)        ::  narrows * to @, which nests in @tas
  [%result name=val]   ::  ✓ compiles
```

Alternatively, use `;;` for runtime normalization of the whole structure:
```hoon
;;(my-type:ast parsed)
```

#### find-fork (Incomplete Pattern Match)
```
find-fork
ford: %slim failed
```
**Cause**: `?-` switch statement is missing a case.

**Debugging steps**:
1. Find the `?-` expression
2. List all possible cases
3. Ensure each case is covered
4. Consider `?+` with default branch

**Common fixes**:
```hoon
::  Wrong: missing case
?-  type
    %num  (add 1 num)
    %txt  (crip txt)

::  Fix: add default branch
?+  type
    %num  (add 1 num)
    %txt  (crip txt)
  $(default-value)
```

#### fish-loop with recursive molds

`?=` pattern matching can trigger `fish-loop` when used directly against
recursive molds such as `tree`, `list`, and containers built on trees (`map`,
`set`, etc.).

**Fix**: when matching a union that contains a recursive mold, match the
non-recursive branch first, or narrow by tag/outer structure before inspecting
the recursive value.

```hoon
::  Wrong: may fish-loop on recursive predicate mold
+$  predicate     (tree predicate-component)
+$  predicate-or-dime
  $:  %predicate-or-dime
    when=$%(predicate dime)
    then=dime
    ==
?:  ?=(predicate when-cwt)
  do-foo
do-kung-foo

::  Fix: test the non-recursive union arm first
?:  ?=(dime when-cwt)
  do-kung-foo
do-foo
```

#### mint-vain (Unused Value)
```
mint-vain
```
**Cause**: Computation was evaluated but result never used.

**Debugging steps**:
1. Locate the expression with `mint-vain`
2. Either use the value or remove the computation

**Common fixes**:
```hoon
::  Wrong: unused computation
=/  result  (complex-calc input)
(do-something-else input)  ::  result not used

::  Fix: remove or use
(do-something-else input)
::  Or use the result
=/  result  (complex-calc input)
(do-something-with result)
```

### Resolution Errors

#### find-limb (Undefined Variable)
```
-find-limb.foo
ford: %slim failed
```
**Cause**: Reference to a face or arm that doesn't exist in the subject.

**Debugging steps**:
1. Verify spelling of the face name
2. Check the face is in scope
3. Ensure the face is properly introduced in the subject
4. For arms: verify they're in the core battery

**Common fixes**:
```hoon
::  Wrong: typo in face name
|%
++  process-data
  |=  data=*
  (calcuate-with dat.value)  ::  calcuate typo
--
::  Fix: correct spelling
++  process-data
  |=  data=*
  (calculate-with data.value)  ::  calculate correct
```

#### find-face (Face Not Found)
```
-find-face.bar
```
**Cause**: Specific face name not found in the subject.

**Debugging steps**:
1. Trace subject construction backwards
2. Verify face is introduced before use
3. Check for shadowing (redefined faces)
4. Ensure proper scoping

### Runtime Errors

#### bail: meme (Out of Memory)
```
bail: meme
[%error ...]
```
**Cause**: Exceeded loom size (memory limit), typically ~2GB-4GB.

**Debugging steps**:
1. Check for infinite loops or recursion
2. Reduce memory usage:
   - Use streaming instead of loading all data
   - Process incrementally
   - Free unused intermediate results
3. Increase loom size with `--loom <31|32|33>` command

**Common fixes**:
```hoon
::  Wrong: loading entire list into memory
=/  huge-data  (scan-file "large.csv")
(flatten huge-data)  ::  May exceed loom

::  Fix: process incrementally
:-  %gold  *process-chunk
=+  chunk  (read-chunk)
(process-chunk chunk)
```

For experimental development with an effectively unlimited loom size, look at the `vere64` project: https://urbit.org/blog/developer-preview-vere64

#### bail: exit (Assertion Failure)
```
bail: exit
```
**Cause**: `?>` assertion failed, `?<` test failed, or `!!` trap triggered.

**Debugging steps**:
1. Find the assertion (`?>`, `?<`, `!!`)
2. Examine the condition
3. Check input values
4. Add print debugging if needed

**Common fixes**:
```hoon
::  Wrong: assertion fails on edge case
?>  (lth (lent list) 10)

::  Fix: handle empty list
?>  (gth (lent list) 0)
```

### Gall Agent Errors

#### poke-ack (Poke Acknowledgment)
```
[%poke-ack %error ...]
```
**Cause**: Agent crashed during `on-poke` handling.

**Debugging steps**:
1. Check `on-poke` for type errors
2. Verify action handler exists
3. Examine state corruption
4. Add `~&` print statements to trace execution

**Common fixes**:
```hoon
::  Wrong: missing action handler
++  on-poke
  |=  poke=poke
  ^-  +(new-state new-wires)
  (handle-action poke.data)  ::  handler not defined

::  Fix: define action handler
++  handle-action
  |=  action=action
  ^-  (unit result)
  (process action)
```

#### sub-fail (Subscription Failure)
```
[%sub-fail ...]
```
**Cause**: Agent crashed during subscription handling.

**Debugging steps**:
1. Check `on-watch` for type errors
2. Verify subscription path is valid
3. Examine agent state at time of subscription
4. Check for circular subscription dependencies

## Systematic Debugging Process

### 1. Reproduce the Issue
- Create minimal failing case
- Isolate from other code
- Verify error is reproducible

### 2. Inspect Error Context
- Read the full error message
- Note the file and line number
- Identify the error category (type, resolution, runtime, Gall)

### 3. Use Dojo Inspection Tools

#### `!>` (Inspect Type)
```hoon
!>(my-expression)
```
Shows the inferred type of any expression.

#### `!<` (Inspect Value)
```hoon
!<(my-value)
```
Pretty-prints a value for debugging.

#### `?>` (Assertion)
```hoon
?>  (my-condition)
```
Halts execution with trace if condition is false.

### 4. Hypothesize and Test
- Form 2-3 likely causes
- Create test cases for each
- Systematically eliminate hypotheses

### 5. Binary Search for Location
- Comment out half the code
- If error persists, bug is in other half
- Repeat until isolated

### 6. Verify Fix
- Apply the proposed fix
- Reproduce the original failure scenario
- Ensure fix doesn't break other functionality

## Common Debugging Patterns

### Print Debugging
```hoon
++  process
  |=  input=*
  ~&  'Processing: ' (scot %ud input)
  (do-work input)
```

### Trace Crash Sites

Use `~|` around known crash points so the crash includes the relevant context.

```hoon
::  Weak: crash loses local context
(potential-crash param)

::  Better: trace includes the value that led to the crash
~|  "failed at potential crash site {<param>}"
    (potential-crash param)
```

### Incremental Building
```hoon
::  Don't build all at once
::  Test each increment
=/  step1  (first-step input)
=/  step2  (second-step step1)
(do-something step2)
```

### Type Inspection
```hoon
::  Check types at every step
=/  typed  !>(some-expression)
=/  casted  ^-@t typed
(use-value casted)
```

## Gall-Specific Debugging

### State Inspection
```hoon
++  debug-state
  |=  =(vase)
  ~&  'State: ' (scot %ud !<(v.u.state))
```

### Subscription Tracing
```hoon
++  on-watch
  |=  path=path
  ~&  'Watching: ' (scot %tas !<path)
  (add-watch path v.state v.watches)
```

### Effect Tracing
```hoon
++  on-poke
  |=  poke=poke
  ~&  'Poke: ' (scot %tas !<poke.data))
  ^-  +(new-state [new-wires new-effects])
  (process poke.data v.state)
```

## Debugging Checklists

### Before Asking for Help
- [ ] Error message copied exactly as shown
- [ ] File and line number identified
- [ ] Minimal failing case created
- [ ] Attempted basic debugging steps
- [ ] Searched documentation for error type

### What to Include When Asking
1. Full error message (verbatim)
2. Relevant code snippet (10-20 lines around error)
3. Input values causing the error
4. What you've tried so far
5. Expected vs actual behavior

## Resources

- [Hoon Errors](https://docs.urbit.org/hoon/hoon-errors)
- [App School (Gall agents)](https://docs.urbit.org/build-on-urbit/app-school)
- [Dojo Tools](https://docs.urbit.org/user-manual/os/dojo-tools)
- [Testing Code (debugging strategies)](https://docs.urbit.org/build-on-urbit/hoon-school/i-testing)
