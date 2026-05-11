---
tags: [linux, devtools, terminal, ricing, alacritty, zellij, starship, zsh]
aliases: [Terminal Stack, Alacritty Zellij Starship, Dev Terminal Setup]
created: 2026-05-10
updated: 2026-05-10
theme: Tokyo Night
---

# Terminal Setup

Current dev terminal stack on Debian-based system. Built 2026-05-10 with [[Claude Code]] assistance. Goal: fast, ergonomic, modern CLI with one cohesive theme (Tokyo Night).

> [!info] Stack at a glance
> **Emulator:** Alacritty 0.17.0 · **Multiplexer:** Zellij 0.44.2 · **Shell:** zsh + oh-my-zsh · **Prompt:** Starship 1.25.1 · **Theme:** Tokyo Night · **Font:** JetBrainsMono Nerd Font

## Related

- [[Ricing]]
- [[Arch Linux]]
- [[Neovim Cheatsheet]]
- [[Programming MOC]]

---

## Component map

| Layer | Tool | Config path |
|---|---|---|
| Terminal emulator | Alacritty | `~/.config/alacritty/alacritty.toml` |
| Terminal multiplexer | Zellij | `~/.config/zellij/config.kdl` |
| Shell | zsh + oh-my-zsh | `~/.zshrc`, `~/.oh-my-zsh/` |
| Prompt | Starship | `~/.config/starship.toml` |
| Font | JetBrainsMono Nerd Font | `~/.local/share/fonts/JetBrainsMono/` |
| Theme | Tokyo Night | applied across all four |

---

## Alacritty

Terminal emulator. GPU-accelerated, TOML config, minimal feature set.

**Key config bits** in `~/.config/alacritty/alacritty.toml`:

- Auto-launches Zellij session "main" on shell start:
  ```toml
  [terminal.shell]
  program = "/usr/bin/zsh"
  args = ["-l", "-c", "zellij attach -c main || zellij -s main"]
  ```
- Font: `JetBrainsMono Nerd Font` (normal/bold/italic), size 11.5
- Tokyo Night palette (primary, normal, bright, cursor, selection, indexed orange/red)
- Opacity 0.98, padding 8px, 10k scrollback
- `Ctrl+Shift+N` spawn new instance · `Ctrl+V` paste

**Heads up:** exiting Zellij also exits Alacritty (because shell is Zellij). For raw shell: `alacritty -e zsh` or comment the `args` line.

---

## Zellij

Multiplexer (tmux alternative). Modal, KDL config, plugin system.

**Custom in** `~/.config/zellij/config.kdl`:

- `default_mode "normal"` (was `locked` — flipped so hotkeys work without `Ctrl+g` first)
- Theme `tokyo-night` defined in `themes { ... }` block
- `show_startup_tips false`

### Mode cheatsheet

> [!note] Press the prefix from normal mode, then the letter
> Keys are sequential (mode → action), not chord like tmux.

| Prefix | Mode | What it does |
|---|---|---|
| `Ctrl+p` | pane | splits, focus, fullscreen |
| `Ctrl+t` | tab | tabs |
| `Ctrl+r` | resize | grow/shrink pane |
| `Ctrl+s` | scroll | scrollback + search |
| `Ctrl+o` | session | detach, plugins |
| `Ctrl+h` | move | reposition pane |
| `Ctrl+q` | — | quit zellij |
| `esc` | — | back to normal |

### Pane mode (`Ctrl+p` then…)

| Key | Action |
|---|---|
| `n` | new pane |
| `d` | split down |
| `r` | split right |
| `s` | stacked pane |
| `x` | close pane |
| `f` | fullscreen toggle |
| `h/j/k/l` | focus left/down/up/right |
| `c` | rename pane |
| `w` | toggle floating |
| `e` | embed/float toggle |

### Global (work in normal + locked)

| Key | Action |
|---|---|
| `Alt+n` | new pane |
| `Alt+h/j/k/l` or arrows | focus direction |
| `Alt+f` | toggle floating panes |
| `Alt+[` / `Alt+]` | swap layouts |
| `Alt++` / `Alt+-` | resize |

### Session commands (terminal)

```bash
zellij                    # new session
zellij ls                 # list sessions
zellij attach             # attach last
zellij --session work     # named session
zellij kill-session work  # kill named
zellij delete-all-sessions
```

---

## Starship

Cross-shell prompt. Single Rust binary, hooked via `eval "$(starship init zsh)"`.

**Config:** `~/.config/starship.toml` — Tokyo Night palette, two-line prompt:

