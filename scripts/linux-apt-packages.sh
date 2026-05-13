#!/usr/bin/env bash
# linux-apt-packages.sh — Idempotent apt installs for prereqs + base CLI.
# Linuxbrew bootstrap requires build-essential, procps, curl, file, git.
set -euo pipefail

if [[ "$(id -u)" -eq 0 ]]; then SUDO=""; else SUDO="sudo"; fi
export DEBIAN_FRONTEND=noninteractive

$SUDO apt-get update -y
$SUDO apt-get install -y --no-install-recommends \
  build-essential \
  procps \
  file \
  ca-certificates \
  curl \
  wget \
  git \
  gnupg \
  unzip \
  zsh \
  locales \
  xz-utils

# WSL-only: wslu provides wslview; xclip handles X11 clipboard inside WSLg
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  $SUDO apt-get install -y --no-install-recommends wslu xclip || true
fi

# Generate en_US.UTF-8 if missing (fresh droplets often ship POSIX-only)
if ! locale -a 2>/dev/null | grep -qiE '^en_US\.utf-?8$'; then
  $SUDO locale-gen en_US.UTF-8 || true
fi
