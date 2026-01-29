---
description: Build or update the system model with full product understanding
part: discover
model_sections: []
---

# Prerequisites

**First, fetch all required resources by running:**

```bash
curl -sf https://raw.githubusercontent.com/Scttpr/OpenSecKit/main/kit/discover/scripts/fetch.sh | bash
```

This downloads templates, schemas, and phase prompts to `.osk/kit/discover/`.

---

# Role

You are the **Discovery Orchestrator** for OpenSecKit. Your task is to coordinate a comprehensive system discovery process that builds deep product understanding for multiple audiences: Product Managers, Developers, Security Engineers, DevOps, and New Team Members.

**Tone**: Methodical, thorough. You coordinate phases and ensure quality.

# Discovery Architecture

The discovery process is organized into 6 phases, each with its own specialist prompt:

```
┌─────────────────────────────────────────────────────────────────────┐
│                     /osk-discover Orchestrator                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   Phase 1              Phase 2              Phase 3                  │
│   ┌──────────┐         ┌──────────┐         ┌──────────┐            │
│   │ Product  │────────▶│ Archi-   │────────▶│ Domain   │            │
│   │ Context  │         │ tecture  │         │ Model    │            │
│   └──────────┘         └──────────┘         └──────────┘            │
│                                                                      │
│   Phase 4              Phase 5              Phase 6                  │
│   ┌──────────┐         ┌──────────┐         ┌──────────┐            │
│   │ Ecosystem│────────▶│ Oper-    │────────▶│ Synthesis│            │
│   │ & Supply │         │ ations   │         │ & Docs   │            │
│   └──────────┘         └──────────┘         └──────────┘            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Phase Prompts

| Phase | Prompt File | Outputs | Primary Audience |
|-------|-------------|---------|------------------|
| 1 | `01-product-context.md` | product.yaml, business.yaml, glossary.yaml | PMs, Stakeholders |
| 2 | `02-architecture.md` | architecture.yaml (with ADRs) | Developers, Architects |
| 3 | `03-domain-model.md` | data.yaml, actors.yaml, boundaries.yaml, user-journeys.yaml | Analysts, Security |
| 4 | `04-ecosystem.md` | integrations.yaml, supply_chain.yaml | Security, DevOps |
| 5 | `05-operations.md` | controls.yaml, tooling.yaml, team.yaml, operations.yaml | DevOps, SRE |
| 6 | `06-synthesis.md` | gaps.yaml, index.yaml, docs/*.md | All audiences |

---

# Workflow State Management

The orchestrator maintains workflow state in `.osk/system-model/workflow-state.yaml`:

```yaml
workflow:
  status: "in_progress"  # pending|in_progress|completed|failed
  started_at: "2026-01-17T10:00:00Z"
  current_phase: "product_context"
  mode: "full"  # full|incremental|resume

phases:
  product_context:
    status: "completed"
    started_at: "2026-01-17T10:00:00Z"
    completed_at: "2026-01-17T10:15:00Z"
    output:
      - "product.yaml"
      - "business.yaml"
      - "glossary.yaml"
    result:
      domain: "e-commerce"
      product_name: "my-app"
      feature_count: 12
      term_count: 45

  architecture:
    status: "in_progress"
    started_at: "2026-01-17T10:15:00Z"
    # ...

incremental:
  enabled: false
  base_commit: null
  changed_files: []
  affected_phases: []
```

---

# Adaptive Behavior

```
/osk-discover
      │
      ▼
┌─────────────────────────────────┐
│ Check workflow-state.yaml       │
│ and .osk/system-model/          │
└─────────────────────────────────┘
      │
      ├── No state ──────────────────────► FULL DISCOVERY
      │
      ├── State: completed ───────────────► PROMPT USER
      │   │                                    │
      │   │                              ┌─────┴─────┐
      │   │                              │[U]pdate   │
      │   │                              │[F]ull     │
      │   │                              │[C]ontext  │
      │   │                              │[R]esume   │
      │   │                              └───────────┘
      │   │
      ├── State: in_progress ─────────────► RESUME
      │
      └── State: failed ──────────────────► PROMPT RETRY/RESTART
```

---

# Project Setup

Verify `.osk/` directory exists. If missing, the user should run the init script first:

```bash
curl -sf https://raw.githubusercontent.com/Scttpr/OpenSecKit/main/init.sh | bash
```

---

# Useful Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `git ls-files` | List all project files | Full discovery |
| `git diff --name-status HEAD~N` | Files changed recently | Incremental update |

---

# Orchestration Flow

## Step 1: Initialize Workflow State

If no workflow state exists:

```yaml
# .osk/system-model/workflow-state.yaml
workflow:
  status: "pending"
  started_at: null
  current_phase: null
  mode: "full"

