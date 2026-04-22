# ADR-001: Sensitive Clipboard Handling

**Status:** Accepted
**Date:** 2026-04-22
**Applies to:** `DankBitwarden.qml`

## Context

Passwords copied via the Bitwarden plugin were persisted in the Wayland clipboard history (e.g. cliphist), making secrets visible long after use. The clipboard also retained the value indefinitely.

## Decision

Use `wl-copy --paste-once --sensitive` when copying secrets, and clear the clipboard after 15 seconds as a fallback.

- `--paste-once`: clipboard content is served for a single paste, then automatically cleared.
- `--sensitive`: hints to clipboard managers not to store the entry in history.
- `sleep 15 && wl-copy --clear`: safety net that clears the clipboard even if the user doesn't paste.

## Alternatives Considered

- **`--paste-once` only**: Would prevent multi-paste but clipboard managers might still log it without `--sensitive`.
- **`--sensitive` only**: Depends on clipboard manager honoring the hint; without `--paste-once` the value stays available indefinitely.
- **Timer-only clearing**: No protection against clipboard history logging; value visible until timeout.
- **No change**: Unacceptable — passwords should not persist in clipboard history.

## Consequences

- Passwords can only be pasted once after copying. Users who paste into multiple fields need to re-copy.
- Clipboard managers that respect the `sensitive` hint (cliphist does) will not log the entry.
- The 15-second fallback timer ensures cleanup even if the user forgets to paste.
- The toast message now indicates the 15s lifetime so the user knows to paste promptly.
