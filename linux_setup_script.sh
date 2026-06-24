#!/usr/bin/env bash
# =============================================================================
# Arch Linux Dotfiles Setup Script
# Installs required packages and creates symlinks for all configs
# =============================================================================

set -euo pipefail

DOTFILES_DIR="$HOME/Documents/GitHub/Dotfiles/linux_dotfiles"
LOG_FILE="/tmp/dotfiles_setup.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()     { echo -e "${BLUE}[INFO]${NC}  $*" | tee -a "$LOG_FILE"; }
success() { echo -e "${GREEN}[OK]${NC}    $*" | tee -a "$LOG_FILE"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*" | tee -a "$LOG_FILE"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"; exit 1; }

# =============================================================================
# PREFLIGHT
# =============================================================================

log "Starting dotfiles setup — logging to $LOG_FILE"

[[ -d "$DOTFILES_DIR" ]] || error "Dotfiles directory not found: $DOTFILES_DIR"
[[ $EUID -eq 0 ]]        && error "Do not run this script as root."

# =============================================================================
# PACKAGE INSTALLATION
# =============================================================================

install_packages() {
    log "Updating pacman databases..."
    sudo pacman -Sy --noconfirm

    # ── Core / base ──────────────────────────────────────────────────────────
    PACMAN_PACKAGES=(
        # Shell
        zsh
        zsh-completions
        zsh-autosuggestions
        zsh-syntax-highlighting

        # Terminal multiplexer
        tmux

        # Neovim and common dependencies
        neovim
        git
        curl
        wget
        unzip
        ripgrep
        fd
        fzf
        tree-sitter
        nodejs
        npm
        python
        python-pip
        luarocks

        # Hyprland compositor + ecosystem
        hyprland
        hypridle
        hyprlock
        hyprshot
        xdg-desktop-portal-hyprland
        qt5-wayland
        qt6-wayland
        polkit-gnome
        
        # awww
        swww

        # Waybar
        waybar

        # Waybar optional but common deps
        otf-font-awesome
        ttf-font-awesome
        noto-fonts
        noto-fonts-emoji

        # Rofi (Wayland fork)
        rofi-wayland

        # Ghostty terminal
        ghostty

        # Wayland utilities often needed by Hyprland configs
        wl-clipboard
        grim
        slurp
        swappy
        dunst
        libnotify
        pipewire
        wireplumber
        xdg-user-dirs

        # Bluetooth
        blueman
        bluez
        bluez-utils

        # Development tools
        gcc
        clang
        docker
        docker-compose
        picocom

        # Office / productivity
        libreoffice-fresh

        # Communication / media
        discord
        obsidian
    )

    log "Installing pacman packages..."
    sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}" \
        && success "pacman packages installed" \
        || warn "Some pacman packages may have failed — check $LOG_FILE"

    # ── AUR helper (yay) ─────────────────────────────────────────────────────
    if ! command -v yay &>/dev/null; then
        log "Installing yay (AUR helper)..."
        tmp_dir=$(mktemp -d)
        git clone --depth=1 https://aur.archlinux.org/yay.git "$tmp_dir/yay"
        (cd "$tmp_dir/yay" && makepkg -si --noconfirm)
        rm -rf "$tmp_dir"
        success "yay installed"
    else
        success "yay already present — skipping"
    fi

    # ── AUR packages ─────────────────────────────────────────────────────────
    AUR_PACKAGES=(
        # Ghostty is on AUR if not yet in extra
        # ghostty   # uncomment if `pacman -S ghostty` fails above

        # Nerd fonts
        ttf-cascadia-code-nerd
        ttf-jetbrains-mono-nerd

        # pywal / color theming used by some rofi/waybar setups
        python-pywal

        # Browser
        brave-bin

        # Music
        spotify

        # VPN
        protonvpn-gui
    )

    log "Installing AUR packages via yay..."
    yay -S --needed --noconfirm "${AUR_PACKAGES[@]}" \
        && success "AUR packages installed" \
        || warn "Some AUR packages may have failed — check $LOG_FILE"
}

# =============================================================================
# SYMLINK HELPER
# =============================================================================

