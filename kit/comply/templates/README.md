# Comply Templates

Jinja2 templates for compliance reporting.

## Structure

```
templates/
├── data/
│   └── assessment.yaml.j2    # Generic assessment data template
└── reports/
    └── compliance-summary.j2  # Multi-framework summary report
```

## Framework-Specific Templates

Each framework has its own templates in `frameworks/<name>/templates/`:

- **RGPD**: AIPD, processing register, gap reports, privacy policy
- **RGS**: Homologation checklist, system perimeter, export dossier

## Usage

Templates are rendered by comply workflow prompts using data from:
- `.osk/system-model/` (system context)
- `.osk/comply/<framework>/` (assessment data)

See [Jinja2 documentation](https://jinja.palletsprojects.com/) for template syntax.
