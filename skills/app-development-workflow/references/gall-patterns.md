# Real-World Gall Agent Patterns

Annotated patterns drawn from the Obelisk RDBMS agent (`desk/app/obelisk.hoon`), an advanced single-agent Gall app. Use these as production-grade reference implementations for the workflow in `SKILL.md`.

---

## 1. Versioned state + crash-safe migration

Each state version carries its **own version tag** as its head; the union is over the full state molds (not over a shared head).

```hoon
+$  versioned-state
  $%  state-0
      state-1
  ==
+$  state-0  $:(%0 server=server:server-state-0)
+$  state-1  $:(%1 =server)
```

Bind the current state at the top of the agent so arms see `state` (and its fields) directly:

```hoon
%-  agent:dbug
=|  state-1            :: bunt current state
=*  state  -           :: alias `state` to the subject head
^-  agent:gall
|_  =bowl:gall
+*  this     .
    default  ~(. (default-agent this %n) bowl)
```

`on-save` exports the live state vase; `on-load` migrates **inside `mule`** so a failed migration cannot brick the agent — on failure it logs and bunts a fresh state instead of crashing the load:

```hoon
++  on-save  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  =/  r=(each state-1 tang)
    %-  mule  |.
    =/  old  !<(versioned-state old-state)
    ?-  -.old
      %0  [%1 (migrate-server-0-to-1 server.old)]
      %1  old
    ==
  ?:  ?=(%.y -.r)  `this(state p.r)
  %-  (slog 'old state corrupt, unable to migrate data' ~)
  `this(state *state-1)
```

Notes:
- The migration logic itself lives in a `lib/migration.hoon` library that imports both the old (`/sur/server-state-0`) and new (`/-  server-state-1`) structures. Keep migration code out of the agent file.
- `mule` returns `(each result tang)`: `%.y` = success (`p` is the value), `%.n` = crash (`p` is the stack trace `tang`).

See also the `hoon-migrate-workflow` skill for the full migration discipline.

---

## 2. Mark-gated `on-poke`

Reject any mark you don't own *first* with an assertion, then extract the typed action and dispatch on its tag. This is stricter and clearer than a `?+ mark` fallthrough when the agent has exactly one input mark.

```hoon
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  ?=(%obelisk-action mark)     :: only accept %obelisk-action
  =/  act  !<(action vase)         :: typed from /-  *obelisk
  ?-  -.act
    %tape        ...
    %tape-print  ...
    %commands    ...
    %parse       ...
    %test        ...
  ==
```

The action is a tagged union defined in `sur/` and reflected by a mark file:

```hoon
+$  action
  $%  [%tape default-database=@tas urql=tape]
      [%tape-print default-database=@tas urql=tape]
      [%commands cmds=(list command)]
      [%parse default-database=@tas urql=tape]
      [%test default-database=@tas urql=tape]
  ==
```

`mar/obelisk/action.hoon` is a thin noun mark — `grow`/`grab`/`grad` over `action`:

```hoon
/-  *obelisk
|_  act=action
++  grow  |%  ++  noun  act  --
++  grab  |%  ++  noun  action  --
++  grad  %noun
--
```

---

## 3. Crash containment with `mule` in `on-poke`

Each handler runs untrusted work (parse + execute urQL) inside `mule`, so a malformed query returns an error fact instead of crashing the agent. Success commits the new state; failure leaves state untouched.

```hoon
%tape-print
  =/  virtualized
    ^-  (each (pair (list cmd-result) server:server-state-1) tang)
    %-  mule  |.
    %:  process-cmds(state server, bowl bowl)
      (parse-urql +<.act +>.act)
    ==
  ?-  -.virtualized
    %.n                                   :: crashed — report, keep state
      :_  this
      :~  [%give %fact ~[/server] %noun !>([| p.virtualized])]
          [%give %kick ~[/server] ~]
      ==
    %.y                                   :: ok — commit new server state
      =/  res  p.virtualized
      :_  this(server +.res)
      :~  [%give %fact ~[/server] %noun !>([& -.res])]
          [%give %kick ~[/server] ~]
      ==
  ==
```

Pattern: virtualize side-effecting work, branch on `%.y`/`%.n`, and only thread the new state in the success arm.

---

## 4. Request/response over a subscription (fact + immediate kick)

