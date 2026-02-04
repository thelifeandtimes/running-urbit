# urbit-skills

AI agent skills for Urbit development, operations, and tooling. Follows the [Agent Skills](https://agentskills.io/) open standard.

These skills give coding agents practical knowledge of the Urbit runtime, Hoon programming, Nock assembly, ship deployment, and operational workflows -- solving the problem of AI agents having imperfect understanding of Urbit's unique stack.

## Quick Start

**Claude Code:**
```bash
/add-dir /path/to/urbit-skills
```

**Other agents:** Copy individual skill directories from `skills/` into your agent's skills directory.

## What's Included

**87 skills** across four categories:

| Category | Count | Purpose |
|----------|-------|---------|
| Knowledge | 53 | Reference material for Hoon, Nock, Arvo, and infrastructure |
| Workflow | 26 | Multi-phase processes for development, deployment, and ops |
| Assistant | 6 | Interactive guidance for coding, debugging, and optimization |
| Interaction | 2 | Direct ship communication via conn.sock and terminal |

## Skills

### Ship Interaction

| Skill | Type | Description |
|-------|------|-------------|
| [urbit-conn](./skills/urbit-conn/) | Interaction | Programmatic ship control via conn.sock -- scry, runtime queries, thread execution, event injection |
| [urbit-terminal](./skills/urbit-terminal/) | Interaction | Interactive dojo access via screen/tmux -- command execution, output capture, safety guards |

### Ship Operations & Deployment

| Skill | Type | Description |
|-------|------|-------------|
| [urbit-fundamentals](./skills/urbit-fundamentals/) | Knowledge | Nock, Hoon, Arvo, vanes, Azimuth, Ames |
| [urbit-troubleshooting](./skills/urbit-troubleshooting/) | Knowledge | Systematic diagnostics |
| [ship-deployment-guide](./skills/ship-deployment-guide/) | Knowledge | Step-by-step deployment procedures |
| [vps-deployment-providers](./skills/vps-deployment-providers/) | Knowledge | DigitalOcean, Linode, Vultr, AWS, Hetzner |
| [groundseg-installation](./skills/groundseg-installation/) | Knowledge | Docker setup, Anchor networking, MinIO S3 |
| [groundseg-troubleshooting](./skills/groundseg-troubleshooting/) | Knowledge | Container issues, DNS, SSL certificates |
| [kubernetes-urbit](./skills/kubernetes-urbit/) | Knowledge | StatefulSets, persistent volumes, GitOps |
| [multi-ship-orchestration](./skills/multi-ship-orchestration/) | Knowledge | Resource allocation, network isolation |
| [fleet-operations](./skills/fleet-operations/) | Knowledge | Terraform IaC, Helm, staged OTA updates |
| [managed-hosting-comparison](./skills/managed-hosting-comparison/) | Knowledge | Tlon, Red Horizon, and hosting providers |
| [minio-s3-integration](./skills/minio-s3-integration/) | Knowledge | Self-hosted S3 for ship storage |
| [performance-engineer-assistant](./skills/performance-engineer-assistant/) | Assistant | Performance troubleshooting and tuning |
| [deploy-planet-workflow](./skills/deploy-planet-workflow/) | Workflow | Bare-metal planet deployment (10 phases) |
| [deploy-vps-planet-workflow](./skills/deploy-vps-planet-workflow/) | Workflow | VPS-optimized deployment |
| [deploy-groundseg-workflow](./skills/deploy-groundseg-workflow/) | Workflow | Multi-ship Docker orchestration |
| [deploy-fleet-workflow](./skills/deploy-fleet-workflow/) | Workflow | Kubernetes fleet deployment (100+ ships) |
| [setup-production-workflow](./skills/setup-production-workflow/) | Workflow | 20-phase security hardening |
| [setup-monitoring-workflow](./skills/setup-monitoring-workflow/) | Workflow | Observability stack deployment |
| [setup-cicd-pipeline-workflow](./skills/setup-cicd-pipeline-workflow/) | Workflow | CI/CD for ship updates |
| [troubleshoot-ship-workflow](./skills/troubleshoot-ship-workflow/) | Workflow | Systematic diagnostic decision trees |
| [migrate-deployment-workflow](./skills/migrate-deployment-workflow/) | Workflow | Zero-downtime migration |
| [optimize-performance-workflow](./skills/optimize-performance-workflow/) | Workflow | Performance tuning |
| [orchestrate-deployment-workflow](./skills/orchestrate-deployment-workflow/) | Workflow | Intelligent deployment coordination |

### Monitoring, Backup & Reliability

| Skill | Type | Description |
|-------|------|-------------|
| [monitoring-observability](./skills/monitoring-observability/) | Knowledge | Prometheus, Grafana, Loki, AlertManager |
| [performance-optimization](./skills/performance-optimization/) | Knowledge | Disk I/O, memory, network tuning |
| [performance-profiling](./skills/performance-profiling/) | Knowledge | Bottleneck identification, capacity planning |
| [sla-management](./skills/sla-management/) | Knowledge | Uptime targets, incident response, error budgets |
| [backup-disaster-recovery](./skills/backup-disaster-recovery/) | Knowledge | Automated backups, restoration procedures |
| [disaster-recovery-advanced](./skills/disaster-recovery-advanced/) | Knowledge | Multi-region failover, cross-region replication |

### Networking & Security

| Skill | Type | Description |
|-------|------|-------------|
| [anchor-networking](./skills/anchor-networking/) | Knowledge | Reverse proxy, Let's Encrypt SSL, custom domains |
| [network-security-advanced](./skills/network-security-advanced/) | Knowledge | Zero-trust networking, VPNs, network policies |
| [container-security](./skills/container-security/) | Knowledge | User namespaces, capabilities, AppArmor |
| [advanced-security-patterns](./skills/advanced-security-patterns/) | Knowledge | Defense-in-depth, intrusion detection |
| [compliance-frameworks](./skills/compliance-frameworks/) | Knowledge | GDPR, HIPAA, SOC2, ISO 27001 |

### Hoon Development

| Skill | Type | Description |
|-------|------|-------------|
| [hoon-basics](./skills/hoon-basics/) | Knowledge | Syntax fundamentals quick reference |
| [hoon-fundamentals](./skills/hoon-fundamentals/) | Knowledge | Subject-oriented programming, noun model |
| [rune-reference](./skills/rune-reference/) | Knowledge | Complete reference for 90+ runes |
| [type-system](./skills/type-system/) | Knowledge | Structural typing, auras, molds, type casting |
| [functional-programming-patterns](./skills/functional-programming-patterns/) | Knowledge | Pure functions, higher-order functions, recursion |
| [advanced-patterns](./skills/advanced-patterns/) | Knowledge | Doors, wet gates, mold builders, metaprogramming |
| [irregular-forms](./skills/irregular-forms/) | Knowledge | Syntactic shortcuts and common sugar |
| [hoon-style-guide](./skills/hoon-style-guide/) | Knowledge | Naming conventions and code organization |
| [data-structures](./skills/data-structures/) | Knowledge | Lists, sets, maps, mops, jars, jugs |
| [string-handling](./skills/string-handling/) | Knowledge | Cord, tape, term, knot types |
| [serialization](./skills/serialization/) | Knowledge | JSON, vases, jam/cue, marks |
| [stdlib-reference](./skills/stdlib-reference/) | Knowledge | Standard library (hoon.hoon) |
| [zuse-libraries](./skills/zuse-libraries/) | Knowledge | HTTP, JSON, crypto, scry utilities |
| [gall-agents](./skills/gall-agents/) | Knowledge | Complete Gall agent development lifecycle |
| [generators](./skills/generators/) | Knowledge | Naked, %say, %ask generators for CLI tools |
| [parsing](./skills/parsing/) | Knowledge | Parser combinators and custom parsers |
| [sail-markup](./skills/sail-markup/) | Knowledge | HTML templating in Hoon |
| [app-development-workflow](./skills/app-development-workflow/) | Knowledge | End-to-end development process |
| [hoon-expert-assistant](./skills/hoon-expert-assistant/) | Assistant | Expert coding help, type errors, optimization |
| [debugging-specialist-assistant](./skills/debugging-specialist-assistant/) | Assistant | Systematic debugging: compilation to runtime |
| [hoon-review-workflow](./skills/hoon-review-workflow/) | Workflow | Code review (quality, security, performance) |
| [hoon-optimize-workflow](./skills/hoon-optimize-workflow/) | Workflow | Performance optimization with benchmarking |
| [hoon-debug-workflow](./skills/hoon-debug-workflow/) | Workflow | Systematic debugging workflow |
| [hoon-refactor-workflow](./skills/hoon-refactor-workflow/) | Workflow | Safe refactoring preserving correctness |
| [hoon-test-workflow](./skills/hoon-test-workflow/) | Workflow | Unit, integration, property-based, TDD |
| [hoon-migrate-workflow](./skills/hoon-migrate-workflow/) | Workflow | Safe state migration for Gall agents |
| [hoon-scaffold-workflow](./skills/hoon-scaffold-workflow/) | Workflow | Project bootstrapping with best practices |
| [orchestrate-feature-workflow](./skills/orchestrate-feature-workflow/) | Workflow | End-to-end feature development orchestration |

### Nock Development

| Skill | Type | Description |
|-------|------|-------------|
| [nock-essentials](./skills/nock-essentials/) | Knowledge | Nouns, reduction model, evaluation semantics |
| [nock-operators](./skills/nock-operators/) | Knowledge | 6 operators: ?, +, =, /, #, * |
| [nock-instructions](./skills/nock-instructions/) | Knowledge | All 13 reduction rules (0-12) with examples |
| [nock-specification-reference](./skills/nock-specification-reference/) | Knowledge | Complete formal Nock 4K specification |
| [nock-tree-addressing](./skills/nock-tree-addressing/) | Knowledge | Binary tree axis encoding, slot calculation |
| [nock-cores-arms-batteries](./skills/nock-cores-arms-batteries/) | Knowledge | Core structure: batteries, payloads, arms |
| [nock-interpreter-patterns](./skills/nock-interpreter-patterns/) | Knowledge | Design patterns for building Nock VMs |
| [nock-multi-language-implementations](./skills/nock-multi-language-implementations/) | Knowledge | C, Python, Rust, Haskell, JS implementations |
| [nock-jetting-optimization](./skills/nock-jetting-optimization/) | Knowledge | Jet acceleration, cold/hot/warm states |
| [nock-performance-profiling](./skills/nock-performance-profiling/) | Knowledge | CPU/memory profiling, benchmarking |
| [nock-metacircular-evaluation](./skills/nock-metacircular-evaluation/) | Knowledge | Self-interpretation: +mock (Nock-in-Nock) |
| [nock-hoon-compilation](./skills/nock-hoon-compilation/) | Knowledge | How Hoon compiles to Nock |
| [nock-interpreter-engineer-assistant](./skills/nock-interpreter-engineer-assistant/) | Assistant | Build Nock interpreters in multiple languages |
| [nock-optimization-specialist-assistant](./skills/nock-optimization-specialist-assistant/) | Assistant | Optimize Nock performance (10x-1000x) |
| [nock-fundamentals-tutor-assistant](./skills/nock-fundamentals-tutor-assistant/) | Assistant | Educational learning from nouns through cores |
| [build-nock-interpreter-workflow](./skills/build-nock-interpreter-workflow/) | Workflow | Build production-ready interpreters |
| [optimize-nock-performance-workflow](./skills/optimize-nock-performance-workflow/) | Workflow | Systematic optimization: profiling to production |
| [learn-nock-fundamentals-workflow](./skills/learn-nock-fundamentals-workflow/) | Workflow | Interactive 5-phase learning path |
| [debug-nock-execution-workflow](./skills/debug-nock-execution-workflow/) | Workflow | Systematic debugging: error analysis to resolution |
| [hoon-to-nock-workflow](./skills/hoon-to-nock-workflow/) | Workflow | Analyze Hoon compilation output |
| [nock-implement-exercise-workflow](./skills/nock-implement-exercise-workflow/) | Workflow | Hands-on guided exercises |
| [orchestrate-interpreter-workflow](./skills/orchestrate-interpreter-workflow/) | Workflow | Complete Nock mastery orchestration |

## Requirements

Skills are self-contained markdown -- no dependencies for knowledge, assistant, or workflow skills. The two interaction skills require:

- **urbit-conn**: `urbit` binary on PATH, `nc` (netcat) for socket communication
- **urbit-terminal**: `screen` or `tmux` with a ship running in a named session

## Contributing

See [AGENTS.md](AGENTS.md) for a complete guide on creating new skills.

## License

MIT -- see [LICENSE](LICENSE).
