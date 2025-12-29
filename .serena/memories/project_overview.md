# Project Overview

## Purpose

Nix configuration repository for macOS that manages system and user environments declaratively.

## Tech Stack

- **nix-darwin**: System-level macOS configurations
- **home-manager**: User-specific configurations
- **Nix Flakes**: Reproducible dependency management

## Target System

- Platform: aarch64-darwin (Apple Silicon Mac)
- Hostname: Mac-big
- User: naitokosuke

## Directory Structure

- `flake.nix`: Entry point with package lists and system settings
- `nix-darwin/`: System-level macOS settings (dock, finder, cursor, etc.)
- `home-manager/`: User-specific configurations (git, zsh, ghostty, vscode, etc.)
