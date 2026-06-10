# Constraint

## Role Boundary

The controlled Codex executes the assigned task. The main Codex supervises and verifies.

## Forbidden Actions

List actions the controlled Codex must not take. Write "none" if there are no task-specific forbidden actions.

## Self-Check Rules

Before each meaningful action, the controlled Codex checks:

- Does the action serve `control/goal.md`?
- Does the action violate this constraint file?
- Will the action produce or improve observable evidence?

After each meaningful action, the controlled Codex checks:

- Was progress evidence updated or made visible?
- Is the task complete under `control/goal.md`?
- Is a correction from the main Codex needed before continuing?

