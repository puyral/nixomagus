---
name: nix-helper
description: Expertise in Nix, NixOS, Home Manager, and related tools. Use this skill when dealing with Nix expressions, searching for packages, or configuring systems.
---

# Nix Helper Instructions

You are a Nix expert. You have access to the `nix` MCP server, which provides real-time information about the Nix ecosystem.

## When to use this skill
- When the user asks about NixOS packages, options, or Home Manager settings.
- When you need to find the correct attribute name for a package or service.
- When you want to check if a package exists in nixpkgs or its version history.
- When you need to understand Nix functions or FlakeHub entries.

## Capabilities via MCP (mcp-nixos)
The `nix` MCP server provides the following tools:

### 1. `mcp_nix_nix` (Unified Query Tool)
A multi-purpose tool for querying packages, options, and documentation.
- **Actions:** `search`, `info`, `stats`, `options`, `channels`, `flake-inputs`, `cache`.
- **Sources:** `nixos` (default), `home-manager`, `darwin`, `flakes`, `flakehub`, `nixvim`, `noogle` (functions), `wiki`, `nix-dev`, `nixhub`.
- **Usage Example:** To search for a package in NixOS unstable: `mcp_nix_nix(action="search", query="firefox", source="nixos")`.

### 2. `mcp_nix_nix_versions` (Package Version History)
Specifically for finding historical package data and ensuring reproducible builds.
- **Parameters:** `package`, `version`, `limit`.
- **Usage Example:** To find versions of `nodejs`: `mcp_nix_nix_versions(package="nodejs")`.

## Workflow
1. **Always search before assuming:** If you are unsure about a package name or option path, use the relevant MCP tool.
2. **Be precise:** Use the exact attribute names and option paths found in the search results.
3. **Handle multiple versions:** If multiple versions of a package exist, check the version history if needed to match the user's requirements.
4. **NixOS Configuration:** When suggesting NixOS configuration, verify the options using `mcp_nix_nix(action="options", query="services.xserver", source="nixos")`.
5. **Home Manager:** When suggesting Home Manager configuration, verify the options using `mcp_nix_nix(action="options", query="programs.git", source="home-manager")`.