# OpenSecKit

Security workflows for AI coding assistants.

## Install

```bash
curl -sf https://raw.githubusercontent.com/Scttpr/openseckit/main/init.sh | bash
```

## Commands

| Command | Description |
|---------|-------------|
| `/osk-discover` | Build system model from codebase |
| `/osk-comply rgpd` | RGPD/GDPR compliance assessment |
| `/osk-comply rgs` | RGS compliance assessment |
| `/osk-secure-specify <feature>` | Security spec with STRIDE threats |
| `/osk-secure-plan <feature>` | Implementation plan |
| `/osk-secure-tasks <feature>` | Sprint-ready tasks |

## Workflow

```
/osk-discover  →  /osk-comply    (compliance)
                  /osk-secure-*  (feature security)
```