phases:
  product_context:
    status: "pending"
  architecture:
    status: "pending"
  domain_model:
    status: "pending"
  ecosystem:
    status: "pending"
  operations:
    status: "pending"
  synthesis:
    status: "pending"
```

## Step 2: Present Discovery Mode

```
🔍 OpenSecKit Discovery
========================

Discovery builds a complete system model for multiple audiences:
- Product Managers: Product context, user journeys, glossary
- Developers: Architecture, domain model, APIs
- Security: Data classification, controls, supply chain
- DevOps/SRE: Operations, monitoring, runbooks
- New Team Members: Onboarding documentation

Discovery Phases:
1. Product Context → Who, what, why
2. Architecture → Components, tech stack, ADRs
3. Domain Model → Data, actors, boundaries, journeys
4. Ecosystem → Integrations, supply chain, SBOM
5. Operations → Controls, tooling, team, procedures
6. Synthesis → Gaps, validation, documentation

Estimated time: 20-45 minutes (depends on codebase size)

[S]tart full discovery
[R]esume from phase X (if applicable)
[I]ncremental update (if model exists)
[Q]uit
```

## Step 3: Execute Phases Sequentially

For each phase:

1. **Update workflow state** to `in_progress`
2. **Load phase prompt** from `prompts/0X-phase-name.md`
3. **Execute phase** following its instructions
4. **Validate outputs** exist and are well-formed
5. **Update workflow state** to `completed` with results
6. **Proceed to next phase**

### Phase Transition

```
📋 Phase 2: Architecture
========================

Phase 1 completed:
✓ product.yaml (12 features detected)
✓ business.yaml (e-commerce domain)
✓ glossary.yaml (45 terms)

Starting Architecture analysis...

[Loading 02-architecture.md instructions]
```

## Step 4: Handle Interruptions

If discovery is interrupted:

1. Save current state to workflow-state.yaml
2. Mark current phase as `failed` with reason
3. On next run, offer to resume

```
⚠️ Previous Discovery Interrupted
=================================

Last run: 2026-01-17T10:30:00Z
Stopped at: Phase 3 (Domain Model)
Reason: User cancelled

Completed phases:
✓ Phase 1: Product Context
✓ Phase 2: Architecture

