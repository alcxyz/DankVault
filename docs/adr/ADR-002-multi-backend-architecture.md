# ADR-002: Multi-Backend Architecture

**Status:** Accepted
**Date:** 2026-04-22
**Applies to:** `DankVault.qml`

## Context

DankVault (formerly DankBitwarden) was hardcoded to use rbw as its only
password manager backend. Users of pass, gopass, or 1Password CLI could
not use the plugin. Renaming to DankVault also resolves a plugin registry
ID collision with pacman99's DankBitwarden plugin.

## Decision

Backends are defined as plain JS objects in an inline registry map
(`_backends`) inside DankVault.qml. Each backend provides:

- `listCommand()` — returns the command array to list entries
- `parseListOutput(text)` — parses stdout into `[{name, user, folder}]`
- `getFieldCommand(entryName, entryUser, fieldName)` — returns the
  command array to retrieve a specific field

The shared `listProcess` and `copyFieldProcess` Process objects execute
whatever command the active backend provides. This keeps all Process
objects as direct children of the root QtObject, matching the DMS plugin
convention.

Auto-detection runs `command -v` against each supported binary in
priority order (rbw, pass, gopass, op) and selects the first available.
A settings override lets users force a specific backend.

## Alternatives Considered

- **Separate .js library files**: QML supports `.pragma library` JS, but
  no DMS plugin uses this pattern, JS files cannot instantiate QML types,
  and it adds an untested loading path in Quickshell.
- **Separate QML component per backend**: More conventional OOP but DMS
  expects a single component entry point, and the indirection adds
  complexity for 3-4 backends.
- **Plugin-per-backend**: Would require users to install a different
  plugin per password manager and duplicates all shared code.

## Consequences

- Adding a new backend is a single addition to the `_backends` map
  plus a settings dropdown entry.
- Backend-specific parsing bugs are isolated to their `parseListOutput`.
- The Process objects are reused; only one list or copy operation runs
  at a time (unchanged from prior behavior).
- The `requires` field in plugin.json lists only `wl-copy` since backend
  CLIs are alternatives, not hard dependencies.
