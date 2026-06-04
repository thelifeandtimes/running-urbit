---
name: urbit-fundamentals
description: Deep understanding of Urbit's architecture including Nock, Hoon, Arvo OS, Vere runtime, vanes (kernel modules), loom memory model, event log, Azimuth identity system, and Ames networking. Use when explaining Urbit internals, diagnosing low-level issues, architecting deployments, or understanding system constraints.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Urbit Fundamentals Skill

Deep understanding of Urbit's architecture, components, and operational principles essential for effective deployment, troubleshooting, and optimization.

## Overview

This skill provides comprehensive knowledge of Urbit's technical architecture from the lowest level (Nock) to the highest (userspace applications). Understanding these fundamentals is critical for diagnosing issues, optimizing performance, and making informed operational decisions.

## Learning Objectives

After mastering this skill, you will understand:

1. **Nock**: The functional assembly language underlying all of Urbit
2. **Hoon**: The high-level functional programming language for Urbit development
3. **Arvo**: The Urbit operating system kernel and its architecture
4. **Vere**: The runtime environment and virtual machine
5. **Vanes**: The ten kernel modules that provide core OS functionality
6. **Loom**: The memory model and its constraints
7. **Event Log**: Persistent state management and replay mechanics
8. **Azimuth**: The identity system and PKI on Ethereum
9. **Ames**: The encrypted peer-to-peer networking protocol

## 1. The Urbit Stack

Urbit consists of multiple abstraction layers, each building on the one below:

```
┌─────────────────────────────────────┐
│  Userspace Applications             │  ← Landscape, Bitcoin wallet, etc.
├─────────────────────────────────────┤
│  Gall (Application Management)      │  ← Agent lifecycle, state management
├─────────────────────────────────────┤
│  Other Vanes (9 kernel modules)     │  ← Ames, Clay, Eyre, etc.
├─────────────────────────────────────┤
│  Arvo (OS Kernel)                   │  ← Event routing, state transitions
├─────────────────────────────────────┤
│  Hoon (High-Level Language)         │  ← Functional programming
├─────────────────────────────────────┤
│  Nock (Assembly Language)           │  ← Axiomatic computation
├─────────────────────────────────────┤
│  Vere (Runtime / VM)                │  ← Nock interpreter, I/O
├─────────────────────────────────────┤
│  Unix (Linux, macOS, etc.)          │  ← Host operating system
└─────────────────────────────────────┘
```

## 2. Nock: The Foundation

### What is Nock?

**Nock** is a functional assembly-level language that serves as the axiomatic representation of a deterministic computer. It is the lowest layer of Urbit's computational model.

### Key Characteristics

- **Pure function**: All Nock computation is deterministic (same input → same output)
- **Minimal specification**: Only 12 opcodes (11 instructions + crash)
- **Homoiconic**: Code and data have the same representation (nouns)
- **Stateless**: Nock itself has no mutable state

### Noun Data Structure

Everything in Nock is a **noun**:
- A noun is either an **atom** (unsigned integer) or a **cell** (ordered pair of nouns)
- Example: `[1 [2 3]]` is a cell containing atom 1 and cell `[2 3]`

### Why Nock Matters for Operators

- **Determinism**: Nock's determinism ensures reproducible computation across all Urbit ships
- **Portability**: Any correct Nock interpreter produces identical results
- **Debugging**: Understanding Nock helps diagnose deep runtime issues
- **Event replay**: Event logs can be replayed because Nock is deterministic

### Reference

- Official Nock specification: https://docs.urbit.org/nock/specification
- Nock definition: https://urbit.org/docs/glossary/nock

## 3. Hoon: The Language

### What is Hoon?

**Hoon** is Urbit's high-level purely functional programming language, designed for building Arvo and userspace applications. Hoon compiles down to Nock.

### Key Characteristics

- **Purely functional**: No side effects, immutable data
- **Statically typed**: Strong type system (molds)
- **Subject-oriented**: All code operates on a "subject" (context)
- **Rune-based syntax**: Two-character ASCII symbols (`|=`, `=<`, `%=`, etc.)

