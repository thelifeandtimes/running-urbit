---
name: hoon-test-workflow
description: Comprehensive testing workflow for Hoon code covering unit tests, integration tests, property-based tests, and test-driven development
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Hoon Testing Command

Complete testing workflow for building robust, well-tested Hoon applications using generators, assertions, and systematic test design.

## Purpose

This command guides developers through creating comprehensive test suites that verify correctness, catch regressions, and enable confident refactoring.

## When to Use

- Before implementing new features (TDD)
- After finding bugs (regression tests)
- When refactoring existing code
- Regular quality assurance
- Before deploying to production
- Documenting expected behavior

## Testing Principles

1. **Test Behavior, Not Implementation** - Test what, not how
2. **Independent Tests** - No dependencies between tests
3. **Fast Feedback** - Tests should run quickly
4. **Clear Failures** - Easy to understand what broke
5. **Comprehensive Coverage** - Test happy paths and edge cases
6. **Maintainable Tests** - Easy to update as code evolves
7. **Valid Hoon Dates** - When writing `@da` literals such as `~2034.12.5`, use real calendar month/day ranges. Never increment the month past 12; roll over to a valid later date such as `~2035.1.*`.

---

## 5-Phase Testing Workflow

### Phase 1: Test Planning

**Objective**: Identify what to test and design test cases.

**Test Type Selection**:

#### Unit Tests
**Purpose**: Test individual functions in isolation
**When**: Pure functions, data transformations, utilities
**Example**: Parsing, validation, calculations

#### Integration Tests
**Purpose**: Test components working together
**When**: Gall agents, multi-agent workflows, state transitions
**Example**: Agent poke → state change → subscription update

#### Property Tests
**Purpose**: Test properties hold across many inputs
**When**: Roundtrip conversions, invariants, generators
**Example**: serialize → deserialize = identity

**Test Case Design**:

```hoon
::  For each function, test:
::  1. Happy path (typical valid input)
::  2. Edge cases (boundary values)
::  3. Error cases (invalid input)
::  4. Special values (empty, zero, null)

::  Example test plan for +parse-number
::  Happy: '42' → 42
::  Edge: '0' → 0, '18446744073709551615' → max @ud
::  Error: 'abc' → ~, '' → ~
::  Special: '0' → 0
```

**Success Criteria**:
- Test cases documented
- Coverage targets defined
- Test structure planned
- Dependencies identified

---

### Phase 2: Unit Testing

**Objective**: Test individual functions with known inputs/outputs.

**Unit Test Structure**:

```hoon
::  /gen/test-my-lib.hoon
::
::  Test suite for my-lib
::
/-  *my-app
/+  *my-lib
::
:-  %say
|=  *
:-  %noun
::
::  Run all tests
::
=/  tests
  :~  test-parse-number
      test-validate-email
      test-calculate-score
  ==
::
%+  turn  tests
|=  test=$-(* ?)
(test)
```

**Test Pattern: Assertion-Based**

