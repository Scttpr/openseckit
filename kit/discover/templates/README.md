# Discover Templates

Jinja2 templates for generating system model and documentation.

## Structure

```
templates/
├── data/           # YAML data templates (16 files)
│   ├── index.yaml.j2
│   ├── business.yaml.j2
│   ├── product.yaml.j2
│   ├── glossary.yaml.j2
│   ├── architecture.yaml.j2
│   ├── data.yaml.j2
│   ├── actors.yaml.j2
│   ├── user-journeys.yaml.j2
│   ├── boundaries.yaml.j2
│   ├── integrations.yaml.j2
│   ├── controls.yaml.j2
│   ├── tooling.yaml.j2
│   ├── team.yaml.j2
│   ├── operations.yaml.j2
│   ├── supply_chain.yaml.j2
│   └── gaps.yaml.j2
└── outputs/        # Markdown documentation templates (6 files)
    ├── product.md.j2         # Product overview (for PMs, stakeholders)
    ├── developer.md.j2       # Developer guide (for developers)
    ├── architecture.md.j2    # Architecture guide (for architects)
    ├── security.md.j2        # Security overview (for security team)
    ├── operations.md.j2      # Operations handbook (for DevOps/SRE)
    └── onboarding.md.j2      # New team member guide
```

## Output Locations

### System Model (`.osk/system-model/`)

YAML files describing the discovered system:

| Template | Output | Purpose |
|----------|--------|---------|
| `index.yaml.j2` | `index.yaml` | Overview, metadata, statistics |
| `business.yaml.j2` | `business.yaml` | Business context, objectives |
| `product.yaml.j2` | `product.yaml` | Product identity, features, KPIs |
| `glossary.yaml.j2` | `glossary.yaml` | Domain terms, acronyms |
| `architecture.yaml.j2` | `architecture.yaml` | Components, APIs, data flows |
| `data.yaml.j2` | `data.yaml` | Data inventory, classification |
| `actors.yaml.j2` | `actors.yaml` | Users, roles, service accounts |
| `user-journeys.yaml.j2` | `user-journeys.yaml` | Personas, journeys, touchpoints |
| `boundaries.yaml.j2` | `boundaries.yaml` | Trust zones, boundaries |
| `integrations.yaml.j2` | `integrations.yaml` | External services, DPA status |
| `controls.yaml.j2` | `controls.yaml` | Security controls |
| `tooling.yaml.j2` | `tooling.yaml` | CI/CD, security tools |
| `team.yaml.j2` | `team.yaml` | Team structure, contacts |
| `operations.yaml.j2` | `operations.yaml` | Environments, runbooks, alerts |
| `supply_chain.yaml.j2` | `supply_chain.yaml` | SBOM, dependency policies |
| `gaps.yaml.j2` | `gaps.yaml` | Identified gaps |

### Documentation (`docs/`)

Markdown documentation for different audiences:

| Template | Output | Audience |
|----------|--------|----------|
| `product.md.j2` | `product.md` | Product Managers, stakeholders |
| `developer.md.j2` | `developer.md` | Developers |
| `architecture.md.j2` | `architecture.md` | Architects, senior developers |
| `security.md.j2` | `security.md` | Security team |
| `operations.md.j2` | `operations.md` | DevOps, SRE |
| `onboarding.md.j2` | `onboarding.md` | New team members |

Each document includes:
- **Dashboard** - Key metrics summary at the top
- **Complete content** - All relevant data from YAML files

## Template Syntax

See [Jinja2 documentation](https://jinja.palletsprojects.com/) for template syntax.

### Common Patterns

```jinja2
{# Iteration #}
{% for item in items %}
- {{ item.name }}
{% endfor %}

{# Conditionals #}
{% if value %}Yes{% else %}No{% endif %}

{# Default values #}
{{ field | default(value="Not specified") }}

{# Filters #}
{{ list | join(sep=", ") }}
{{ text | truncate(length=50) }}
{{ date | date(format="%Y-%m-%d") }}
```