```
 OS │  user │  cwd │  branch + git status │ lang ver │ docker/aws │ 󰥔 time
❯
```

**Modules enabled:** os, username, directory, git_branch, git_status, nodejs, python, rust, golang, lua, java, c, docker_context, aws, time. Kubernetes disabled by default.

**Common tweaks** (edit `~/.config/starship.toml`):
- Hide time → `[time] disabled = true`
- Hide OS → `[os] disabled = true`
- One-line prompt → remove `$line_break` from `format`
- Enable k8s → `[kubernetes] disabled = false`

---

## Modern CLI replacements

All installed via `apt` or GitHub releases. Symlinks live in `~/.local/bin/`.

| Tool | Replaces | Trigger |
|---|---|---|
| **fzf** | history search, file pick | `Ctrl+R`, `Ctrl+T`, `Alt+C` |
| **fd** | `find` | `fd pattern` |
| **bat** | `cat` | `cat file` (aliased) |
| **eza** | `ls` | `l`, `la`, `lt` |
| **ripgrep** | `grep -r` | `rg pattern` (aliased to `grep`) |
| **zoxide** | `cd` | `z partial-name`, `zi` (picker) |
| **delta** | git diff pager | transparent — every git diff |
| **lazygit** | git TUI | `lazygit` |
| **btop** | `top` / `htop` | `btop` |

### fzf keybinds (wired in zshrc)

| Keybind | What it does |
|---|---|
| `Ctrl+R` | fuzzy history search |
| `Ctrl+T` | insert fuzzy-picked file path at cursor |
| `Alt+C` | cd to fuzzy-picked subdir |

### zsh plugins (sourced in `~/.zshrc`)

- `zsh-autosuggestions` — ghost-text predictions from history. Press `→` to accept.
- `zsh-syntax-highlighting` — live red/green as you type. Must be sourced **last**.

---

## Aliases live in `.zshrc`

```bash
alias ls='eza --group-directories-first --icons'
alias l='eza -l --git --group-directories-first --icons'
alias la='eza -la --git --group-directories-first --icons'
alias lt='eza --tree --level=2 --git-ignore --icons'
alias cat='bat --paging=never'
alias catp='bat'           # paged
alias ccat='/bin/cat'      # original cat
alias grep='rg'
```

---

## Git + delta integration

`~/.gitconfig` keys set:

```ini
[core]
    pager = delta
[interactive]
    diffFilter = delta --color-only
[delta]
    navigate = true
    side-by-side = true
    line-numbers = true
    syntax-theme = Monokai Extended
[merge]
    conflictstyle = diff3
[diff]
    colorMoved = default
```

Every `git diff`, `git show`, `git log -p` now renders side-by-side syntax-highlighted.

---

## Daily workflow combos

> [!tip] Power combos worth muscle-memoryzing
> - `vim $(fzf)` — fuzzy pick then edit
> - `cd $(fd -t d \| fzf)` — drill into dir
> - `git checkout $(git branch \| fzf)` — branch picker
> - `kill -9 $(ps aux \| fzf \| awk '{print $2}')` — kill picker
> - `z proj` + `lazygit` — jump + commit
> - In lazygit: `space` stage · `c` commit · `P` push · `r` rebase · `?` help

---

## How to reproduce on fresh machine

> [!warning] Order matters
> Install order: font → emulator → multiplexer → shell tools → prompt → editor.

```bash
# 1. Nerd Font
mkdir -p ~/.local/share/fonts/JetBrainsMono
cd /tmp && curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
fc-cache -fv

# 2. Alacritty (cargo) + Zellij (binary)
# Already installed via cargo / direct download — keep tarball cache for offline

# 3. Shell modernization (apt)
sudo apt install -y fzf fd-find bat zoxide zsh-autosuggestions zsh-syntax-highlighting ripgrep
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
ln -sf "$(which batcat)" ~/.local/bin/bat

# 4. GitHub-release binaries → ~/.local/bin
# eza, delta, lazygit, starship — see Terminal Setup script (TODO)

# 5. Wire ~/.zshrc and ~/.gitconfig (copy from this machine)
# 6. Copy ~/.config/alacritty, ~/.config/zellij, ~/.config/starship.toml
```

> [!todo] Future
> - Bundle dotfiles in a public repo for replication
> - Upgrade neovim 0.7.2 → 0.10+ (current is 3 yr old)
> - Try `atuin` for history sync across machines
> - Build a `zellij` layout file for default split (e.g. editor + shell + logs)

---

## Tags

#linux #terminal #devtools #ricing #productivity #setup
