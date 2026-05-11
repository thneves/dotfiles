# dotfiles

Personal terminal + shell configuration. Tracked via the [bare-repo pattern](https://www.atlassian.com/git/tutorials/dotfiles) — files live in `$HOME`, version-controlled by a separate `~/.dotfiles` git directory.

**Theme:** Tokyo Night across all components · **Last bootstrap:** 2026-05-10

## Stack

| Layer | Tool | Tracked file |
|---|---|---|
| Terminal emulator | [Alacritty](https://github.com/alacritty/alacritty) | `.config/alacritty/alacritty.toml` |
| Multiplexer | [Zellij](https://github.com/zellij-org/zellij) | `.config/zellij/config.kdl` |
| Shell | zsh + oh-my-zsh | `.zshrc` |
| Prompt | [Starship](https://starship.rs) | `.config/starship.toml` |
| Git diff pager | [delta](https://github.com/dandavison/delta) | `.gitconfig` |
| Bootstrap | apt + GitHub releases | `.local/bin/dotfiles-bootstrap.sh` |

Full setup notes: [`.config/dotfiles-docs/terminal-setup.md`](.config/dotfiles-docs/terminal-setup.md)

## Bootstrap a fresh machine

```bash
# 1. Run the installer (apt packages + GitHub-release binaries + Nerd Font)
curl -fsSL https://raw.githubusercontent.com/thneves/dotfiles/main/.local/bin/dotfiles-bootstrap.sh -o /tmp/bootstrap.sh
bash /tmp/bootstrap.sh

# 2. Clone the bare repo
git clone --bare git@github.com:thneves/dotfiles.git $HOME/.dotfiles

# 3. Define alias + suppress untracked listing
alias config='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
config config --local status.showUntrackedFiles no

# 4. Check out configs (back up first if files already exist)
config checkout

# 5. Reload
chsh -s "$(which zsh)"
exec zsh
```

## Daily workflow

```bash
config status              # what changed
config diff
config add <path>
config commit -m "msg"
config push
```

## CI

`.github/workflows/lint.yml` runs on push:
- `zsh -n .zshrc` — syntax check
- TOML parse on alacritty + starship configs
- `bash -n` on bootstrap script

## Related

- Vault note (broader context): `3. Resources/Programming/Linux/Terminal Setup.md`
