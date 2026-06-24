---
name: app-development-workflow
description: Complete workflow for developing, testing, and distributing Urbit applications including Gall agent development, React front-ends, desk packaging, local development with fake ships, testing, and peer-to-peer distribution. Use when developing Urbit apps, setting up development environments, testing agents, or publishing desks.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# App Development Workflow Skill

Complete workflow for developing, testing, and distributing Urbit applications including Gall agent development, desk publishing, and peer-to-peer distribution (2026).

## Overview

Urbit app development involves creating Gall agents (backend), React front-ends, packaging into desks, and distributing via peer-to-peer network. This skill covers the complete development lifecycle.

## Urbit Development Environment

### Prerequisites

1. **Fake ship** for development (never develop on live planet!)
2. **Development tools**: Hoon, Node.js, npm/yarn
3. **Code editor**: VS Code with Hoon syntax highlighting

### Setup Development Ship

```bash
# Create fake ship (any identity, offline)
urbit -F zod  # Or any ship name

# Important: -F flag = fake ship (no network, disposable)
```

**Why fake ships?**
- No network connectivity (fast, isolated)
- Disposable (can delete and recreate)
- Any identity (can test with ~zod, ~nec, etc.)
- Safe for experimentation

---

## Gall Agent Architecture

### What is a Gall Agent?

**Gall** = Arvo kernel module for userspace applications

**Agent** = State machine with event handlers:
```
(events, old-state) => (effects, new-state)
```

### Agent Arms (Event Handlers)

```hoon
|_  bowl:gall
++  on-init     :: Initialize agent (first boot)
++  on-save     :: Export state (for upgrades)
++  on-load     :: Import state (from upgrades)
++  on-poke     :: Handle poke (command/transaction)
++  on-watch    :: Handle subscription request
++  on-leave    :: Handle unsubscription
++  on-peek     :: Handle scry (read-only query)
++  on-agent    :: Handle updates from other agents
++  on-arvo     :: Handle kernel responses (Behn, Clay, Eyre, Iris)
++  on-fail     :: Handle crashes
--
```

### Minimal Gall Agent Example

Bind the current state with `=|`/`=*` so arms can read `state` and its fields directly. Give each state version a head tag (`%0`) so `on-load` can branch across versions.

```hoon
/+  default-agent, dbug
|%
+$  versioned-state  $%(state-0)
+$  state-0  [%0 counter=@ud]
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this      .
    default   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  `this(state [%0 counter=0])
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  =(src.bowl our.bowl)  :: Auth: only ship owner
  ?+    mark  (on-poke:default mark vase)
      %noun
    =/  =action  !<(?(%increment %decrement) vase)
    ?-  action
      %increment  `this(counter.state +(counter.state))
      %decrement  `this(counter.state (dec counter.state))
    ==
  ==
::
++  on-save  !>(state)
++  on-load
  |=  old=vase
  `this(state !<(versioned-state old))
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent  on-agent:default
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
--
```

> For production-grade versions of every arm — crash-safe migration, mark-gated pokes, fact+kick replies, scry, Clay warps, and external installs — see [references/gall-patterns.md](references/gall-patterns.md), drawn from the Obelisk RDBMS agent.

**Test in dojo**:
```
|start %counter
:counter &noun %increment
:counter &noun %increment
:counter &noun %decrement
```

---

## Desk Structure

### Required Files

```
myapp/
├── desk.bill          # Apps to start on installation
├── desk.docket-0      # App metadata, tile config
├── sys.kelvin         # Kernel version compatibility
├── app/
│   └── myapp.hoon     # Gall agent
├── sur/
│   └── myapp.hoon     # Shared structures
├── lib/
│   └── myapp.hoon     # Shared libraries
├── mar/
│   └── myapp/
│       └── action.hoon  # Mark files (data validators)
└── gen/
    └── myapp/
        └── command.hoon # Generators (CLI tools)
```

### desk.bill

Lists Gall agents to start on desk installation.

```hoon
:~  %myapp
==
```

### desk.docket-0

Metadata for app display in Grid (home screen).

