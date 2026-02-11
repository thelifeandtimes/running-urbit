---
name: urbit-conn
description: Interact with a running Urbit ship programmatically via the conn.c Unix domain socket. Use when the user wants to send commands to a ship, run Hoon code, scry ship state, manage OTAs, install desks, run threads, or perform maintenance operations (pack, meld) on a running Urbit ship without using the interactive dojo. Triggers include "send command to ship", "scry", "run thread", "pack ship", "meld", "eval hoon", "ship maintenance", "conn.c", "click".
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
argument-hint: <command> [pier-path]
---

# Urbit conn.c Socket Interaction

Programmatic interface to a running Urbit ship via the `.urb/conn.sock` Unix domain socket.

## Critical: Prefer File-Based Threads Over Inline

**The `-kp` inline mode is unreliable.** Backticks, `!>`, and special characters get mangled by shell quoting layers. Inline strings work for trivial expressions but break on real Hoon.

**Always prefer `-k -i file.hoon` (file-based threads) for anything non-trivial:**

```bash
# RECOMMENDED: Write thread to a file, then execute
cat > /tmp/my-thread.hoon << 'HOON'
=/  m  (strand ,vase)
;<  our=@p  bind:m  get-our
(pure:m !>(our))
HOON
click -k -i /tmp/my-thread.hoon /path/to/pier
```

```bash
# UNRELIABLE: Inline mode — backticks and !> get mangled by shell
# This looks like it should work but produces conn: moor bail -1 newt-decode:
click -kp /path/to/pier '=/  m  (strand ,vase)  (pure:m !>(42))'
# Even simple cases break once you need backticks, !>, or nested quotes.
# There is no reliable way to shell-escape complex Hoon inline.
```

Reserve `-kp` inline only for the simplest expressions (no backticks, no `!>`). For everything else, write to a temp file and use `-k -i`.

## Known Error: `conn: moor bail -1 newt-decode`

This error means the command sent to conn.sock was malformed — usually due to shell escaping issues with inline click commands. It is **not** a ship problem.

**Fix**: Switch to file-based threads (`-k -i file.hoon`) instead of inline strings.

## Stale conn.sock After Shutdown

After an ungraceful shutdown (kill -9, OOM kill, power loss), `conn.sock` persists as a stale file because the cleanup in `_conn_io_exit()` never runs. If you find a `conn.sock` but get "Connection refused", the ship is down and the socket is stale.

```bash
# Check if ship process is actually running
pgrep -a urbit | grep pier-name
```

**You do NOT need to manually remove the stale socket.** Vere's `_conn_init_sock()` automatically unlinks any existing socket on startup before creating a new one. Just restart the ship:

```bash
urbit /path/to/pier
```

The stale socket is only a diagnostic concern: its presence does NOT mean the ship is running. **Always check for a running process before trusting that conn.sock means the ship is alive.**

## Step 1: Discover Running Ships

Before sending any commands, locate the target ship's pier and verify it is running.

### Auto-Discovery

Search for active `conn.sock` files:

```bash
# Common pier locations
find ~/zod ~/bus ~/piers ~/urbit ~/.urbit /home/*/piers -name "conn.sock" -path "*/.urb/*" 2>/dev/null

# Broader search (slower)
find ~/ -maxdepth 5 -name "conn.sock" -path "*/.urb/*" 2>/dev/null
```

If the user provides a pier path directly, verify **both** the socket and the process:

```bash
# Check conn.sock exists
ls -la /path/to/pier/.urb/conn.sock

# ALSO verify ship process is running (socket can be stale)
pgrep -a urbit | grep pier-name
```

### Health Check

Verify the ship is responsive before sending commands:

```bash
echo "[0 %peel /live]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

A successful response means the ship is alive and accepting connections.

## Step 2: Determine Tooling

### Check for click

```bash
which click 2>/dev/null || echo "click not found"
```

If `click` is available, prefer it — it handles newt encoding/decoding automatically.

If `click` is not available, use the raw pipeline:

```bash
echo "<command>" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

### Check for urbit binary

```bash
which urbit 2>/dev/null || echo "urbit binary not found"
```

The `urbit` binary is required for both approaches (click depends on it too). If not on PATH, check common locations:

```bash
ls ~/urbit/urbit /usr/local/bin/urbit /opt/urbit/urbit 2>/dev/null
```

### Installing click

If click is not installed, inform the user:

> click is a bash thin client for conn.c. Install from: https://github.com/urbit/tools/tree/master/pkg/click
>
> Clone the repo and add the click script to your PATH.

## Step 3: Send Commands

All commands to conn.c are newt-encoded jammed nouns with format `[request-id command arguments]`.

The five command types:

| Command | Target | Action | Use For |
|---------|--------|--------|---------|
| `%peek` | Arvo | Scry (read) | Reading agent/vane state |
| `%peel` | Vere | Scry (read) | Runtime info, health checks |
| `%ovum` | Arvo | Inject event | Raw kernel events, pokes |
| `%fyrd` | Arvo (Khan) | Run thread | Executing Hoon code, complex operations |
| `%urth` | Vere | Runtime command | Pack, meld |

---

## Command Reference

### Maintenance

#### |pack (compact event log)

Raw pipeline:
```bash
echo "[0 %urth %pack]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

Via click:
```bash
click -kp /path/to/pier \
  $'=/  m  (strand ,vase)  ;<  ~  bind:m  (flog [%pack ~])  (pure:m !>(\\\'success\\\'))'
```

#### |meld (deduplicate persistent state)

Raw pipeline:
```bash
echo "[0 %urth %meld]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

Via click:
```bash
click -kp /path/to/pier \
  $'=/  m  (strand ,vase)  ;<  ~  bind:m  (flog [%meld ~])  (pure:m !>(\\\'success\\\'))'
```

### Ship Information

#### +code (get web login code)

```bash
click -kp /path/to/pier \
  $'=/  m  (strand ,vase)  ;<  our=@p  bind:m  get-our  ;<  code=@p  bind:m  (scry @p /j/code/(scot %p our))  (pure:m !>((crip (slag 1 (scow %p code)))))'
```

#### +vats (desk status)

All desks:
```bash
click -kp /path/to/pier \
  $'=/  m  (strand ,vase)  ;<  our=@p  bind:m  get-our  ;<  now=@da  bind:m  get-time  (pure:m !>((crip ~(ram re [%rose [~ ~ ~] (report-vats our now [%base %kids ~] %$ |)]))))' \
  '/sur/hood/hoon'
```

Existing desks only:
```bash
click -kp /path/to/pier \
  $'=/  m  (strand ,vase)  ;<  our=@p  bind:m  get-our  ;<  now=@da  bind:m  get-time  (pure:m !>((crip ~(ram re [%rose [~ ~ ~] (report-vats our now ~ %exists |)]))))' \
  '/sur/hood/hoon'
```

#### Health check (%peel /live)

```bash
echo "[0 %peel /live]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

#### Ship identity (%peel /who)

```bash
echo "[0 %peel /who]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

#### Vere version (%peel /v)

```bash
echo "[0 %peel /v]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

#### Help - list available commands (%peel /help)

```bash
echo "[0 %peel /help]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

#### Runtime info/metrics (%peel /info)

```bash
echo "[0 %peel /info]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

#### Check Khan vane status (%peel /khan)

```bash
echo "[0 %peel /khan]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

#### |mass output (%peel /mass)

```bash
echo "[0 %peel /mass]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

#### Query Ames port (%peel /port/ames)

```bash
echo "[0 %peel /port/ames]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

#### Query HTTP port (%peel /port/http)

```bash
echo "[0 %peel /port/http]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

#### Query HTTPS port (%peel /port/htls)

```bash
echo "[0 %peel /port/htls]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

### OTA Management

#### |ota ~bus (enable OTAs from sponsor)

Raw pipeline:
```bash
echo "[0 %ovum [%g /test [%deal [~ship ~ship] %hood %raw-poke %kiln-install %base ~bus %kids]]]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

Via click:
```bash
click -kp /path/to/pier \
  $'=/  m  (strand ,vase)  ;<  our=@p  bind:m  get-our  ;<  ~  bind:m  (poke [our %hood] %kiln-install !>([%base ~bus %kids]))  (pure:m !>(\\\'success\\\'))'
```

**Note:** Replace `~ship` with the actual ship name in the raw pipeline, and `~bus` with the desired OTA source.

#### |ota %disable

Via click:
```bash
click -kp /path/to/pier \
  $'=/  m  (strand ,vase)  ;<  our=@p  bind:m  get-our  ;<  ~  bind:m  (poke [our %hood] %kiln-install !>([%base our %base]))  (pure:m !>(\\\'success\\\'))'