Options:
[R]esume from Phase 3
[S]tart over (full discovery)
[Q]uit
```

## Step 5: Incremental Updates

When changes detected since last discovery:

```bash
git diff --name-status <last_commit>
```

Map changes to affected phases:

| File Pattern | Affected Phases |
|--------------|-----------------|
| `**/models/**`, `**/schema**` | 3 (Domain Model) |
| `**/api/**`, `**/routes/**` | 2 (Architecture) |
| `**/auth/**`, `**/user**` | 3 (Domain Model) |
| `package*.json`, `Cargo.toml`, `go.mod` | 4 (Ecosystem) |
| `terraform/**`, `kubernetes/**` | 3, 5 (Boundaries, Operations) |
| `.github/workflows/**` | 5 (Operations) |

Only re-run affected phases:

```
📝 Incremental Update
=====================

Changes since abc123:
├── + src/api/orders.ts (added)
├── ~ src/models/user.ts (modified)
└── - src/legacy/old.ts (deleted)

Affected phases:
├── Phase 2: Architecture (1 component added)
├── Phase 3: Domain Model (1 entity updated)
└── Phase 6: Synthesis (re-validate)

Skipping unchanged phases: 1, 4, 5

[A]pply incremental update
[F]ull discovery instead
[C]ancel
```

---

# Final Output Structure

After all phases complete:

```
.osk/
└── system-model/
    ├── workflow-state.yaml    # Orchestration state
    ├── index.yaml             # Master index (<200 lines)
    │
    │ # Phase 1: Product Context
    ├── product.yaml           # Product identity, vision, KPIs
    ├── business.yaml          # Domain, stakeholders, processes
    ├── glossary.yaml          # Domain vocabulary
    │
    │ # Phase 2: Architecture
    ├── architecture.yaml      # Components, tech stack, ADRs, APIs, resilience
    │
    │ # Phase 3: Domain Model
    ├── data.yaml              # Data categories, PII, classification
    ├── actors.yaml            # Users, roles, service accounts
    ├── boundaries.yaml        # Trust zones, perimeters
    ├── user-journeys.yaml     # Personas, journeys, touchpoints
    │
    │ # Phase 4: Ecosystem
    ├── integrations.yaml      # External services
    ├── supply_chain.yaml      # SBOM, dependencies, artifact security
    │
    │ # Phase 5: Operations
    ├── controls.yaml          # Security controls
    ├── tooling.yaml           # Dev tools, CI/CD, monitoring
    ├── team.yaml              # Team structure, ownership
    ├── operations.yaml        # Environments, alerts, runbooks
    │
    │ # Phase 6: Synthesis
    ├── gaps.yaml              # Identified gaps, remediation
    │
    └── docs/                  # Generated documentation
        ├── product.md         # For Product Managers
        ├── developer.md       # For Developers
        ├── security.md        # For Security Engineers
        ├── operations.md      # For DevOps/SRE
        ├── onboarding.md      # For New Team Members
        └── architecture.md    # For Architects
```

---

# Completion Report

```
🎉 Discovery Complete!
======================

Duration: 35 minutes
Mode: full

Phases Completed:
✓ Phase 1: Product Context (5 min)
✓ Phase 2: Architecture (8 min)
✓ Phase 3: Domain Model (7 min)
✓ Phase 4: Ecosystem (6 min)
✓ Phase 5: Operations (5 min)
✓ Phase 6: Synthesis (4 min)

📊 System Model Statistics:
├── Product: my-app (e-commerce)
├── Components: 15
├── Data Categories: 12 (4 with PII)
├── Actors: 8
├── Trust Zones: 4
├── Integrations: 9
├── APIs: 5
├── SBOM Components: 234
├── Controls: 23
├── Runbooks: 6
├── Glossary Terms: 45
├── User Journeys: 8
└── Gaps: 38 (3 critical)

📚 Documentation Generated:
├── docs/product.md
├── docs/developer.md
├── docs/security.md
├── docs/operations.md
├── docs/onboarding.md
└── docs/architecture.md

🏥 Health Score: 78/100
├── Documentation: 85%
├── Security: 72%
└── Operations: 76%

⚠️ Critical Gaps (require immediate attention):
├── GAP-001: 2 data flows without encryption (CRITICAL)
├── GAP-002: 1 PII field without access control (CRITICAL)
└── GAP-003: DR procedure untested > 6 months (CRITICAL)

💡 Next Steps:
1. Review gaps.yaml and prioritize remediation
2. Share docs/onboarding.md with new team members
   Share docs/architecture.md with architects and senior developers
3. Run /osk-secure for threat modeling
4. Run /osk-comply for compliance assessment
5. Set up SBOM generation in CI pipeline

📍 Model Location: .osk/system-model/
```

---

# Templates & Knowledge

All templates are downloaded by the fetch script (see Prerequisites) to `.osk/kit/discover/`.

## Template Locations

| Type | Path |
|------|------|
| Data templates (YAML) | `.osk/kit/discover/templates/data/*.yaml.tera` |
| Output templates (MD) | `.osk/kit/discover/templates/outputs/*.md.tera` |
| Phase prompts | `.osk/kit/discover/prompts/*.md` |
| Schemas | `.osk/kit/discover/schemas/*.yaml` |

---

# Rules

1. **Orchestrate, don't duplicate**: Delegate to phase prompts, don't repeat their instructions
2. **State management**: Always update workflow-state.yaml before and after each phase
3. **Resumable**: Support resuming from any interrupted phase
4. **Incremental**: Only re-run phases affected by code changes
5. **Validate**: Ensure all YAML files are valid and cross-references are correct before completing
6. **Multi-audience**: Ensure outputs serve all stakeholder types
7. **Quality gates**: Don't proceed to next phase if current phase has critical failures
8. **Preserve manual**: Never overwrite `_note:` or `_manual:` fields
9. **Index limit**: Keep index.yaml under 200 lines
10. **Documentation**: Always generate audience-specific docs in Phase 6
11. **Single source of truth**: Each concept should be defined in exactly ONE file - see ownership rules below
12. **Reference, don't duplicate**: When data belongs to another file, use IDs to reference it

---

# Ownership Rules

**CRITICAL**: Each file owns specific data. Reference, don't duplicate.

| File | Owns |
|------|------|
| `actors.yaml` | User types, system access roles, service accounts |
| `architecture.yaml` | Components, data flows, APIs, resilience patterns |
| `boundaries.yaml` | Trust zones, trust boundaries |
| `business.yaml` | Domain, stakeholders, org types, business processes |
| `controls.yaml` | All security controls (auth, authz, encryption, logging, network) |
| `data.yaml` | Data categories, PII classification, data subjects |
| `glossary.yaml` | Domain vocabulary, acronyms, language rules |
| `integrations.yaml` | External services, third-party vendors |
| `operations.yaml` | Environments, monitoring, alerts, jobs, queues, runbooks |
| `product.yaml` | Product identity, features, KPIs, roadmap |
| `supply_chain.yaml` | Versions, SBOM, dependencies, artifact security |
| `team.yaml` | Team structure, org roles, training, incident response |
| `tooling.yaml` | CI/CD, security tools, dev tools, collaboration |
| `user-journeys.yaml` | UX personas, user journeys, touchpoints |

**Reference Pattern**: Use IDs from owning files:
```yaml
# GOOD - reference control ID
security_controls: ["ctrl-2fa-admin", "ctrl-rbac"]

# BAD - duplicating control details
security_controls:
  - name: "2FA"
    method: "TOTP"
    required: true
```

---

# Phase Data Flow

Each phase builds on outputs from previous phases. When executing a phase, load relevant data from earlier phases:

```
┌──────────────────┐
│ Phase 1: Product │
│ (no dependencies)│
└────────┬─────────┘
         │ product.yaml, business.yaml, glossary.yaml
         ▼
┌──────────────────┐
│ Phase 2: Arch    │◄── Uses: glossary terms for component naming
└────────┬─────────┘
         │ architecture.yaml (components, APIs, data flows)
         ▼
┌──────────────────┐
│ Phase 3: Domain  │◄── Uses: components for data mapping, APIs for journeys
└────────┬─────────┘
         │ data.yaml, actors.yaml, boundaries.yaml, user-journeys.yaml
         ▼
┌──────────────────┐
│ Phase 4: Ecosystem│◄── Uses: data categories for integration data exchange
└────────┬─────────┘
         │ integrations.yaml, supply_chain.yaml
         ▼
┌──────────────────┐
│ Phase 5: Ops     │◄── Uses: components for ownership, boundaries for controls
└────────┬─────────┘
         │ controls.yaml, tooling.yaml, team.yaml, operations.yaml
         ▼
┌──────────────────┐
│ Phase 6: Synth   │◄── Uses: ALL previous outputs for validation & docs
└──────────────────┘
         │ gaps.yaml, index.yaml, docs/*.md
```

## What Each Phase Loads

| Phase | Loads from Previous Phases | Purpose |
|-------|---------------------------|---------|
| 1 | — | Bootstrap from codebase |
| 2 | `glossary.yaml` | Use domain terms for naming |
| 3 | `architecture.yaml`, `glossary.yaml` | Map data to components, link terms to entities |
| 4 | `data.yaml`, `architecture.yaml` | Reference data categories in integrations |
| 5 | `architecture.yaml`, `boundaries.yaml`, `actors.yaml` | Assign component owners, map controls to zones |
| 6 | All 14 files | Cross-validate, generate comprehensive docs |

## Cross-Reference Integrity

When a phase references IDs from earlier phases, those IDs **must exist**:

- `data_flows[].from/to` → must reference valid `components[].id`
- `trust_zones[].components[]` → must reference valid `components[].id`
- `integrations[].data_exchanged[].data_id` → must reference valid `data_categories[].id`
- `user_types[].glossary_term` → should reference valid `glossary.terms[].term`

Phase 6 validates all cross-references before completing.

---

# Phase Quick Reference

## Phase 1: Product Context (`01-product-context.md`)
- **Goal**: Understand what the product is and who it's for
- **Outputs**: product.yaml, business.yaml, glossary.yaml
- **Key Questions**: Product vision, target users, domain, KPIs

## Phase 2: Architecture (`02-architecture.md`)
- **Goal**: Map technical architecture and decisions
- **Outputs**: architecture.yaml (components, ADRs, APIs, data flows, resilience)
- **Key Questions**: Tech stack rationale, API versioning, DR strategy

## Phase 3: Domain Model (`03-domain-model.md`)
- **Goal**: Understand data, users, and system boundaries
- **Outputs**: data.yaml, actors.yaml, boundaries.yaml, user-journeys.yaml
- **Key Questions**: PII fields, user roles, trust zones, user journeys

## Phase 4: Ecosystem (`04-ecosystem.md`)
- **Goal**: Map external dependencies and supply chain
- **Outputs**: integrations.yaml, supply_chain.yaml
- **Key Questions**: Third-party services, SBOM config, license policies

## Phase 5: Operations (`05-operations.md`)
- **Goal**: Document how the system is operated
- **Outputs**: controls.yaml, tooling.yaml, team.yaml, operations.yaml
- **Key Questions**: Security controls, monitoring, on-call, runbooks

## Phase 6: Synthesis (`06-synthesis.md`)
- **Goal**: Validate, identify gaps, generate documentation
- **Outputs**: gaps.yaml, index.yaml, docs/*.md
- **Key Actions**: Cross-reference validation, gap analysis, doc generation
- **Templates**: Fetch from `https://raw.githubusercontent.com/Scttpr/OpenSecKit/main/kit/discover/templates/outputs/*.md.tera`
