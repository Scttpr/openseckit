# Phase 6: Synthesis

**Phase**: 6 of 7
**Focus**: Cross-validation, gap analysis, and index generation
**Outputs**: `gaps.yaml`, `index.yaml`

---

## Role

You are the **Synthesis Analyst**. Your task is to bring together all discovered information, identify gaps, validate consistency, and prepare the system model for documentation generation.

**Tone**: Holistic, quality-focused. Connect the dots and make knowledge accessible.

---

## Prerequisites

- All previous phases completed (1-5)
- Workflow state shows all phases completed
- All YAML files generated

---

## Template Compliance

**CRITICAL: You MUST follow templates exactly.**

1. **Read templates first** from `.osk/kit/discover/templates/`:
   - `data/index.yaml.j2`
   - `data/gaps.yaml.j2`

2. **Match structure exactly** - do not add or remove fields
3. **Use `null` or `"unknown"`** for missing data - never omit fields
4. **Preserve field order** as defined in templates

---

## Steps

### Step 6.1: Cross-Reference Validation

**Goal**: Ensure consistency across all system model files.

#### Validation Rules

```yaml
validation_rules:
  # Component references must exist
  component_references:
    - source: "data_flows.*.from"
      target: "components.*.id"
      error: "Data flow references non-existent component"

    - source: "data_flows.*.to"
      target: "components.*.id"
      error: "Data flow references non-existent component"

  # Actor references
  actor_references:
    - source: "boundaries.*.allowed_actors"
      target: "actors.*.id"
      error: "Boundary references non-existent actor"

    - source: "user_journeys.*.persona"
      target: "personas.*.id"
      error: "Journey references non-existent persona"

  # Data references
  data_references:
    - source: "data_flows.*.data"
      target: "data_categories.*.fields.*.name"
      error: "Data flow references undocumented data field"

    - source: "controls.*.data_protected"
      target: "data_categories.*.id"
      error: "Control references non-existent data category"

  # Integration references
  integration_references:
    - source: "user_journeys.*.steps.*.integrations"
      target: "integrations.*.id"
      error: "Journey references non-existent integration"
```

#### Validation Report

```
✅ Cross-Reference Validation
==============================

Components (15 total):
✓ All components have unique IDs
✓ All component references valid
⚠️ 2 components not referenced in any data flow

Actors (8 total):
✓ All actors have unique IDs
✓ All actor references valid

Data Categories (12 total):
✓ All categories have unique IDs
⚠️ 3 fields missing classification

Integrations (9 total):
✓ All integrations documented
⚠️ 1 integration missing failure impact

Trust Boundaries (5 total):
✓ All boundaries defined
✓ All zone references valid

Issues Found: 6
- 3 Warning (non-critical)
- 3 Info (suggestions)

View detailed report? [Y/n]
```

---

### Step 6.2: Gap Analysis

**Goal**: Identify missing documentation, security gaps, and improvement opportunities.

#### Gap Categories

```yaml
gap_categories:
  documentation:
    - missing_descriptions
    - outdated_content
    - incomplete_runbooks
    - missing_adrs

  security:
    - unprotected_data_flows
    - missing_controls
    - untested_controls
    - unclassified_data

  operations:
    - missing_monitoring
    - incomplete_runbooks
    - undocumented_procedures
    - missing_ownership

  compliance:
    - unmapped_controls
    - missing_evidence
    - untested_procedures
```

#### Gap Detection Process

```
🔍 Gap Analysis
===============

Documentation Gaps:
⚠️ 5 components missing descriptions
⚠️ 3 APIs without documentation links
⚠️ 2 integrations without contact info
ℹ️ 8 glossary terms could use examples

Security Gaps:
🔴 2 data flows without encryption specification
🔴 1 PII field without access control
⚠️ 4 controls never tested
⚠️ SBOM not integrated into CI pipeline

Operations Gaps:
⚠️ 3 alerts without linked runbooks
⚠️ On-call handoff checklist incomplete
ℹ️ DR procedure last tested > 6 months ago

Compliance Gaps:
⚠️ 12 controls not mapped to framework
ℹ️ Missing GDPR Article 30 records

Total: 3 Critical, 15 High, 8 Medium, 12 Low

Generate remediation plan? [Y/n]
```

#### Gap Structure

```yaml
gap:
  id: "gap-{{ generate_id }}"
  title: "{{ gap_title }}"
  category: "{{ documentation|security|operations|compliance }}"
  severity: "{{ critical|high|medium|low }}"

  description: "{{ detailed_description }}"

  affected:
    files: ["{{ file_list }}"]
    items: ["{{ item_ids }}"]

  impact: "{{ impact_description }}"

  recommendation: "{{ recommendation }}"

  effort: "{{ low|medium|high }}"
  priority: {{ calculated_priority }}

  assigned_to: "{{ team_or_person }}"
  due_date: "{{ suggested_date }}"

  remediation_steps:
    - "{{ step }}"

  references:
    - "{{ relevant_standards }}"
```

---

### Step 6.3: Index Generation

**Goal**: Create the master index file linking all system model components.

#### Index Structure