```

### Desk Installation

#### |install ~sampel-palnet %desk

Raw pipeline:
```bash
echo "[0 %ovum [%g /test [%deal [~ship ~ship] %hood %raw-poke %kiln-install %desk ~sampel-palnet %desk]]]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

Via click:
```bash
click -kp /path/to/pier \
  $'=/  m  (strand ,vase)  ;<  our=@p  bind:m  get-our  ;<  ~  bind:m  (poke [our %hood] %kiln-install !>([%desk ~sampel-palnet %desk]))  (pure:m !>(\\\'success\\\'))'
```

#### |install with local name

```bash
click -kp /path/to/pier \
  $'=/  m  (strand ,vase)  ;<  our=@p  bind:m  get-our  ;<  ~  bind:m  (poke [our %hood] %kiln-install !>([%my-desk ~sampel-palnet %desk]))  (pure:m !>(\\\'success\\\'))'
```

### Arbitrary Hoon Evaluation

#### -eval (evaluate Hoon expression with ship state)

Via click:
```bash
click -kp /path/to/pier $'=/  m  (strand ,vase)  ;<  result=<TYPE>  bind:m  (eval <HOON-EXPRESSION>)  (pure:m !>(result))'
```

Simple example — evaluate `(add 2 2)`:
```bash
click -p /path/to/pier '(add 2 2)'
```

#### -khan-eval (run inline thread)

Via click:
```bash
click -k /path/to/pier '<THREAD-CODE>'
```

From file:
```bash
click -k -i /path/to/thread.hoon /path/to/pier
```

### Custom Thread Execution (%fyrd)

Raw pipeline:
```bash
echo "[0 %fyrd %base %thread-name %output-mark %input-mark <input-noun>]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

### Raw Event Injection (%ovum)

**WARNING:** `%ovum` injects raw kernel events. This is powerful and potentially dangerous. Always confirm the event structure with the user before sending.

```bash
echo "[0 %ovum <raw-kernel-move>]" | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -cn
```

## %gx scries (important gotchas)

- `%gx` is a **Gall (app) scry**.
- The **mark is part of the path** (eg `.../count/noun`, `.../pill/noun`).
- Your agent’s `on-peek` will typically see the path **prefixed with `/x`**.
  - Example: a `%gx` request to `.../count/noun` arrives at the agent as `path=/x/count`.
- `.^` returns the **decoded product**, *not* a `cage`.
  - So you usually want something like:
    - `.^(noun %gx /(scot %p p.bec)/myapp/(scot %da now)/foo/noun)`
    - or `.^(pill:pill %gx /(scot %p p.bec)/aqua/(scot %da now)/pill/noun)`
  - **Don’t** try to decode `%gx` as `(unit cage)` unless you’re sure the scry actually returns a cage.
- If the target app isn’t running, `%gx` can **hard-fail** (eg `bail: 4`, `arvo: scry-lost`) rather than returning `~`.

## Response Format

Responses from conn.c are newt-encoded jammed nouns: `[request-id output]`.

- **%urth**: Returns `%&` on success
- **%ovum**: Returns `[%news %done]` on success, `[%news %drop]` if dropped, `[%bail goof]` on error
- **%fyrd**: Returns `[%avow %& mark noun]` on success, `[%avow %| goof]` on error
- **%peek**: Returns `[%peek (unit (unit scry-output))]` — `~` means invalid endpoint, `[~ ~]` means empty result
- **%peel**: Returns `(unit result)` — `~` means invalid path

## Undocked Ships

If the ship is not docked (no `.run` file in pier), click won't work directly. Use the `click-format` helper with the raw pipeline:

```bash
click-format -k '<hoon-code>' | urbit eval -jn | nc -U -W 1 /path/to/pier/.urb/conn.sock | urbit eval -ckn
```

## Safety

- Always verify ship identity with `%peel /who` before sending commands
- Use `%peel /live` to confirm the ship is responsive before operations
- Never inject `%ovum` events without explicit user confirmation
- For maintenance ops (`|pack`, `|meld`), warn the user these can take significant time on large piers
- Always use `-W 1` (1 second timeout) with `nc` to avoid hanging on unresponsive sockets
- Prefer file-based threads (`-k -i`) over inline (`-kp`) to avoid shell escaping errors
- If `conn: moor bail -1 newt-decode` appears, the command was malformed — switch to file-based threads
- A `conn.sock` file does NOT guarantee the ship is running — check for a live process with `pgrep -a urbit`
