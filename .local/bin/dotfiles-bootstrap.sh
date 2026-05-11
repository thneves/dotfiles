#!/usr/bin/env bash
# Bootstrap script — install all tooling on a fresh Debian-based machine.
# Idempotent: re-running is safe.
#
# Usage: ./dotfiles-bootstrap.sh
#
# After: clone the bare dotfiles repo and check out:
#   git clone --bare git@github.com:thneves/dotfiles.git ~/.dotfiles
#   git --git-dir=$HOME/.dotfiles --work-tree=$HOME config --local status.showUntrackedFiles no
#   git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout

set -euo pipefail

LOCAL_BIN="$HOME/.local/bin"
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

log() { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

mkdir -p "$LOCAL_BIN"

# ---------- apt packages ----------
log "Installing apt packages (will sudo)"
sudo apt update
sudo apt install -y \
    curl wget unzip git zsh \
    fzf fd-find bat zoxide ripgrep btop neovim \
    zsh-autosuggestions zsh-syntax-highlighting \
    fontconfig

# ---------- Debian binary name fixups ----------
log "Symlinking fdfind → fd, batcat → bat"
ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd"
ln -sf "$(command -v batcat)" "$LOCAL_BIN/bat"

# ---------- Nerd Font ----------
if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    log "Installing JetBrainsMono Nerd Font"
    mkdir -p "$FONT_DIR"
    cd "$TMP"
    curl -fLO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    unzip -oq JetBrainsMono.zip -d "$FONT_DIR"
    fc-cache -f "$FONT_DIR" >/dev/null
else
    log "Nerd Font already present, skipping"
fi

# ---------- starship ----------
if ! have starship; then
    log "Installing starship"
    cd "$TMP"
    curl -fLO "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz"
    tar -xzf starship-x86_64-unknown-linux-gnu.tar.gz
    install -m 0755 starship "$LOCAL_BIN/starship"
else
    log "starship already present, skipping"
fi

# ---------- eza ----------
if ! have eza; then
    log "Installing eza"
    cd "$TMP"
    curl -fLO "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
    tar -xzf eza_x86_64-unknown-linux-gnu.tar.gz
    install -m 0755 eza "$LOCAL_BIN/eza"
else
    log "eza already present, skipping"
fi

# ---------- delta ----------
if ! have delta; then
    log "Installing delta"
    cd "$TMP"
    DELTA_URL=$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest \
        | grep browser_download_url \
        | grep x86_64-unknown-linux-gnu.tar.gz \
        | head -1 | cut -d'"' -f4)
    curl -fLO "$DELTA_URL"
    tar -xzf "$(basename "$DELTA_URL")"
    install -m 0755 "$(find . -maxdepth 2 -name delta -type f | head -1)" "$LOCAL_BIN/delta"
else
    log "delta already present, skipping"
fi

# ---------- lazygit ----------
if ! have lazygit; then
    log "Installing lazygit"
    cd "$TMP"
    LG_URL=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
        | grep browser_download_url \
        | grep -i Linux_x86_64.tar.gz \
        | head -1 | cut -d'"' -f4)
    curl -fLO "$LG_URL"
    tar -xzf "$(basename "$LG_URL")" lazygit
    install -m 0755 lazygit "$LOCAL_BIN/lazygit"
else
    log "lazygit already present, skipping"
fi

# ---------- zellij + alacritty (assumed installed via cargo) ----------
if ! have zellij; then
    log "WARNING: zellij not found. Install via cargo: cargo install --locked zellij"
fi
if ! have alacritty; then
    log "WARNING: alacritty not found. Install via cargo: cargo install alacritty"
fi

log "Done. Next steps:"
echo "  1. Clone dotfiles bare repo (see comment at top of this script)"
echo "  2. chsh -s \$(which zsh)   # if not already default"
echo "  3. exec zsh                 # reload"
