---
description: Run autonomous compliance assessment (RGPD or RGS)
part: comply
phase: compliance
---

# /osk-comply <framework>

> Autonomous multi-phase compliance assessment workflow

## Usage

```
/osk-comply rgpd    # RGPD/GDPR compliance assessment
/osk-comply rgs     # RGS compliance assessment (French public sector)
```

## Available Frameworks

| Framework | Description |
|-----------|-------------|
| `rgpd` | RGPD/GDPR - EU data protection regulation |
| `rgs` | RGS - French government security standard |

---

# ORCHESTRATOR INSTRUCTIONS

When this command is invoked with a framework argument, execute the following steps **in order**:

## Step 1: Parse framework argument

Extract the framework name from the command. Valid values: `rgpd`, `rgs`.
If no framework specified or invalid, display usage and stop.

## Step 2: Bootstrap - Auto-fetch framework resources

**CRITICAL: This step is MANDATORY before any workflow execution.**

Check if framework resources exist:
```
.osk/kit/comply/frameworks/<framework>/knowledge/
```

If the directory does NOT exist or is empty:

```bash
# For RGS:
curl -sf https://raw.githubusercontent.com/Scttpr/openseckit/main/kit/comply/frameworks/rgs/scripts/fetch.sh | bash

# For RGPD:
curl -sf https://raw.githubusercontent.com/Scttpr/openseckit/main/kit/comply/frameworks/rgpd/scripts/fetch.sh | bash
```

Display progress:
```
Fetching <framework> resources...
  ✓ knowledge
  ✓ schemas
  ✓ templates
  ✓ prompts
Done!
```

## Step 3: Load framework orchestrator

Read the framework-specific orchestrator prompt:
```
.osk/kit/comply/frameworks/<framework>/prompt.md
```

If the file doesn't exist after fetch, display error and abort.

## Step 4: Execute framework workflow

Follow the instructions in the loaded framework orchestrator prompt to execute the full compliance workflow.

---

## How It Works

Each framework runs an autonomous 5-phase workflow:

1. **Discovery** - Analyze system model for relevant data/controls
2. **Assessment** - Evaluate against framework requirements
3. **Risk Analysis** - Identify gaps and risks
4. **Remediation** - Generate remediation roadmap
5. **Documentation** - Produce compliance artifacts

The workflow maintains state in `.osk/comply/<framework>/workflow-state.yaml` and can be resumed at any point.

## Prerequisites

- System model must exist: `.osk/system-model/index.yaml`
- Run `/osk-discover` first if not present

## Output

```
.osk/comply/<framework>/
├── workflow-state.yaml    # Progress tracking
├── *.yaml                 # Assessment data
└── documents/             # Generated compliance documents
```

## Options

- `--update` - Re-run assessment with updated system model
- `--export <md|pdf>` - Export compliance documentation

---

**Please specify a framework:** `/osk-comply rgpd` or `/osk-comply rgs`
