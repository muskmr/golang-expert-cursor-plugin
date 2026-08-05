---
name: go-analyze
description: Analyse the current Go module - layout, health, deps, vulns and architecture summary.
---

# Analyse this Go project

Use the `go-project-analysis` skill end-to-end on the workspace.

1. Locate `go.mod` / `go.work` and classify the layout.
2. Run `scripts/go-audit.sh`, `scripts/go-deps.sh` and `scripts/go-vuln.sh`.
3. Produce the analysis report skeleton from the skill.
4. Attach Mermaid diagrams (`layered-packages`, `package-dependency-graph`,
   and `service-architecture` when applicable) using the validated templates.