```yaml
index:
  metadata:
    project: "{{ project_name }}"
    version: "{{ system_model_version }}"
    generated_at: "{{ timestamp }}"
    last_full_discovery: "{{ timestamp }}"
    generator: "OpenSecKit Discover v{{ version }}"
    documentation_language: "{{ language_code }}"  # en|fr|es|de

  sections:
    - file: "product.yaml"
      status: "{{ complete|partial|missing }}"
      last_updated: "{{ timestamp }}"

    - file: "business.yaml"
      status: "{{ status }}"
      last_updated: "{{ timestamp }}"

    # ... all files

  stats:
    components: {{ count }}
    integrations: {{ count }}
    data_categories: {{ count }}
    actors: {{ count }}
    controls: {{ count }}
    apis: {{ count }}
    sbom_components: {{ count }}
    gaps:
      total: {{ count }}
      critical: {{ count }}
      high: {{ count }}

  health:
    overall_score: {{ percentage }}
    documentation_coverage: {{ percentage }}
    security_posture: {{ score }}
    operational_readiness: {{ percentage }}

  audiences:
    - role: "Product Manager"
      relevant_files: ["product.yaml", "business.yaml", "user-journeys.yaml", "glossary.yaml"]
      quick_start: ".osk/docs/product.md"

    - role: "Developer"
      relevant_files: ["architecture.yaml", "glossary.yaml", "integrations.yaml", "tooling.yaml"]
      quick_start: ".osk/docs/developer.md"

    - role: "Security Engineer"
      relevant_files: ["controls.yaml", "boundaries.yaml", "data.yaml", "supply_chain.yaml"]
      quick_start: ".osk/docs/security.md"

    - role: "DevOps/SRE"
      relevant_files: ["operations.yaml", "architecture.yaml", "tooling.yaml"]
      quick_start: ".osk/docs/operations.md"

    - role: "New Team Member"
      relevant_files: ["product.yaml", "glossary.yaml", "team.yaml", "architecture.yaml"]
      quick_start: ".osk/docs/onboarding.md"

    - role: "Architect"
      relevant_files: ["architecture.yaml", "boundaries.yaml", "data.yaml", "integrations.yaml"]
      quick_start: ".osk/docs/architecture.md"
```

---

### Step 6.4: Language Selection

**Goal**: Allow the user to choose the language for generated documentation.

#### Language Selection Prompt

Before generating documentation, present the language options to the user:

```
🌐 Documentation Language Selection
===================================

Please select the language for generated documentation:

  1. English (en) - Default
  2. Français (fr)
  3. Español (es)
  4. Deutsch (de)

Your choice [1-4, default: 1]: ___
```

#### Supported Languages

| Code | Language | Template Suffix |
|------|----------|-----------------|
| `en` | English | (default, no suffix) |
| `fr` | Français | `.fr` |
| `es` | Español | `.es` |
| `de` | Deutsch | `.de` |

#### Store Language Preference

Store the selected language in the workflow state:

```yaml
workflow:
  documentation_language: "{{ selected_language_code }}"  # en|fr|es|de
```

---

### Step 6.5: Handoff to Documentation Phase

**Goal**: Summarize synthesis results and proceed to documentation generation.

#### Synthesis Summary

```
✓ Synthesis Complete
====================

System Model Generated:
├── product.yaml ✓
├── business.yaml ✓
├── glossary.yaml ✓
├── architecture.yaml ✓
├── data.yaml ✓
├── actors.yaml ✓
├── boundaries.yaml ✓
├── user-journeys.yaml ✓
├── integrations.yaml ✓
├── supply_chain.yaml ✓
├── controls.yaml ✓
├── tooling.yaml ✓
├── team.yaml ✓
├── operations.yaml ✓
├── gaps.yaml ✓
└── index.yaml ✓

Gaps Identified: {{ gap_count }}
- Critical: {{ critical_count }}
- High: {{ high_count }}
- Medium: {{ medium_count }}
- Low: {{ low_count }}

Health Score: {{ score }}/100

→ Proceeding to Phase 7: Documentation Generation
```

**After displaying this summary, immediately proceed to Phase 7 (`07-documentation.md`) to generate documentation.**

---

## Output Generation

### YAML Templates

**Use YAML templates from `.osk/kit/discover/templates/data/` (downloaded by fetch script).**

| Output | Template URL |
|--------|--------------|
| `gaps.yaml` | `https://raw.githubusercontent.com/Scttpr/openseckit/main/kit/discover/templates/data/gaps.yaml.j2` |
| `index.yaml` | `https://raw.githubusercontent.com/Scttpr/openseckit/main/kit/discover/templates/data/index.yaml.j2` |

Generate the following files:

### gaps.yaml
- All identified gaps with severity
- Remediation recommendations
- Priority scoring
- Assignment suggestions

### index.yaml
- Master index of all files
- Statistics
- Health scores
- Audience routing

---

## Update Workflow State

```yaml
phases:
  synthesis:
    status: "completed"
    completed_at: "{{ timestamp }}"
    output:
      - "gaps.yaml"
      - "index.yaml"
    result:
      gap_count: {{ count }}
      health_score: {{ score }}

workflow:
  current_phase: "documentation"  # Ready for Phase 7
```

---

## Validation Checklist

- [ ] All cross-references validated
- [ ] Gaps identified and prioritized
- [ ] Index file complete
- [ ] Health score calculated
- [ ] Workflow state updated
- [ ] Ready to proceed to Phase 7

---

## Post-Discovery

After discovery is complete, users can:

1. **Run security workflows**: `/osk-secure` for threat modeling
2. **Run compliance checks**: `/osk-comply` for GDPR/RGS assessment
3. **Update incrementally**: Re-run discover with `--incremental` flag
4. **Generate reports**: `/osk-report` for stakeholder presentations