```hoon
::  Test case structure
++  test-parse-number
  ^-  [name=@t result=?]
  =/  tests
    :~  ['parse-42' .=(`42 (parse-number '42'))]
        ['parse-0' .=(`0 (parse-number '0'))]
        ['parse-invalid' .=(~ (parse-number 'abc'))]
        ['parse-empty' .=(~ (parse-number ''))]
    ==
  =/  passed  (lent (skim tests |=([n=@t r=?] r)))
  =/  total  (lent tests)
  =/  all-pass  =(passed total)
  ~&  ?:  all-pass
        >  "✓ parse-number: {<passed>}/{<total>} passed"
      >>>  "✗ parse-number: {<passed>}/{<total>} passed"
  ['parse-number' all-pass]
```

**Test Pattern: Example-Based**

```hoon
::  Test with specific examples
++  test-validate-email
  ^-  ?
  &(
    (validate-email 'user@example.com')
    (validate-email 'test.user@domain.co.uk')
    !(validate-email 'invalid')
    !(validate-email '@example.com')
    !(validate-email 'user@')
  )
```

**Test Pattern: Table-Driven**

```hoon
::  Test multiple cases from table
++  test-calculate-discount
  ^-  ?
  =/  test-cases
    :~  [age=25 member=%.n purchases=5 expected=5]
        [age=25 member=%.y purchases=5 expected=15]
        [age=70 member=%.n purchases=5 expected=10]
        [age=70 member=%.y purchases=15 expected=20]
    ==
  %+  levy  test-cases
  |=  [age=@ud member=? purchases=@ud expected=@ud]
  .=  expected  (calculate-discount age member purchases)
```

**Testing Pure Functions**:

```hoon
::  lib/math-utils.hoon
|%
++  factorial
  |=  n=@ud
  ^-  @ud
  ?:  =(n 0)  1
  (mul n $(n (dec n)))
--

::  gen/test-math-utils.hoon
/+  math-utils
::
++  test-factorial
  ^-  ?
  &(
    .=(1 (factorial:math-utils 0))
    .=(1 (factorial:math-utils 1))
    .=(2 (factorial:math-utils 2))
    .=(6 (factorial:math-utils 3))
    .=(120 (factorial:math-utils 5))
  )
```

**Testing Data Transformations**:

```hoon
::  lib/data-transform.hoon
|%
++  normalize-user
  |=  raw=[name=@t age=@t email=@t]
  ^-  (unit [name=@t age=@ud email=@t])
  =/  age-parsed  (rush age.raw dem)
  ?~  age-parsed  ~
  `[name.raw u.age-parsed email.raw]
--

::  gen/test-data-transform.hoon
/+  data-transform
::
++  test-normalize-user
  ^-  ?
  &(
    ::  Valid input
    .=  `['Alice' 30 'a@ex.com']
        (normalize-user:data-transform ['Alice' '30' 'a@ex.com'])
    ::  Invalid age
    .=  ~
        (normalize-user:data-transform ['Bob' 'abc' 'b@ex.com'])
  )
```

---

### Phase 3: Integration Testing

**Objective**: Test Gall agents and multi-component interactions.

**Agent Test Pattern**:

```hoon
::  gen/test-my-agent.hoon
::
::  Integration tests for my-agent
::
/-  my-app
::
:-  %say
|=  [[now=@da eny=@uvJ bec=beak] ~ ~]
:-  %noun
::
::  Simulate agent lifecycle
::
=/  test-bowl
  :*  [~zod ~zod %my-app]
      [~ ~]
      [now eny]
      [0 0]
  ==
::
::  Test 1: on-init
~&  >  'Test: on-init creates empty state'
=/  agent  *agent:gall
=/  [cards-init this-init]  on-init:agent
=/  state-init  state:this-init
=/  test-1  =(state-init *app-state)
~&  ?:(test-1 > '✓ on-init' >>> '✗ on-init')
::
::  Test 2: on-poke creates item
~&  >  'Test: on-poke %create adds item'
=/  action  [%create name='test']
=/  [cards-poke this-poke]  (on-poke:this-init %my-action !>(action))
=/  state-poke  state:this-poke
=/  test-2  .=  1  (lent items.state-poke)
~&  ?:(test-2 > '✓ on-poke create' >>> '✗ on-poke create')
::
::  Test 3: on-save/on-load roundtrip
~&  >  'Test: on-save/on-load preserves state'
=/  saved  (on-save:this-poke)
=/  [cards-load this-load]  (on-load:agent saved)
=/  state-load  state:this-load
=/  test-3  .=  state-poke  state-load
~&  ?:(test-3 > '✓ save/load roundtrip' >>> '✗ save/load roundtrip')
::
::  Return summary
:~  test-1
    test-2
    test-3
==
```

**State Transition Testing**:

```hoon
::  Test state changes
++  test-state-transitions
  ^-  ?
  ::  Initial state
  =/  state-0  *app-state
  ::  Transition 1: Create
  =/  state-1  (handle-create state-0 'item-1')
  =/  check-1  .=(1 (lent items.state-1))
  ::  Transition 2: Update
  =/  state-2  (handle-update state-1 0 'updated')
  =/  check-2  .=('updated' name:(snag 0 items.state-2))
  ::  Transition 3: Delete
  =/  state-3  (handle-delete state-2 0)
  =/  check-3  .=(0 (lent items.state-3))
  ::  All checks pass
  &(check-1 check-2 check-3)
```

**Subscription Testing**:

```hoon
::  Test subscription flow
++  test-subscriptions
  ^-  ?
  ::  Setup
  =/  agent  *agent:gall
  =/  path  /updates
  ::  Subscribe
  =/  [cards-watch this-watch]  (on-watch:agent path)
  =/  check-1  .=(1 (lent cards-watch))  ::  Initial fact sent
  ::  Update
  =/  [cards-poke this-poke]  (on-poke:this-watch %action !>([%create 'test']))
  ::  Check update card generated
  =/  check-2
    %+  lien  cards-poke
    |=  c=card
    ?=([%give %fact * *] c)
  ::  Leave
  =/  [cards-leave this-leave]  (on-leave:this-poke ~zod)
  &(check-1 check-2)
```

---

### Phase 4: Property-Based Testing

**Objective**: Verify properties hold across many random inputs.

**Property Test Pattern**:

```hoon
::  Test property with random generation
++  test-property-roundtrip
  |=  [iterations=@ud eny=@uvJ]
  ^-  ?
  =/  rng  ~(. og eny)
  =/  passed  0
  |-  ^-  ?
  ?:  =(iterations 0)
    ::  All iterations passed
    =(passed iterations)
  ::  Generate random value
  =^  val  rng  (rads:rng 1.000.000)
  ::  Test property: serialize → deserialize = identity
  =/  serialized  (to-json val)
  =/  deserialized  (from-json serialized)
  ?:  .=(val deserialized)
    $(iterations (dec iterations), passed +(passed))
  ::  Property failed
  ~&  >>>  "Property failed for value: {<val>}"
  %.n
```

**Invariant Testing**:

```hoon
::  Test invariants always hold
++  test-invariants
  |=  state=app-state
  ^-  ?
  ::  Invariant 1: IDs are unique
  =/  ids  (turn items.state |=(i=item id.i))
  =/  unique-ids  ~(wyt in (~(gas in *(set @ud)) ids))
  =/  check-1  .=(unique-ids (lent ids))
  ::  Invariant 2: Count matches length
  =/  check-2  .=(count.state (lent items.state))
  ::  Invariant 3: All items valid
  =/  check-3  (levy items.state is-valid-item)
  &(check-1 check-2 check-3)
```

**Fuzzing Test Pattern**:

```hoon
::  Generate random inputs to find crashes
++  fuzz-parser
  |=  [iterations=@ud eny=@uvJ]
  ^-  ?
  =/  rng  ~(. og eny)
  |-  ^-  ?
  ?:  =(iterations 0)  %.y
  ::  Generate random text
  =^  len  rng  (rads:rng 100)
  =/  text
    =/  chars  *(list @t)
    =/  i  0
    |-
    ?:  =(i len)  (crip chars)
    =^  char  rng  (rads:rng 256)
    $(i +(i), chars [`@t`char chars])
  ::  Try to parse (should not crash)
  =/  result
    %-  mule  |.
    (parse-input text)
  ?-  -.result
    %&  $(iterations (dec iterations))
    %|
      ~&  >>>  "Parser crashed on: {<text>}"
      %.n
  ==
```

---

### Phase 5: Test-Driven Development (TDD)

**Objective**: Write tests before implementation (Red-Green-Refactor).

**TDD Workflow**:

#### 1. Red - Write Failing Test

```hoon
::  gen/test-features.hoon
::
::  Test for feature not yet implemented
::
++  test-calculate-score
  ^-  ?
  ::  Expected: Calculate score from user data
  =/  user  [posts=10 likes=50 followers=100]
  =/  expected-score  160  ::  10 + 50 + 100
  =/  actual-score  (calculate-score user)
  .=  expected-score  actual-score

::  Run: +test-features
::  Result: Compilation error - calculate-score doesn't exist
```

#### 2. Green - Minimal Implementation

```hoon
::  lib/scoring.hoon
|%
++  calculate-score
  |=  user=[posts=@ud likes=@ud followers=@ud]
  ^-  @ud
  ::  Minimal implementation to pass test
  (add (add posts.user likes.user) followers.user)
--

::  Run: +test-features
::  Result: Test passes ✓
```

#### 3. Refactor - Improve Code

```hoon
::  lib/scoring.hoon
|%
++  calculate-score
  |=  user=[posts=@ud likes=@ud followers=@ud]
  ^-  @ud
  ::  Refactored: Use roll for clarity
  %+  roll  ~[posts.user likes.user followers.user]
  add

::  Run: +test-features
::  Result: Test still passes ✓
--
```

**TDD Example: Validation Function**

```hoon
::  Step 1: Write test (RED)
++  test-validate-username
  ^-  ?
  &(
    (validate-username 'alice')
    (validate-username 'bob123')
    !(validate-username 'ab')  ::  Too short
    !(validate-username 'alice@')  ::  Invalid char
    !(validate-username '')  ::  Empty
  )

::  Step 2: Implement (GREEN)
++  validate-username
  |=  name=@t
  ^-  ?
  =/  len  (lent (trip name))
  ?.  &((gte len 3) (lte len 20))  %.n
  %+  levy  (trip name)
  |=  c=@t
  ?|  &((gte c 'a') (lte c 'z'))
      &((gte c 'A') (lte c 'Z'))
      &((gte c '0') (lte c '9'))
  ==

::  Step 3: Refactor (REFACTOR)
++  is-alphanumeric
  |=  c=@t
  ^-  ?
  ?|  &((gte c 'a') (lte c 'z'))
      &((gte c 'A') (lte c 'Z'))
      &((gte c '0') (lte c '9'))
  ==

++  validate-username
  |=  name=@t
  ^-  ?
  =/  len  (lent (trip name))
  &(
    (gte len 3)
    (lte len 20)
    (levy (trip name) is-alphanumeric)
  )
```

---

## Test Organization

### File Structure

```
desk/
├── gen/
│   ├── test-all.hoon          # Run all tests
│   ├── test-utils.hoon        # Test utility functions
│   ├── test-parser.hoon       # Test parser
│   ├── test-agent.hoon        # Test agent integration
│   └── test-properties.hoon   # Property tests
├── lib/
│   ├── test-helpers.hoon      # Shared test utilities
│   └── test-data.hoon         # Test fixtures
```

### Test Suite Runner

```hoon
::  gen/test-all.hoon
::
::  Run all test suites
::
/+  test-utils, test-parser, test-agent
::
:-  %say
|=  *
:-  %noun
::
=/  suites
  :~  ['utils' test-all:test-utils]
      ['parser' test-all:test-parser]
      ['agent' test-all:test-agent]
  ==
::
=/  results
  %+  turn  suites
  |=  [name=@t tests=$-(* (list ?))]
  =/  test-results  (tests)
  =/  passed  (lent (skim test-results |=(r=? r)))
  =/  total  (lent test-results)
  ~&  >  "{<name>}: {<passed>}/{<total>} passed"
  [name passed total]
::
results
```

---

## Testing Checklist

### Test Design
- [ ] Happy path covered
- [ ] Edge cases identified
- [ ] Error cases tested
- [ ] Special values included
- [ ] Invariants checked

### Test Quality
- [ ] Tests are independent
- [ ] Clear test names
- [ ] Minimal test code
- [ ] Fast execution
- [ ] Deterministic results

### Coverage
- [ ] All public functions tested
- [ ] All branches covered
- [ ] All state transitions tested
- [ ] Integration points tested
- [ ] Regression tests for bugs

---

## Integration with Skills

This command references:
- **hoon-fundamentals** - Testing basics
- **functional-programming-patterns** - Pure functions
- **gall-agents** - Agent testing
- **generators** - Test generators
- **data-structures** - Test data setup

---

## Common Testing Mistakes

1. **Testing implementation details** - Test behavior, not internals
2. **Dependent tests** - Each test should be independent
3. **Slow tests** - Keep tests fast for frequent running
4. **Unclear failures** - Make failures easy to diagnose
5. **No edge case testing** - Test boundaries and special values

---

## Success Metrics

- **High coverage** - >80% of code paths tested
- **Fast feedback** - Tests run in <10 seconds
- **Clear failures** - Easy to identify failing test
- **No flaky tests** - Deterministic results
- **Maintained tests** - Updated with code changes
