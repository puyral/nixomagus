# Emacs Home Manager Module

This module provides Emacs with ProofGeneral support and optional Squirrel prover integration.

## Options

Located at `config.extra.emacs.*`

- `enable`: Enable Emacs with ProofGeneral
- `extensions`: Additional emacs packages from nixpkgs (list)
- `squirrel.enable`: Enable Squirrel prover emacs integration

## Usage

Add to your Home Manager configuration (e.g., `users/<user>/<computer>/default.nix`):

```nix
{
  extra.emacs = {
    enable = true;
    squirrel.enable = true;  # Optional, off by default
    extensions = [           # Optional, additional packages
      pkgs.emacsPackages.magit
    ];
  };
}
```

## What It Does

When enabled (`extra.emacs.enable = true`):
- Installs Emacs
- Installs ProofGeneral package
- Copies `squirrel.el` and `squirrel-syntax.el` to `~/.emacs.d/lisp/PG/squirrel/` (files available regardless)

When `squirrel.enable = true`:
- Creates `~/.emacs.d/init.el` with:
  - ProofGeneral loading
  - Squirrel mode configuration

## Files Installed

- `~/.emacs.d/lisp/PG/squirrel/squirrel.el`
- `~/.emacs.d/lisp/PG/squirrel/squirrel-syntax.el`
- `~/.emacs.d/init.el` (if squirrel enabled)

## Squirrel Setup

After enabling `squirrel.enable`, ensure `squirrel` prover is in your PATH:

```bash
export PATH=$PATH:/path/to/squirrel
emacs examples/<file>.sp
```

Files are sourced from the `squirrel-prover-src` input defined in `flake.nix`.