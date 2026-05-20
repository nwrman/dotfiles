@echo off
:: pbpaste — print the Windows clipboard to stdout.
:: Mirrors the macOS/Linux shim in home/.zsh/linux.zsh for cross-machine parity.
powershell -NoProfile -Command "Get-Clipboard"