```hoon
:~
  title+'My Urbit App'
  info+'A description of my app'
  color+0x4b.c934
  version+[0 1 0]
  website+'https://myapp.example'
  license+'MIT'
  base+'myapp'
  glob-ames+[~zod 0v0]
  image+'https://example.com/icon.svg'
==
```

### sys.kelvin

Specifies kernel version compatibility. A desk may list **multiple** kelvins to
support a range of runtimes (Obelisk's `sys.kelvin`):

```hoon
[%zuse 411]
[%zuse 410]
[%zuse 409]
[%zuse 408]
```

Check the ship's current kelvin with `.^(@ud %cz %$)` and ensure it appears in
the list.

---

## Development Workflow

### Phase 1: Local Development

**On fake ship**:
```bash
# 1. Start fake ship
urbit -F zod

# 2. Create desk
|merge %myapp our %base

# 3. Mount desk to Unix filesystem
|mount %myapp

# 4. Exit ship (Ctrl+D), edit files in zod/myapp/
# Copy your app files to zod/myapp/

# 5. Restart ship, commit changes
|commit %myapp

# 6. Install app
|install our %myapp
```

### Phase 2: Iterative Development

**File change workflow**:
```bash
# 1. Edit Hoon files in zod/myapp/
# 2. In dojo:
|commit %myapp    # Commit changes to Clay
|bump %myapp      # Restart apps in desk
```

**Test changes immediately** - no rebuild required!

### Phase 3: Testing

**Unit Tests** (tests/app/myapp.hoon):
```hoon
/+  *test, *myapp
|%
++  test-increment
  =/  initial  [%0 counter=0]
  =/  expected  [%0 counter=1]
  ;:  weld
    %+  expect-eq
      !>  expected
      !>  (increment initial)
  ==
--
```

**Run tests**:
```
-test %/tests ~
```

---

## Front-End Development (React)

### Setup React App

```bash
# Create React app
npx create-react-app myapp-ui

# Install Urbit HTTP API
cd myapp-ui
npm install @urbit/http-api
```

### Urbit API Integration

```javascript
// src/api.js
import Urbit from '@urbit/http-api';

const api = new Urbit('', '', 'myapp');
api.ship = window.ship;  // Set from index.html

// Subscribe to updates
api.subscribe({
  app: 'myapp',
  path: '/updates',
  event: (data) => console.log('Update:', data),
  err: () => console.log('Subscription error'),
  quit: () => console.log('Kicked from subscription')
});

// Poke (send command)
api.poke({
  app: 'myapp',
  mark: 'myapp-action',
  json: { increment: null }
});

// Scry (read-only query)
api.scry({
  app: 'myapp',
  path: '/counter'
}).then(data => console.log(data));

export default api;
```

### Build Glob (Front-End Bundle)

```bash
# Build production bundle
npm run build

# Upload glob to ship
cd build
ls | xargs -I {} curl -X POST -F "file=@{}" http://localhost:8080/~/my app/upload

# In dojo, get glob hash
.^(* %cx /=myapp=/desk/docket-0)
```

**Update desk.docket-0**:
```hoon
glob-ames+[~zod 0v5.abc.def.ghi]  # Use glob hash from above
```

---

## Publishing and Distribution

### Prepare for Publishing

**Checklist**:
- [ ] desk.bill lists all agents
- [ ] desk.docket-0 metadata complete
- [ ] sys.kelvin matches ship kelvin
- [ ] All mark files included
- [ ] All dependencies in desk (libraries, structures)
- [ ] Glob uploaded (if front-end exists)
- [ ] Tested on fake ship

### Publish with %treaty

```bash
# 1. Start publishing on live ship
:treaty|publish %myapp

# 2. Set treaty metadata (in dojo)
:treaty|add %myapp
```

### Distribution URL

**Share with users**:
```
web+urbitgraph://~sampel-palnet/myapp
```

**Or direct link**:
```
https://sampel-palnet.arvo.network/apps/grid/perma?patp=~sampel-palnet&desk=myapp
```

### User Installation

**Users install via**:
1. Grid → Get Apps → Search for publisher ship
2. Or paste installation link
3. Or via dojo: `|install ~sampel-palnet %myapp`

---

## Peer-to-Peer Updates

### Publishing Updates

```bash
# 1. Increment version in desk.docket-0
version+[0 2 0]  # 0.1.0 → 0.2.0

# 2. Commit changes
|commit %myapp

# 3. Publish update
:treaty|publish %myapp
```

**Users automatically receive update** via Kiln (package manager).

---

## CI/CD Integration

### Automated Testing (GitHub Actions)

See `/setup-cicd-pipeline` command for complete GitLab CI/CD configuration including:
- Validation on fake ship
- Automated test execution
- Desk tarball creation
- Deployment to production ship

---

## Development Tools (2025)

### Hoon Language Server

```bash
# Install via npm
npm install -g @urbit/hoon-language-server

# VS Code extension
code --install-extension urbit-pilled.hoon-language-server
```

### Debugging with +dbug

```hoon
/+  default-agent, dbug  # Import dbug

%-  agent:dbug  # Wrap agent
^-  agent:gall
|_  =bowl:gall
  # ... agent code ...
--
```

**Debug commands**:
```
:myapp +dbug [%state]      # View current state
:myapp +dbug [%bowl]       # View bowl
:myapp +dbug [%subscriptions]  # View subscriptions
```

---

## Best Practices

1. **Always develop on fake ships** (never on live planet)
2. **Commit frequently** (Clay version control)
3. **Test thoroughly** (unit tests, integration tests)
4. **Desk self-containment**: Include ALL dependencies (marks, libs, structures)
5. **Version semantically**: Follow semver (major.minor.patch)
6. **Document APIs**: Write clear sur/ structure definitions
7. **Security**: Validate poke sources (`?>  =(src.bowl our.bowl)`)
8. **Graceful upgrades**: Version-tag state; wrap `on-load` migration in `mule` with a bunt fallback so a bad migration cannot brick the agent (see [references/gall-patterns.md](references/gall-patterns.md)).
9. **Crash containment**: Virtualize untrusted/side-effecting work with `mule` and branch on `(each result tang)`; thread new state only on `%.y`. `on-fail` runs AFTER a crash for recovery/logging — use `?>` guards, `?~` null checks, and `mule` to PREVENT crashes in the first place.
10. **Performance**: Minimize state size, use caching

---

## Common Patterns

> The patterns below are the generic forms. For annotated, production-grade
> versions extracted from the Obelisk RDBMS agent, see
> [references/gall-patterns.md](references/gall-patterns.md).

### Versioned state + crash-safe migration

Tag each state version at its head; union the molds in `versioned-state`.
Wrap migration in `mule` so a bad migration logs and bunts instead of bricking
`on-load`:

```hoon
+$  versioned-state  $%(state-0 state-1)
+$  state-0  [%0 =counter =users]
+$  state-1  [%1 =counter =users =settings]

++  on-save  !>(state)
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
  =/  r=(each state-1 tang)
    %-  mule  |.
    =/  old  !<(versioned-state old-vase)
    ?-  -.old
      %0  [%1 counter.old users.old settings=~]   :: migrate
      %1  old
    ==
  ?:  ?=(%.y -.r)  `this(state p.r)
  %-  (slog 'state corrupt, unable to migrate' ~)
  `this(state *state-1)
```

### Mark-gated `on-poke`

When an agent has one input mark, assert it up front, then dispatch on the
typed action tag (clearer than a `?+ mark` fallthrough):

```hoon
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  ?=(%myapp-action mark)
  =/  act  !<(action vase)
  ?-  -.act
    %do-thing  ...
  ==
```

### Crash containment with `mule`

Virtualize untrusted/side-effecting work so a malformed input returns an error
fact instead of crashing the agent. Thread the new state only on success:

```hoon
=/  res=(each new-state tang)  (mule |.(run-work))
?-  -.res
  %.n  :_  this  [%give %fact ~[/path] %noun !>([| p.res])]~   :: keep state
  %.y  :_  this(state p.res)  [%give %fact ~[/path] %noun !>([& p.res])]~
==
```

### Subscription (streaming server)

```hoon
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:default path)
      [%updates ~]
    :_  this
    [%give %fact ~ %json !>((updates-to-json state))]~
  ==
```

### Request/response over a subscription (fact + kick)

For one-shot replies (no persistent subscription), give a single fact then
immediately kick the subscriber. Tag the payload with a success flag:

```hoon
++  on-watch  |=(=path `this)   :: accept, no initial state
::  ...in on-poke, after producing `res`:
:~  [%give %fact ~[/server] %noun !>([& res])]
    [%give %kick ~[/server] ~]