make_link() {
    local src="$1"
    local dst="$2"

    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"

    # Back up existing file/dir that is NOT already our symlink
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        local backup="${dst}.bak.$(date +%s)"
        warn "Backing up existing $dst → $backup"
        mv "$dst" "$backup"
    elif [[ -L "$dst" ]]; then
        log "Removing stale symlink: $dst"
        rm "$dst"
    fi

    ln -sf "$src" "$dst"
    success "Linked  $dst  →  $src"
}

# =============================================================================
# SYMLINKS
# =============================================================================

create_symlinks() {
    log "Creating configuration symlinks..."

    # ── Ghostty ──────────────────────────────────────────────────────────────
    make_link "$DOTFILES_DIR/ghostty/config" \
              "$HOME/.config/ghostty/config"

    # ── Hyprland ─────────────────────────────────────────────────────────────
    make_link "$DOTFILES_DIR/hypr/hyprland.lua"   "$HOME/.config/hypr/hyprland.lua"
    make_link "$DOTFILES_DIR/hypr/hypridle.conf"  "$HOME/.config/hypr/hypridle.conf"
    make_link "$DOTFILES_DIR/hypr/hyprlock.conf"  "$HOME/.config/hypr/hyprlock.conf"

    # ── Neovim ───────────────────────────────────────────────────────────────
    make_link "$DOTFILES_DIR/nvim/init.lua" \
              "$HOME/.config/nvim/init.lua"

    # ── Rofi ─────────────────────────────────────────────────────────────────
    make_link "$DOTFILES_DIR/rofi/config.rasi" \
              "$HOME/.config/rofi/config.rasi"

    # ── Tmux ─────────────────────────────────────────────────────────────────
    make_link "$DOTFILES_DIR/tmux/tmux.conf" \
              "$HOME/.config/tmux/tmux.conf"
    # Also link to legacy location some plugins expect
    make_link "$DOTFILES_DIR/tmux/tmux.conf" \
              "$HOME/.tmux.conf"

    # ── Waybar ───────────────────────────────────────────────────────────────
    make_link "$DOTFILES_DIR/waybar/config"    "$HOME/.config/waybar/config"
    make_link "$DOTFILES_DIR/waybar/style.css" "$HOME/.config/waybar/style.css"

    # ── Zsh ──────────────────────────────────────────────────────────────────
    make_link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
}

# =============================================================================
# POST-INSTALL TWEAKS
# =============================================================================

post_install() {
    # Set zsh as default shell
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        log "Changing default shell to zsh..."
        chsh -s "$(which zsh)" "$USER" \
            && success "Default shell set to zsh (re-login to take effect)" \
            || warn "Could not change shell automatically — run: chsh -s \$(which zsh)"
    else
        success "zsh is already the default shell"
    fi

    # Install tmux plugin manager (tpm)
    TPM_DIR="$HOME/.tmux/plugins/tpm"
    if [[ ! -d "$TPM_DIR" ]]; then
        log "Installing tmux plugin manager (tpm)..."
        git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR" \
            && success "tpm installed — press prefix+I inside tmux to install plugins"
    else
        success "tpm already installed"
    fi

    # Enable XDG user dirs
    xdg-user-dirs-update 2>/dev/null || true

    # Docker — enable service and add user to docker group
    log "Enabling docker service..."
    sudo systemctl enable --now docker \
        && success "docker service enabled" \
        || warn "Could not enable docker"
    if ! groups "$USER" | grep -q docker; then
        sudo usermod -aG docker "$USER"
        warn "Added $USER to docker group — re-login required before using docker without sudo"
    else
        success "$USER already in docker group"
    fi

    # Bluetooth — enable service
    log "Enabling bluetooth service..."
    sudo systemctl enable --now bluetooth \
        && success "bluetooth service enabled" \
        || warn "Could not enable bluetooth"

    log "Enabling pipewire services..."
    systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null \
        && success "pipewire services enabled" \
        || warn "Could not enable pipewire services (may need a re-login first)"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      Arch Dotfiles Setup Script          ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo ""

    install_packages
    create_symlinks
    post_install

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           Setup Complete!                ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
    echo ""
    log "Next steps:"
    log "  1. Log out and back in (or reboot) to start Hyprland + apply docker group"
    log "  2. Open tmux and press  prefix + I  to install plugins"
    log "  3. Open nvim — lazy.nvim/your plugin manager will bootstrap automatically"
    log "  4. Start swww with: swww-daemon & swww img <path/to/wallpaper>"
    log "  5. Review $LOG_FILE for any warnings"
}

main "$@"
