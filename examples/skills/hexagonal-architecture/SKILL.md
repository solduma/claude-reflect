---
name: hexagonal-architecture
description: The user's principles for hexagonal (ports & adapters) architecture — pure domain core, ports as interfaces, adapters as implementations, dependency inversion pointing inward, and enforcing boundaries with a tool like import-linter rather than convention. Invoke when designing or reviewing the layering of a codebase, deciding where a piece of logic belongs (domain vs application vs adapter), introducing ports/adapters, auditing whether an architecture is real or decorative, or planning an incremental migration toward hexagonal. Language-agnostic principles; consult project memory for any project-specific contracts and directory layout.
---

# Hexagonal Architecture (Ports & Adapters)

Principles for structuring a codebase so business logic is isolated from IO and frameworks. These are universal — a specific project's concrete contracts, directory names, and migration history live in that project's memory, not here.

## The layers (dependencies always point inward)

```
driving adapters  →  application  →  domain (pure)  ←  ports (interfaces)
(routers, CLI,        (services:      (entities,        ↑
 scheduler, TUI)       orchestration)  pure functions)  driven adapters implement ports
                                                          (db, http clients, LLM, storage, queues)
```

- **domain** — pure business logic: entities, value objects, pure functions. **No IO, no framework, no ORM, no `import` of anything outside stdlib + other domain code.** A domain file you can unit-test with plain values is the goal.
- **ports** — interfaces (Protocols/ABCs) the application depends on. Leaf: they import nothing from implementations or upper layers.
- **application (services)** — orchestration and use-cases. Depends on domain + ports, never on concrete adapters directly (ideally receives them injected).
- **adapters** — concrete implementations. *Driven* adapters (persistence, HTTP clients, LLM, storage) implement ports. *Driving* adapters (HTTP routers, CLI, scheduler, TUI) call the application.

## Core rules

1. **Dependency inversion**: upper layers depend on abstractions (ports), not concretions. The domain never reaches outward.
2. **Domain purity is non-negotiable**: if a "domain" file imports `requests`/an ORM/a framework, it isn't domain — it's an adapter or service in disguise.
3. **Driving adapters are thin edges**: routers assemble DTOs and delegate; they hold no business logic and no direct data access. Scoring/decisions belong in domain, orchestration in services.
4. **One concern per adapter**: external IO and persistence live behind adapters, not scattered through services.
5. **Substitutability is the point of a port**: a port only earns its keep if something can be swapped for it — an injected fake in tests, or a second real adapter. A port with a single hardcoded implementation and no injection is *decorative*, not real.

## Enforce boundaries with a tool, not vigilance

Layer discipline erodes without a checker. Use **import-linter** (Python) or an equivalent to encode contracts and run them in the pre-commit hook + CI:

- `layers`: declare the order (e.g. routers > services > adapters > db) so upward imports fail the build.
- `forbidden`: keep domain/ports as pure leaves (forbid them importing IO packages).
- A **capstone contract** that forbids the exact leak you care about (e.g. routers importing ORM models directly) is worth more than ten aspirational ones. Prove a contract works by injecting a violation and watching it break.

**"Contracts pass" ≠ "architecture is sound."** Layer contracts catch direction, not decorative ports. Audit separately for: ports with zero injection, "adapters" that are just moved files with no interface, and domain logic still hiding in routers/services.

## Migrating an existing layered codebase

Incremental beats big-bang:

1. **Freeze the current boundaries first** with a green import-linter baseline (contracts that already pass), so nothing regresses while you refactor.
2. Extract **pure domain** first (scoring, calculations, policy) using explicit primitive signatures — not ORM duck-typing.
3. Introduce **ports + adapters** for the highest-churn / most-mockable external dependency first (usually the DB or the LLM).
4. Push **driving adapters** (routers) down to delegation last, capped by a no-ORM-in-routers contract.
5. Verify behavior is unchanged at each step (e.g. large random-input diff tests against the pre-refactor implementation).

## Example (reporter)

reporter (`api/app`) is a live instance: `domain/` (pure scoring/technicals/financials), `ports/` (repository + market-data Protocols), `adapters/` (persistence/market/dart/external/realtime/storage), `services/` (application), `routers/` (driving). Boundaries are enforced by import-linter contracts. Its specific contract set, directory map, migration steps, and remaining gaps (e.g. port DI still hardcoded, LLMPort not yet extracted) are recorded in **reporter project memory** — read that before working on reporter's architecture.
