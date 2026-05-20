-- _dotfiles.lua — Clink configuration for cmd.exe.
-- Deployed to %LOCALAPPDATA%\clink\_dotfiles.lua by windows/bootstrap.ps1.
-- Loaded automatically by Clink on every cmd startup (underscore prefix => early load).

-- ---------------------------------------------------------------------------
-- History (substitute for atuin on Windows — atuin has no cmd integration).
-- ---------------------------------------------------------------------------
settings.set("history.max_lines",   "25000")
settings.set("history.shared",      "true")       -- all cmd windows share one history file
settings.set("history.dupe_mode",   "erase_prev") -- repeating a command moves it to the end
settings.set("history.expand_mode", "off")        -- `!42` etc. is more confusing than useful in cmd
settings.set("history.save",        "true")

-- ---------------------------------------------------------------------------
-- Display / input ergonomics
-- ---------------------------------------------------------------------------
settings.set("clink.colorize_input",   "true")
settings.set("match.expand_envvars",   "true")    -- expand %FOO% during completion
settings.set("match.ignore_case",      "relaxed")
settings.set("exec.enable",            "true")

-- ---------------------------------------------------------------------------
-- clink-fzf (if installed) — Ctrl-T (files), Ctrl-R (history), Alt-C (dirs).
-- Substitute for atuin's Ctrl-R TUI and the fzf zsh keybindings.
-- ---------------------------------------------------------------------------
settings.set("fzf.default_bindings", "true")
settings.set("fzf.height",           "60%")

-- Snazzy-ish palette + cleaner layout for all fzf invocations.
os.setenv("FZF_DEFAULT_OPTS",
  "--layout=reverse --info=inline --border=rounded --margin=1 --padding=0 "
  .. "--pointer='> ' --marker='+ ' --prompt='> ' "
  .. "--color=fg:#d0d0d0,bg:-1,hl:#57c7ff,fg+:#ffffff,bg+:#262626,hl+:#ff6ac1,"
  .. "info:#9aedfe,prompt:#ff6ac1,pointer:#ff5c57,marker:#5af78e,spinner:#ff6ac1,header:#5af78e")

-- Ctrl-R: command history. Field 1 is the history index; the rest is the command.
-- Preview pane shows the full (wrapped) command so long lines are readable
-- before you press Enter. Kept the upstream "DEL deletes entry" header.
os.setenv("FZF_CTRL_R_OPTS",
  "--prompt='history > ' "
  .. "--header='Ctrl-R toggle sort  -  Del remove entry  -  Enter run' "
  .. "--preview='echo {2..}' --preview-window=down:3:wrap "
  .. "--height=70%")

-- Ctrl-T: fuzzy find files in the current dir. Preview with bat (syntax-highlighted)
-- and fall back to `type` for binaries / when bat isn't available.
os.setenv("FZF_CTRL_T_OPTS",
  "--prompt='files > ' "
  .. "--preview='bat --color=always --style=numbers --line-range=:200 {} 2>nul || type {}' "
  .. "--preview-window=right:60%")

-- Alt-C: jump to a directory under cwd. Preview with eza's tree view.
os.setenv("FZF_ALT_C_OPTS",
  "--prompt='cd > ' "
  .. "--preview='eza --tree --level=2 --color=always --icons=never {} 2>nul' "
  .. "--preview-window=right:50%")

-- ---------------------------------------------------------------------------
-- clink-zoxide (if installed) — `cd <fragment>` jumps to a known frequent dir.
-- Matches the zsh setup: `zoxide init --cmd cd zsh` in home/.zshrc.
-- ---------------------------------------------------------------------------
settings.set("zoxide.cmd",         "cd")
settings.set("zoxide.hook",        "pwd")
settings.set("zoxide.no_aliases",  "false")