Obelisk does not hold long-lived subscriptions. It answers a poke by giving a single `%fact` on `/server` then immediately `%kick`ing the subscriber — a one-shot reply channel. The fact payload is a `[success=? result]` flag-tagged noun so clients can distinguish ok from error.

```hoon
:~  [%give %fact ~[/server] %noun !>([& -.res])]   :: result
    [%give %kick ~[/server] ~]                      :: close the channel
==
```

`on-watch` accepts any path without producing initial state (the data arrives via the poke-driven fact):

```hoon
++  on-watch  |=(=path `this)
```

Contrast with a streaming agent, which keeps subscribers and gives facts on later state changes (see the generic subscription pattern in `SKILL.md`).

---

## 5. Scry via `on-peek`

Expose read-only state on a `%x` (Clay-style) path. Return `[~ ~]` for unknown paths, `` ``mark+!>(value) `` for hits.

```hoon
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  [~ ~]
    [%x %server ~]  ``noun+!>(server.state)
  ==
```

Read it with `.^(* %gx /=obelisk=/server/noun)` from dojo or another agent.

---

## 6. Clay warp in `on-init`, handled in `on-arvo`

To seed state from a file in its own desk, the agent passes a Clay `%warp` (`%sing %x`) read request at boot, then handles the returned `riot:clay` in `on-arvo`, validating the cage mark before use.

`on-init` (read a generator's text output at the current revision):

```hoon
:*  %pass  /init/animal-shelter  %arvo  %c  %warp
    our.bowl  q.byk.bowl  ~
    %sing  %x  da+now.bowl  /gen/animal-shelter/all-animal-shelter/txt
==
```

`on-arvo` (validate and act — here it pokes itself with the loaded data):

```hoon
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:default wire sign-arvo)
      [%init %animal-shelter ~]
    ?+    -.sign-arvo  (on-arvo:default wire sign-arvo)
        %clay
      ?+  -.+.sign-arvo  (on-arvo:default wire sign-arvo)
          %writ
        =/  riot=riot:clay  +.+.sign-arvo
        ?~  riot
          %-  (slog 'init import file not found' ~)
          `this
        =/  cage  r.u.riot
        ?.  ?=(%txt p.cage)
          %-  (slog 'init import expected %txt cage' ~)
          `this
        =/  txt  !<(wain q.cage)
        :_  this
        :~  :*  %pass  /init/animal-shelter/poke  %agent
                [our.bowl dap.bowl]  %poke  %obelisk-action
                !>([%tape %animal-shelter (reel txt ...)])
        ==  ==
      ==
    ==
  ==
```

Pattern: tag the `wire` (`/init/...`) so the `on-arvo` dispatch matches your own request; descend `sign-arvo` (`%clay` → `%writ` → `riot`); guard `?~ riot` and the cage mark before `!<`.

---

## 7. Installing an external app via `%hawk`

On first boot, scry installed desks and conditionally drive Kiln to install a dependency app from a publisher ship — idempotent (skips if already present).

```hoon
++  on-init
  ^-  (quip card _this)
  =+  .^(desks=(set desk) %cd /=//=)        :: scry installed desks
  =/  install-hawk=card
    :*  %pass  /init/hawk/install  %agent
        [our.bowl %hood]  %poke  %kiln-install
        !>([%hawk ~dister-migrev-dolseg %hawk])
    ==
  =/  hawk-cards=(list card)
    ?:  (~(has in desks) %hawk)  ~          :: already installed → no-op
    [install-hawk ~]
  :_  this(state *state-1)
  (weld hawk-cards animal-cards)
```

Ack the Kiln response in `on-agent` so it isn't treated as an error:

```hoon
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:default wire sign)
      [%init %hawk %install ~]    `this
      [%init %animal-shelter %poke ~]  `this
  ==
```

---

## Checklist for an agent like this

- [ ] Version tag is the head of each state mold; `versioned-state` unions the molds.
- [ ] `on-load` migration wrapped in `mule`, with a bunt fallback.
- [ ] One input mark, asserted with `?>  ?=(%... mark)`.
- [ ] Side-effecting work virtualized in `mule`; state threaded only on `%.y`.
- [ ] Reply facts carry a `[ok=? payload]` flag.
- [ ] `on-peek` returns `[~ ~]` for misses.
- [ ] Every self-issued `%pass` wire is tagged and matched in `on-arvo`/`on-agent`.
- [ ] External installs are idempotent (scry `%cd` before poking Kiln).
