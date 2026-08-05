---
name: go-diagram
description: Produce a Mermaid diagram for the current Go system from a validated template.
---

# Diagram this Go system

Use the `go-mermaid-diagrams` skill.

1. Ask which view is needed (or infer): architecture, packages, sequence,
   concurrency, state, ERD, CI, upgrade, vulns, performance, etc.
2. Copy the matching template from `skills/go-mermaid-diagrams/assets/templates/`.
3. Replace placeholders with real identifiers from the repo.
4. Lint with `node scripts/mermaid-lint.mjs` before presenting.