==
```

### Scry via `on-peek`

Expose read-only state on a `%x` path; `[~ ~]` for misses:

```hoon
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  [~ ~]
    [%x %state ~]  ``noun+!>(state)
  ==
```

### Clay warp at boot, handled in `on-arvo`

Seed state from a file in the agent's own desk. Tag the wire so `on-arvo`
matches it, and guard `?~ riot` / the cage mark before `!<`:

```hoon
::  on-init card:
:*  %pass  /init/seed  %arvo  %c  %warp  our.bowl  q.byk.bowl  ~
    %sing  %x  da+now.bowl  /path/to/file/txt
==
```

### Installing a dependency app via Kiln

Idempotent external install: scry installed desks first, poke `%hood` with
`%kiln-install` only if absent. (Obelisk uses this to install `%hawk`.)

```hoon
=+  .^(desks=(set desk) %cd /=//=)
?:  (~(has in desks) %hawk)  ~
:_  ~  :*  %pass  /init/hawk/install  %agent  [our.bowl %hood]
           %poke  %kiln-install  !>([%hawk ~publisher %hawk])
       ==
```

### HTTP API Endpoint

> **Note**: HTTP responses should use `give-simple-payload:app:server` from the `server` library, not raw `%give %fact` cards. The server library handles the correct multi-card response protocol (header + body + complete) that Eyre expects.

```hoon
/+  server
::
++  on-poke
  |=  [=mark =vase]
  ?+  mark  (on-poke:default mark vase)
      %handle-http-request
    =/  req  !<([@ta inbound-request:eyre] vase)
    :_  this
    %+  give-simple-payload:app:server  -.req
    [[200 ~[['Content-Type' 'application/json']]] `(as-octs:mimes:html '{"status":"ok"}')]
  ==
```

---

## Troubleshooting

**Agent won't start**:
- Check syntax: `:myapp +dbug %state`
- Read source file (not logs): `.^(wain %cx /=myapp=/app/myapp/hoon)` -- note this reads the Hoon source code, not runtime logs. For runtime errors, check the dojo output directly.

**Subscription not working**:
- Verify path in on-watch
- Check permissions (source ship allowed?)

**Glob not loading**:
- Verify glob hash in desk.docket-0
- Check Eyre serving: `http://localhost:8080/apps/myapp/`

**Desk won't install**:
- Verify sys.kelvin matches ship kelvin: `.^(@ud %cz %$)`
- Check all marks exist in desk
- Ensure desk.bill lists all agents

---

## Reference

- [references/gall-patterns.md](references/gall-patterns.md) — production Gall patterns (versioned state, `mule` migration, mark-gated pokes, fact+kick, scry, Clay warps, Kiln installs) from the Obelisk agent
- App School (full course): https://docs.urbit.org/build-on-urbit/app-school
- Software Distribution: https://docs.urbit.org/build-on-urbit/userspace/dist/software-distribution
- Gall Reference: https://docs.urbit.org/urbit-os/kernel/gall/gall-api
- HTTP API: https://github.com/urbit/js-http-api
- Hoon School: https://docs.urbit.org/build-on-urbit/hoon-school

---

## Summary

Urbit app development uses Gall agents (backend state machines with event handlers), React front-ends (via @urbit/http-api), and desks for distribution. Development workflow: create fake ship (-F flag), mount desk to filesystem (|mount), edit files, commit changes (|commit), and test iteratively. Distribution via %treaty agent enables peer-to-peer installation with automatic updates through Kiln. Desk structure requires desk.bill (agent list), desk.docket-0 (metadata), sys.kelvin (kernel compatibility), and self-contained dependencies (marks, libs, structures). Best practices: always use fake ships for development, commit frequently, test thoroughly, and implement proper state migration for upgrades.
