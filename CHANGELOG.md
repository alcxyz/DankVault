# Changelog

All notable changes to this plugin are documented here. The format follows
Keep a Changelog, and the release workflow publishes each version's section
as its GitHub release notes.

## [Unreleased]

## [0.4.1] - 2026-09-20

- Added an optional development-build packaging path: running `scripts/package.py --output dist/dev` now stages a copy of the plugin stamped with an identifiable version like `X.Y.Z-dev.<commit>` (with a `.dirty` suffix for uncommitted changes), so builds installed from a checkout can be told apart from tagged releases. Release packaging still requires a clean checkout at the exact `vX.Y.Z` tag; the tracked `plugin.json` keeps the plain release version.
- Added Nix packaging support (`default.nix`) for building the plugin with an explicit revision.

## [0.4.0] - 2026-09-08

- Fixed 1Password (`op`) backend reads of concealed fields such as passwords: without `--reveal`, `op` returned a redacted placeholder that the plugin copied to the clipboard while still showing a "Copied password" toast, so users appeared to copy their password but actually got a masked string. Non-concealed fields (username) and TOTP were not affected.
- Fixed `pass`/`gopass` entries so that vault paths nested in folders are looked up by their full path instead of by name alone, preventing entries that share a name in different folders from resolving to the wrong secret.
- Vault search results no longer appear when the launcher is used without its trigger key; existing installs get this as a one-time default applied automatically, without overriding a visibility choice already made in settings.

## [0.3.2] - 2026-05-03

- Packaging/tooling only: the plugin version is now sourced solely from `plugin.json`, removing the separate `VERSION` file so CI, the Nix flake, and the test suite can no longer disagree about the current version. No user-facing behavior changed.

## [0.3.1] - 2026-04-23

- Fixed vault entries being fetched as soon as the plugin loaded, which could trigger a password/PIN unlock prompt on every DMS startup even if the launcher was never opened. Entries are now only fetched the first time the vault trigger is used.

## [0.3.0] - 2026-04-23

- Renamed the plugin from DankBitwarden to DankVault to resolve a plugin registry ID collision with another Bitwarden plugin, and broadened it from a Bitwarden-only launcher into a multi-backend password manager plugin.
- Added support for `pass`, `gopass`, and the 1Password CLI (`op`) as additional backends alongside `rbw` (Bitwarden), with auto-detection of whichever supported backend is installed; the backend can also be selected explicitly.
- Added username as a directly copyable field alongside password and TOTP.
- Fixed 1Password CLI field lookups, which require a `label=` prefix on `--fields`, and tightened the username lookup for `pass` so it no longer matches unrelated keys with similar prefixes.
- Added a test suite (26 tests) covering backend output parsing and clipboard security behavior.

## [0.2.0] - 2026-04-22

- Each vault entry now shows separate password and TOTP results in the launcher (with distinct icons) instead of one combined entry, so a field can be copied directly without going through the context menu first.
- Fixed passwords persisting in clipboard history: copying now uses `wl-copy --paste-once --sensitive` and automatically clears the clipboard after 15 seconds if it hasn't been pasted.

## [0.1.0] - 2026-04-22

- Initial release: a DankMaterialShell launcher plugin (then named DankBitwarden) that integrates Bitwarden password management via `rbw`. Activate with the `@` trigger to search vault entries by name, username, or folder, copy the password, username, or TOTP code to the clipboard, and switch between fields from a context menu. Automatically retries when the vault is locked.