### Why Hoon Matters for Operators

- **Userspace is written in Hoon**: Understanding Hoon helps read app source code
- **Dojo commands are Hoon**: Commands like `|pack`, `+code` are Hoon expressions
- **Debugging**: Error messages reference Hoon code locations
- **Performance**: Inefficient Hoon can cause performance issues

### Hoon Compilation

```
Hoon Source Code
     ↓ (compiled by Hoon compiler)
Nock Code
     ↓ (executed by Vere runtime)
Result
```

### Reference

- Hoon language documentation: https://docs.urbit.org/build-on-urbit/hoon-school
- Hoon School (tutorial): https://docs.urbit.org/courses/hoon-school

## 4. Arvo: The Operating System

### What is Arvo?

**Arvo** is the Urbit operating system kernel, written in Hoon (~1,000 lines), compiled to Nock, and executed by the Vere runtime. Arvo is a single-level store OS with a functional state transition model.

### Core Functionality

Arvo's primary purpose is implementing the **transition function** (`+poke`):

```
+poke: (event, old-state) → new-state
```

This pure function takes:
- An **event** (input from Unix, network, timer, etc.)
- The **current state** of the OS

And produces:
- The **new state** after processing the event
- Zero or more **effects** (outputs to Unix, network, etc.)

### Key Principles

1. **Single-level store**: All persistent state in one unified address space
2. **Event sourcing**: State is a pure function of the event log
3. **Purely functional**: No direct I/O, all effects are values returned
4. **Vane delegation**: Arvo routes events to the appropriate vane (kernel module)

### Arvo's Role

- **Event routing**: Dispatch events to the correct vane
- **State management**: Coordinate the unified OS state
- **Vane coordination**: Manage communication between vanes
- **Effect handling**: Pass effects to Vere for execution

### Why Arvo Matters for Operators

- **State transitions**: Understanding +poke helps debug state issues
- **Event log**: Arvo's event log is the ship's "source of truth"
- **Upgrades**: OTA updates replace Arvo code via events
- **Performance**: Arvo's efficiency directly affects ship responsiveness

### Reference

- Arvo overview: https://docs.urbit.org/urbit-os/kernel/arvo
- Arvo architecture: https://docs.urbit.org/courses/app-school/1-arvo
- Arvo source: sys/arvo.hoon in urbit/urbit repository

## 5. Vere: The Runtime Environment

### What is Vere?

**Vere** is the Nock virtual machine and runtime environment that serves as the interface between Urbit (Nock/Hoon/Arvo) and Unix (the host operating system). Written in C.

### Core Responsibilities

