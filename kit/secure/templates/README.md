# Secure Templates

Jinja2 templates for generating security documentation and data files.

## Structure

```
templates/
├── data/           # YAML data output templates
│   └── risks.yaml.j2
└── outputs/        # Markdown report templates
    ├── security-spec.md.j2
    ├── security-plan.md.j2
    ├── security-tests.md.j2
    └── risks.md.j2
```

## Usage

Templates are rendered by the secure workflow prompts using data from:
- `.osk/system-model/` (system context)
- `.osk/specs/<feature>/` (feature-specific data)

See [Jinja2 documentation](https://jinja.palletsprojects.com/) for template syntax.
