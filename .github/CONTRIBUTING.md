# Contributing

## Setup

```bash
git clone https://github.com/Scttpr/openseckit.git
cd OpenSecKit
git config core.hooksPath .githooks
```

## Structure

```
init.sh                                  # Entry point (downloads slash commands)
ingest.sh                                # Export project context
kit/
├── discover/
│   ├── prompts/                         # Discovery prompts
│   ├── templates/                       # YAML/MD templates
│   └── scripts/fetch.sh                 # Fetch discover resources
├── comply/
│   ├── prompts/                         # Comply orchestrator
│   └── frameworks/
│       ├── rgpd/                        # RGPD (knowledge, templates, scripts/)
│       └── rgs/                         # RGS (knowledge, templates, scripts/)
└── secure/
    ├── prompts/                         # Security prompts
    ├── knowledge/principles/            # 7 security principles
    └── scripts/fetch.sh                 # Fetch secure resources
```

## Adding a Prompt

1. Create `.md` file in appropriate `kit/*/prompts/` folder
2. Add frontmatter:
   ```yaml
   ---
   description: Short description
   part: discover|comply|secure
   ---
   ```
3. Add to `init.sh` commands array if it's a slash command
4. Test: `./init.sh`

## Pull Requests

1. Fork & branch: `git checkout -b feat/my-feature`
2. Use [conventional commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`
3. Push & open PR

## Questions

Open an [issue](https://github.com/Scttpr/openseckit/issues).