1. **Nock interpreter**: Execute Nock instructions
2. **Event log persistence**: Write events to disk (consistently at each event)
3. **Snapshot management**: Periodically snapshot loom state for fast restarts
4. **I/O handling**: Interface with Unix for networking, filesystem, HTTP, etc.
5. **Memory management**: Manage the loom (Urbit's memory arena)

### Vere Components

- **Noun allocator (u3a)**: Manage loom memory allocation
- **Noun deduplication (u3h)**: Detect and merge duplicate nouns (memory efficiency)
- **Event log manager**: Persist events to disk
- **I/O drivers**: Unix filesystem, sockets, HTTP servers, etc.

### Why Vere Matters for Operators

- **Binary updates**: Updating Urbit = updating Vere runtime
- **Crash debugging**: Vere crashes (bail: errors) require understanding runtime
- **Performance tuning**: Loom size, snapshot frequency, I/O optimization
- **Platform compatibility**: Vere is platform-specific (Linux/macOS/BSD)

### Vere Versions

Check Vere version:
```bash
urbit --version
# Output: Urbit vere v4.2
```

Update Vere:
```bash
curl -L https://urbit.org/install/linux-x86_64/latest | tar xzk --transform='s/.*/urbit/g'
sudo mv urbit /usr/local/bin/
```

### Reference

- Vere runtime reference: https://operators.urbit.org/manual/running/vere
- Vere internals: https://docs.urbit.org/build-on-urbit/core-academy/ca05

## 6. Vanes: The Kernel Modules

### What are Vanes?

**Vanes** are Arvo's ten kernel modules that provide core operating system functionality. Most of Arvo's work is delegated to vanes—Arvo itself just routes events.

### The 10 Vanes (2025)

1. **Ames** (`%ames`): Encrypted peer-to-peer networking protocol
2. **Behn** (`%behn`): Timer management (scheduling future events)
3. **Clay** (`%clay`): Filesystem and revision control
4. **Dill** (`%dill`): Terminal driver (dojo interface)
5. **Eyre** (`%eyre`): HTTP server (web interface, API endpoints)
6. **Gall** (`%gall`): Application management (agent lifecycle, state)
7. **Iris** (`%iris`): HTTP client (outbound HTTP requests)
8. **Jael** (`%jael`): Azimuth PKI management (ship identities, keys)
9. **Khan** (`%khan`): External API for thread execution
10. **Lick** (`%lick`): Inter-process communication (IPC)

### Vane Interactions

Example: Loading a web page

```
User visits ship URL (https://ship.arvo.network)
          ↓
Eyre (HTTP server vane) receives request
          ↓
Eyre routes to Gall app (e.g., Landscape)
          ↓
Gall app processes request, returns HTML
          ↓
Eyre sends HTTP response
          ↓
User sees web page
```

### Critical Vanes for Operators

**Ames** (Networking)
- Protocol: Encrypted UDP packets on port 34543
- NAT traversal: Requires port forwarding or UPnP
- Connectivity: Test with `|hi ~zod` in dojo
- Troubleshooting: Firewall issues, router configuration

**Eyre** (HTTP Server)
- Listens on localhost port (default 8080 or 80)
- Serves Landscape web interface
- Requires reverse proxy (Nginx) for HTTPS
- Login code: `+code` in dojo

**Gall** (Applications)
- Manages all userspace agents
- List running apps: `+vats` in dojo
- Suspend app: `|suspend %app-name`
- OTA updates often blocked by Gall apps

**Clay** (Filesystem)
- Stores ship's filesystem (desks)
- OTA updates delivered via Clay
- Desk list: `+vats` (shows desk usage)

**Jael** (Azimuth)
- Manages ship identity and cryptographic keys
- Syncs Azimuth state from Ethereum
- Sponsor relationships tracked by Jael
- Breach (identity reset) handled by Jael

### Reference

- Vanes overview: https://docs.urbit.org/urbit-os/kernel/arvo
- Individual vane docs: https://developers.urbit.org/reference/arvo/overview

## 7. The Loom: Memory Model

### What is the Loom?

The **loom** is Urbit's contiguous block of memory that serves as both the persistent state storage and working space for computation. The loom is a critical architectural component with important operational implications.

### Loom Characteristics (2025)

- **Contiguous memory**: Single continuous address space
- **Configurable size**: 1GB, 2GB (default), 4GB, or 8GB maximum
- **Fixed at boot**: Loom size set via `--loom` flag cannot change while running
- **Page-based**: Organized into 16KB pages
- **Special allocators**: Requires u3a allocators (standard malloc won't work)

### Loom Size Configuration

Loom sizes specified as powers of 2:
- `--loom 30` = 2^30 = 1GB
- `--loom 31` = 2^31 = 2GB (default)
- `--loom 32` = 2^32 = 4GB
- `--loom 33` = 2^33 = 8GB (maximum)

**Example**:
```bash
# Boot with 4GB loom
urbit --loom 32 /path/to/pier

# IMPORTANT: Must use same --loom on every subsequent boot
# Loom size is "sticky" - once set, must be maintained
# unless `meld` or `pack` brings loom size underneath the previous cap
```

### The 2GB Limit and "Out of Loom" Errors

**Historical context**: Urbit originally had a hard 2GB loom limit. Heavily-used ships could exceed this and crash with `bail: meme` or `out of loom` errors.

**2025 status**: Loom is now configurable up to 8GB, but:
- Most ships still use default 2GB
- Changing loom size requires persistence (every boot)
- Larger loom = more RAM usage

**When ships hit loom limit**:
```
# Symptom: Error messages
bail: meme
out of loom
address-out-of-loom

# Solution 1: Reduce state size
|pack  # Fast defragmentation (10-30% reduction)
|meld  # Slow deduplication (30-70% reduction, uses 8GB RAM)

# Solution 2: Increase loom (if system has RAM)
# Stop ship
urbit --loom 32 /path/to/pier  # 4GB loom
# MUST use --loom 32 on every subsequent boot
```

### Why Loom Matters for Operators

- **Memory errors**: "Out of loom" is common production issue
- **State management**: |pack and |meld reduce loom usage
- **Resource planning**: Ships need RAM = loom size + overhead
- **Performance**: Full loom causes frequent garbage collection (slow)

### Loom Best Practices

1. **Monitor loom usage**: Check pier size regularly (`du -sh pier/`)
2. **Preventive maintenance**: Run `|pack` weekly to prevent loom exhaustion
3. **Emergency cleanup**: Use `|meld` if ship approaching 2GB and cannot increase loom
4. **Plan for growth**: Consider 4GB loom for heavily-used ships
5. **System resources**: Ensure host has 2x loom size in RAM (for |meld)

### Future Capabilities
- the `vere64` project aims to ship in H1 of 2026 and will free the Urbit runtime from the loom size limitation, thus making it possible to store incredibly large amount of large files in your urbit (10s of TB). 

### Reference

- Loom architecture: https://docs.urbit.org/build-on-urbit/core-academy/ca06
- Memory management: https://docs.urbit.org/courses/core-academy/ca06

## 8. Event Log: State Persistence

### What is the Event Log?

The **event log** is the ordered list of all Arvo events (completed state transitions) that have occurred on a ship. It is the "source of truth" for ship state.

### Key Principles

1. **Pure function**: Ship state = function(event log)
2. **Append-only**: Events never deleted or modified (immutable)
3. **Deterministic replay**: Replaying event log recreates exact state
4. **Snapshots**: Loom state periodically snapshotted to avoid full replay

### Event Log Structure

```
Event Log (on disk: pier/.urb/log/)
├─ Event 1: Boot ship with keyfile
├─ Event 2: OTA update from sponsor
├─ Event 3: User installs app
├─ Event 4: Timer fires
├─ Event 5: HTTP request received
└─ Event N: Current state
```

Each event:
- Has a sequence number (monotonically increasing)
- Contains input (move from vane or Unix)
- Results in state transition (old state → new state)
- May produce effects (outputs to Unix, network, etc.)

### Event Processing

```
Unix I/O → Vere → Event → Arvo (+poke) → New State → Snapshot (periodic) → Disk
                                   ↓
                            Event Log Entry
```

### Snapshots and Recovery

**Problem**: Replaying millions of events on boot is slow

**Solution**: Periodic snapshots of loom state

When ship boots:
1. Load most recent snapshot (fast)
2. Replay events since snapshot (incremental)
3. Result: Current state restored

### Why Event Log Matters for Operators

**Backup Safety**:
- **NEVER backup live pier**: Corrupts event log (inconsistent state)
- **Safe backup procedure**: Stop ship → wait 30s → backup → restart
- Backup must capture consistent event log + snapshot

**Corruption Recovery**:
- **Symptom**: Ship won't boot, event replay errors
- **Diagnosis**: Event log corruption (disk failure, improper shutdown)
- **Recovery**: Restore from backup (if available)
- **Last resort**: Factory reset (data loss)

**Event Replay**:
```bash
# Replay events (debug/recovery)
urbit-worker replay /path/to/pier

# If replay fails, event log is corrupted
```

**OTA Updates**:
- OTA updates are events in the event log
- Failed OTA = corrupted event (may need sponsor change)

### Event Log Best Practices

1. **Graceful shutdown always**: `ctrl+d` in dojo (or `systemctl stop`)
2. **Never kill -9**: SIGKILL can corrupt event log mid-write
3. **Backup when stopped**: Consistent event log + snapshot
4. **SSD recommended**: Fast I/O for event log writes
5. **Disk space**: Event log grows over time (monitor `du -sh pier/.urb/log/`)

### Reference

- Event log documentation: https://docs.urbit.org/build-on-urbit/core-academy/ca04

## 9. Azimuth: The Identity System

### What is Azimuth?

**Azimuth** is Urbit's general-purpose public-key infrastructure (PKI) implemented as smart contracts on the Ethereum blockchain. It manages Urbit identities (ships) and their cryptographic keys.

### Azimuth Components

1. **Smart contracts** (Ethereum Layer 1 or Layer 2)
2. **Bridge** (web interface: bridge.urbit.org)
3. **Jael vane** (syncs Azimuth state to ship)
4. **Roller** (Layer 2 transaction batching service)

### The Urbit Address Space

Urbit's namespace is a 128-bit address space with hierarchical structure:

```
Galaxies (2^8 = 256)
    ↓ spawn
Stars (2^16 = 65,536)
    ↓ spawn
Planets (2^32 = ~4.3 billion)
    ↓ spawn
Moons (2^64, not on Azimuth)
    ↓
Comets (2^128, not on Azimuth)
```

**Ownership hierarchy**:
- **Galaxies** (~zod, ~marzod, etc.): Root infrastructure, govern network
- **Stars** (~litzod, ~sampel, etc.): Sponsor planets, can sponsor/route
- **Planets** (~sampel-palnet, etc.): Personal identities, not transferable sponsorship
- **Moons**: Disposable identities, tied to parent planet
- **Comets**: Self-generated, zero-trust identities

### Azimuth Layer 2 (Naive Rollups)

**Introduced**: 2021

**Problem**: Ethereum Layer 1 gas fees were expensive ($50-200 per transaction)

**Solution**: Naive rollups (Layer 2)
- Batch multiple Azimuth transactions into single Ethereum transaction
- Compute PKI state transitions off-chain (on your Urbit)
- **Cost savings**: 65-100x cheaper than Layer 1
- **Tlon's free roller**: Free for ordinary public use

**How L2 works**:
1. User submits Azimuth transaction (e.g., transfer planet)
2. Transaction sent to roller (batching service)
3. Roller aggregates transactions from many users
4. Roller submits batch to Ethereum (single L1 transaction)
5. Your Urbit computes state transition locally (verifies in Jael)

**Result**: New users can get Azimuth identity without prior crypto knowledge

### Azimuth Operations

Common operations via Bridge (bridge.urbit.org):

1. **Transfer ownership**: Change planet owner (L1 or L2)
2. **Set networking keys**: Rotate cryptographic keys (for security)
3. **Configure spawn proxy**: Delegate spawning rights
4. **Set management proxy**: Delegate management operations
5. **Escape**: Change sponsor (star)

### Why Azimuth Matters for Operators

**Identity Verification**:
- Ship's identity proven via Azimuth (cryptographic)
- Ames networking uses Azimuth keys (end-to-end encryption)

**Sponsorship**:
- Stars sponsor planets (provide OTA updates, routing)
- Change sponsor: `|ota ~new-sponsor` in dojo
- Sponsor unreachable → OTA updates fail

**Breach (Identity Reset)**:
- "Breach" = reset ship identity (new keys, abandoned old state)
- Necessary if: Keys compromised, unrecoverable corruption, network ban
- Performed via Bridge (L1 or L2)
- **Effect**: All other ships forget old ship (must re-authenticate)

**Keyfile Security**:
- Master ticket (from Bridge) generates keyfile
- Keyfile used ONCE to boot planet (consumed after first boot)
- **NEVER reuse keyfile**: Causes network ban
- **NEVER share keyfile**: Full control of ship identity

### Azimuth Best Practices

1. **Secure master ticket**: Store offline, encrypted (password manager)
2. **One-time keyfile**: Use keyfile once, then delete (`shred -u keyfile.key`)
3. **Backup strategy**: Backup pier (stopped), NOT keyfile
4. **Sponsor selection**: Choose reliable star (uptime, OTA delivery)
5. **Layer 2 preferred**: Use L2 for all Azimuth operations (cheaper, faster)

### Reference

- Azimuth overview: https://developers.urbit.org/reference/azimuth/azimuth
- Layer 2 guide: https://developers.urbit.org/reference/azimuth/l2/layer2
- Bridge interface: https://bridge.urbit.org

## 10. Ames: Networking Protocol

### What is Ames?

**Ames** is Urbit's encrypted peer-to-peer networking protocol that enables ships to communicate directly with each other. It is one of the ten vanes in Arvo.

### Ames Characteristics

1. **End-to-end encrypted**: All messages encrypted using Azimuth keys
2. **UDP-based**: Uses UDP port 34543
3. **NAT traversal**: Requires port forwarding or symmetric routing
4. **Packet-based**: Sends encrypted packets directly between ships
5. **Sponsorship-aware**: Uses sponsor ships for routing when direct unreachable

### Ames Architecture

```
Ship A                                Ship B
   ↓                                     ↑
Ames vane                           Ames vane
   ↓                                     ↑
Vere runtime                        Vere runtime
   ↓                                     ↑
UDP socket (port 34543)             UDP socket (port 34543)
   ↓                                     ↑
   └──────── Internet (encrypted) ──────┘
```

### Ames Packet Format

Each Ames packet:
- Encrypted with ship's Azimuth keys
- Contains sender/receiver ship addresses
- Includes message payload
- Authenticated (prevents spoofing)

**Security guarantee**: Only ship with valid Azimuth key can send/receive as that ship

### Ames Connectivity Requirements

**Firewall**:
```bash
# Open UDP port 34543
sudo ufw allow 34543/udp
```

**Router** (if behind NAT):
- Port forward UDP 34543 to ship's local IP
- Or use UPnP (automatic port forwarding)
- Symmetric NAT can cause issues (use StarTram/Anchor)

**Testing**:
```
# In dojo, ping ~zod (network bootstrap)
|hi ~zod
# Should see: ack from ~zod

# If no ack, Ames connectivity broken
```

### Ames Troubleshooting

**Problem**: Ship shows offline to other ships

**Diagnosis**:
1. Check firewall: `sudo ufw status | grep 34543`
2. Check router port forwarding (if behind NAT)
3. Test connectivity: `|hi ~zod` in dojo
4. Check sponsor: `+trouble` in dojo

**Solutions**:
- Open UDP 34543 in firewall
- Configure router port forwarding
- Use StarTram (managed networking) or Anchor (self-hosted)
- Change sponsor if current unreachable: `|ota ~litzod`

### Ames Performance

**Bandwidth**:
- Ames is designed for low-bandwidth scenarios
- Large file transfers (S3 via MinIO recommended)
- Image/video hosting (external, not Ames)

**Latency**:
- UDP provides low-latency messaging
- Direct ship-to-ship: <100ms typical
- Via sponsor routing: 200-500ms

### Why Ames Matters for Operators

- **Core functionality**: Ames is required for ship-to-ship communication
- **Firewall critical**: UDP 34543 must be open
- **NAT challenges**: Home/office networks require port forwarding
- **Connectivity debugging**: Most "ship offline" issues are Ames-related
- **Security**: Ames encryption ensures privacy (but event log not encrypted at rest)

### Reference

- Ames protocol: https://docs.urbit.org/urbit-os/kernel/ames
- Ames troubleshooting: https://operators.urbit.org/guides/urbit-security

## 11. Integration: How It All Works Together

### Boot Sequence

1. **Vere starts**: Load Urbit binary, allocate loom
2. **Event log replay**: Load snapshot + replay events since snapshot
3. **Arvo boots**: Initialize kernel, load vanes
4. **Azimuth sync**: Jael vane syncs identity from Ethereum
5. **Ames networking**: Establish connectivity with sponsor/peers
6. **HTTP server**: Eyre vane starts listening (localhost port)
7. **Userspace**: Gall loads all installed applications
8. **Ready**: Ship operational, dojo accessible

### Event Processing Flow

```
External Event (HTTP request, Ames packet, timer)
        ↓
Vere captures event
        ↓
Event written to event log
        ↓
Arvo routes event to appropriate vane
        ↓
Vane processes event (state transition)
        ↓
Effects produced (HTTP response, Ames send, etc.)
        ↓
Vere executes effects (writes to network, etc.)
        ↓
Loom snapshot (periodic)
```

### OTA Update Flow

```
Sponsor ship publishes OTA update
        ↓
Ames delivers update to Clay (filesystem vane)
        ↓
Clay verifies update integrity
        ↓
Arvo applies kernel update (if kernel OTA)
        ↓
Gall applies userspace updates (if app OTA)
        ↓
Update complete (ship may restart)
```

### Memory Management

```
App allocates noun → u3a allocator → Loom
                                       ↓
                                  Loom fills
                                       ↓
                            Garbage collection (periodic)
                                       ↓
                                 Deduplication
                                       ↓
                            If still too full → |pack or |meld
```

## 12. Operational Implications

Understanding Urbit fundamentals informs operational decisions:

### Deployment

- **Loom size**: Plan based on expected state growth (2GB default, 4GB+ for heavy use)
- **System RAM**: 2x loom size minimum (for |meld, which uses 8GB)
- **SSD strongly recommended**: Event log writes, snapshot I/O

### Troubleshooting

- **Boot failures**: Check event log, loom size, Vere version
- **Memory errors**: |pack (quick), |meld (slow but thorough)
- **Network issues**: Ames (UDP 34543), sponsor connectivity
- **OTA failures**: |bump (suspend blocking apps), change sponsor

### Performance

- **CPU**: Nock interpretation (Vere efficiency), Hoon compilation
- **RAM**: Loom size, garbage collection frequency
- **Disk I/O**: Event log writes, snapshot creation, Clay filesystem
- **Network**: Ames bandwidth (low), Eyre HTTP (reverse proxy caching)

### Security

- **Identity**: Azimuth keys, keyfile handling
- **Networking**: Ames encryption (in transit), event log not encrypted (at rest)
- **Isolation**: Systemd sandboxing, dedicated user account
- **Updates**: OTA security patches, Vere runtime updates

### Backup/Recovery

- **Event log consistency**: Stop ship before backup
- **Snapshot alignment**: Backup captures consistent event log + snapshot
- **Restoration**: Extract backup, boot ship (replays events if needed)
- **Factory reset**: Last resort (data loss, requires fresh keyfile from Bridge)

## 13. Further Learning

### Official Documentation

- **docs.urbit.org**: Primary documentation hub

### Courses

- **Hoon School**: Learn Hoon programming
- **App School**: Build Urbit applications
- **Core Academy**: Deep dive into Nock, Arvo, Vere internals

### Community Resources

- **GitHub**: https://github.com/urbit/urbit (source code, issues)
- **nock.is**: Nock ISA / Language specific site
- **urbitsystems.tech**: Technical Journal about Urbit and Solid-State Computing

## 14. Key Takeaways

1. **Nock is the foundation**: Deterministic, pure functional computation
2. **Hoon compiles to Nock**: High-level language for practical development
3. **Arvo is a state transition function**: +poke processes events
4. **Vere is the runtime**: Executes Nock, manages event log and loom
5. **Vanes are kernel modules**: 10 vanes provide core OS functionality
6. **Loom is memory arena**: 2GB default, 8GB max, must manage growth
7. **Event log is source of truth**: Append-only, deterministic replay
8. **Azimuth is Ethereum PKI**: Ship identities, Layer 2 (65-100x cheaper)
9. **Ames is encrypted networking**: UDP port 34543, end-to-end encrypted
10. **Understanding fundamentals enables effective operations**: Troubleshooting, optimization, security

## Summary

Urbit's architecture is unique: a purely functional OS with deterministic computation (Nock), persistent state (event log), cryptographic identity (Azimuth), and encrypted networking (Ames). Operators must understand these fundamentals to effectively deploy, secure, troubleshoot, and optimize Urbit ships in production environments.

This knowledge forms the foundation for all other urbit-operations skills: deployment procedures, troubleshooting workflows, performance optimization, and backup/disaster recovery all build upon these core architectural principles.
