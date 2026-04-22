# DankBitwarden

A launcher plugin for [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) that integrates Bitwarden password management into the DMS launcher via [rbw](https://github.com/doy/rbw).

## Features

- Search vault entries by name, username, or folder
- Copy password, username, or TOTP code to clipboard
- Context menu for switching between credential fields
- Auto-retry when vault is locked

## Installation

### Nix (flake)

Add as a `flake = false` input and include in your DMS plugin configuration:

```nix
inputs.dms-plugin-bitwarden = {
  url = "github:alcxyz/DankBitwarden";
  flake = false;
};
```

```nix
programs.dank-material-shell.plugins.DankBitwarden = {
  enable = true;
  src = inputs.dms-plugin-bitwarden;
};
```

### Manual

Copy the plugin directory to `~/.config/DankMaterialShell/plugins/DankBitwarden/`.

## Usage

Activate with `@` (default trigger) in the DMS launcher, then:

- `@` — list all vault entries
- `@github` — search for entries matching "github"
- Select an entry to copy the default field (password)
- Right-click for options: copy password, username, or TOTP

## Requirements

- [rbw](https://github.com/doy/rbw) — Bitwarden CLI client (must be configured and unlocked)
- `wl-copy` — Wayland clipboard utility

## License

MIT
