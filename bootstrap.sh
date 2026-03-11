#!/usr/bin/env bash
#
# Bootstrap: installs CLI tools and symlinks for this dotfiles setup.
# Run from repo root: ./bootstrap.sh
#
# What gets installed:
#   - Homebrew CLI: bat, zoxide, lsd, fzf, ripgrep, gitui, gnupg (for Node)
#   - Font: JetBrains Mono Nerd Font (for Neovim/icons)
#   - Symlinks: Alacritty, Neovim config, tmux, gitui theme, zshrc
#   - Tmux: TPM + plugins (sensible, resurrect, continuum, vim-tmux-navigator, catppuccin, yank)
#   - Zsh: zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab; Ctrl+R fuzzy history (fzf)
#   - Neovim: plugin build (Lazy)
#
# Prerequisites: Homebrew. Languages/runtimes (Node, Go, Rust, Java, Neovim)
# should be installed and version-managed manually (e.g. rustup, system Go/Node).
#
set -euo pipefail

# Make Homebrew quieter during bootstrap runs.
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1

backup_path() {
  local target="$1"

  [ ! -e "$target" ] && return

  local backup="${target}.bak"
  if [ -e "$backup" ]; then
    backup="${backup}.$(date +%Y%m%d%H%M%S)"
  fi

  mv "$target" "$backup"
  echo "Backed up $target -> $backup"
}

build_neovim_plugins() {
  if ! command -v nvim >/dev/null 2>&1; then
    echo "WARNING: nvim not available; skipping plugin build."
    return
  fi

  if ! nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1; then
    echo "WARNING: Failed to run 'Lazy sync'; Neovim plugins may not be fully installed."
  fi
}

verify_installations() {
  echo "==== Verification ===="

  if command -v node >/dev/null 2>&1; then
    echo "Node: $(node --version) (from $(command -v node))"
  else
    echo "Node: not available"
  fi

  if /usr/libexec/java_home >/dev/null 2>&1; then
    local jhome
    jhome="$(
      /usr/libexec/java_home 2>/dev/null || true
    )"
    if [ -n "${jhome:-}" ] && [ -x "$jhome/bin/java" ]; then
      echo "Java: $("$jhome/bin/java" -version 2>&1 | head -n 1) (java_home=$jhome)"
    else
      echo "Java: detected via java_home but could not determine version"
    fi
  else
    echo "Java: not available"
  fi

  if command -v go >/dev/null 2>&1; then
    echo "Go:   $(go version) (from $(command -v go))"
  else
    echo "Go:   not available"
  fi

  if command -v rustc >/dev/null 2>&1; then
    echo "Rust: $(rustc --version) (from $(command -v rustc))"
  else
    echo "Rust: not available"
  fi

   if command -v rust-analyzer >/dev/null 2>&1; then
    echo "rust-analyzer: $(command -v rust-analyzer)"
  else
    echo "rust-analyzer: not available"
  fi

  if command -v nvim >/dev/null 2>&1; then
    echo "Neovim: $(nvim --version | head -n 1) (from $(command -v nvim))"
  else
    echo "Neovim: not available"
  fi
}

symlink_alacritty_config() {
  ALACRITTY_SOURCE_DIR="$HOME/dotfiles/alacritty"
  ALACRITTY_SOURCE_CONFIG="$ALACRITTY_SOURCE_DIR/alacritty.toml"
  ALACRITTY_CONFIG_DIR="$HOME/.config/alacritty"
  ALACRITTY_CONFIG_FILE="$ALACRITTY_CONFIG_DIR/alacritty.toml"
  ALACRITTY_THEMES_SOURCE="$ALACRITTY_SOURCE_DIR/themes"
  ALACRITTY_THEMES_TARGET="$ALACRITTY_CONFIG_DIR/themes"

  mkdir -p "$HOME/.config"

  if [ -L "$ALACRITTY_CONFIG_DIR" ]; then
    echo "WARNING: $ALACRITTY_CONFIG_DIR is a symlink. Skipping file-level Alacritty symlinks."
    return
  fi

  mkdir -p "$ALACRITTY_CONFIG_DIR"

  if [ -e "$ALACRITTY_CONFIG_FILE" ] && [ ! -L "$ALACRITTY_CONFIG_FILE" ]; then
    backup_path "$ALACRITTY_CONFIG_FILE"
  fi

  ln -sfn "$ALACRITTY_SOURCE_CONFIG" "$ALACRITTY_CONFIG_FILE"
  echo "Linked $ALACRITTY_CONFIG_FILE -> $ALACRITTY_SOURCE_CONFIG"

  if [ -e "$ALACRITTY_THEMES_TARGET" ] && [ ! -L "$ALACRITTY_THEMES_TARGET" ]; then
    backup_path "$ALACRITTY_THEMES_TARGET"
  fi

  ln -sfn "$ALACRITTY_THEMES_SOURCE" "$ALACRITTY_THEMES_TARGET"
  echo "Linked $ALACRITTY_THEMES_TARGET -> $ALACRITTY_THEMES_SOURCE"
}

symlink_neovim_config() {
  local source_nvim_config_dir="$HOME/dotfiles/nvim"
  local target_nvim_config_dir="$HOME/.config/nvim"

  mkdir -p "$HOME/.config"

  if [ -e "$target_nvim_config_dir" ] && [ ! -L "$target_nvim_config_dir" ]; then
    backup_path "$target_nvim_config_dir"
  fi

  ln -sfn "$source_nvim_config_dir" "$target_nvim_config_dir"
  echo "Linked $target_nvim_config_dir -> $source_nvim_config_dir"
}

install_jetbrains_mono_nerd_font() {
  if ! brew list --cask | grep -q "font-jetbrains-mono-nerd-font"; then
    brew tap homebrew/cask-fonts 2>/dev/null || true
    brew install --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1
    echo "Font: JetBrains Mono Nerd Font installed"
  else
    echo "Font: JetBrains Mono Nerd Font already installed"
  fi
}

install_bat_and_alias() {
  if command -v brew >/dev/null 2>&1; then
    if ! brew list bat >/dev/null 2>&1; then
      brew install -q bat >/dev/null 2>&1
      echo "bat: installed"
    else
      echo "bat: already installed"
    fi
  else
    echo "bat: skipped (Homebrew not installed)"
  fi
}

install_zoxide() {
  if command -v brew >/dev/null 2>&1; then
    if ! brew list zoxide >/dev/null 2>&1; then
      brew install -q zoxide >/dev/null 2>&1
      echo "zoxide: installed"
    else
      echo "zoxide: already installed"
    fi
  else
    echo "zoxide: skipped (Homebrew not installed)"
  fi
}

install_lsd() {
  if command -v brew >/dev/null 2>&1; then
    if ! brew list lsd >/dev/null 2>&1; then
      brew install -q lsd >/dev/null 2>&1
      echo "lsd: installed"
    else
      echo "lsd: already installed"
    fi
  else
    echo "lsd: skipped (Homebrew not installed)"
  fi
}

install_fzf() {
  if command -v brew >/dev/null 2>&1; then
    if ! brew list fzf >/dev/null 2>&1; then
      brew install -q fzf >/dev/null 2>&1
      echo "fzf: installed"
    else
      echo "fzf: already installed"
    fi
  else
    echo "fzf: skipped (Homebrew not installed)"
  fi
}

install_ripgrep() {
  if command -v brew >/dev/null 2>&1; then
    if ! brew list ripgrep >/dev/null 2>&1; then
      brew install -q ripgrep >/dev/null 2>&1
      echo "ripgrep: installed"
    else
      echo "ripgrep: already installed"
    fi
  else
    echo "ripgrep: skipped (Homebrew not installed)"
  fi
}

install_gitui() {
  if command -v brew >/dev/null 2>&1; then
    if ! brew list gitui >/dev/null 2>&1; then
      brew install -q gitui >/dev/null 2>&1
      echo "gitui: installed"
    else
      echo "gitui: already installed"
    fi
  else
    echo "gitui: skipped (Homebrew not installed)"
  fi
}

install_java() {
  # On macOS, /usr/bin/java exists even when no JDK is installed and prints
  # a noisy "Unable to locate a Java Runtime" message. Prefer java_home.
  if /usr/libexec/java_home >/dev/null 2>&1; then
    echo "Java: already installed (java_home=$(/usr/libexec/java_home 2>/dev/null))"
    return
  fi

  if command -v brew >/dev/null 2>&1; then
    if brew list --cask 2>/dev/null | grep -q "^temurin$"; then
      echo "Java: temurin JDK already installed"
      return
    fi

    if brew install --cask temurin >/dev/null 2>&1; then
      echo "Java: installed (temurin JDK)"
    else
      echo "Java: install failed via Homebrew (temurin)"
    fi
  else
    echo "Java: skipped (Homebrew not installed)"
  fi
}

install_go() {
  if command -v go >/dev/null 2>&1; then
    echo "Go: already installed at $(command -v go)"
    return
  fi

  if command -v brew >/dev/null 2>&1; then
    if brew install -q go >/dev/null 2>&1; then
      echo "Go: installed at $(command -v go || echo 'PATH may need a new shell')"
    else
      echo "Go: install failed via Homebrew"
    fi
  else
    echo "Go: skipped (Homebrew not installed)"
  fi
}

install_node() {
  if command -v node >/dev/null 2>&1; then
    echo "Node.js: already installed at $(command -v node)"
    return
  fi

  if command -v brew >/dev/null 2>&1; then
    if brew install -q node >/dev/null 2>&1; then
      echo "Node.js: installed at $(command -v node || echo 'PATH may need a new shell')"
    else
      echo "Node.js: install failed via Homebrew"
    fi
  else
    echo "Node.js: skipped (Homebrew not installed)"
  fi
}

symlink_zshrc() {
  local source_zshrc="$HOME/dotfiles/zsh/.zshrc"
  local target_zshrc="$HOME/.zshrc"

  if [ -e "$target_zshrc" ] && [ ! -L "$target_zshrc" ]; then
    backup_path "$target_zshrc"
  fi

  ln -sfn "$source_zshrc" "$target_zshrc"
  echo "Linked $target_zshrc -> $source_zshrc"
}

symlink_tmux_config() {
  local source_tmux_conf="$HOME/dotfiles/tmux/.tmux.conf"
  local target_tmux_conf="$HOME/.tmux.conf"

  if [ -e "$target_tmux_conf" ] && [ ! -L "$target_tmux_conf" ]; then
    backup_path "$target_tmux_conf"
  fi

  ln -sfn "$source_tmux_conf" "$target_tmux_conf"
  echo "Linked $target_tmux_conf -> $source_tmux_conf"
}

install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [ -d "$tpm_dir" ]; then
    echo "TPM already present at $tpm_dir"
    return
  fi
  mkdir -p "$(dirname "$tpm_dir")"
  git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  echo "Cloned TPM to $tpm_dir"
}

install_zsh_autosuggestions() {
  local plugin_dir="$HOME/.zsh/plugins/zsh-autosuggestions"
  if [ -f "$plugin_dir/zsh-autosuggestions.zsh" ]; then
    echo "zsh-autosuggestions already present at $plugin_dir"
    return
  fi
  mkdir -p "$(dirname "$plugin_dir")"
  git clone https://github.com/zsh-users/zsh-autosuggestions "$plugin_dir"
  echo "Cloned zsh-autosuggestions to $plugin_dir"
}

install_zsh_syntax_highlighting() {
  local plugin_dir="$HOME/.zsh/plugins/zsh-syntax-highlighting"
  if [ -f "$plugin_dir/zsh-syntax-highlighting.zsh" ]; then
    echo "zsh-syntax-highlighting already present at $plugin_dir"
    return
  fi
  mkdir -p "$(dirname "$plugin_dir")"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugin_dir"
  echo "Cloned zsh-syntax-highlighting to $plugin_dir"
}

install_fzf_tab() {
  local plugin_dir="$HOME/.zsh/plugins/fzf-tab"
  if [ -f "$plugin_dir/fzf-tab.zsh" ]; then
    echo "fzf-tab already present at $plugin_dir"
    return
  fi
  mkdir -p "$(dirname "$plugin_dir")"
  git clone https://github.com/Aloxaf/fzf-tab "$plugin_dir"
  echo "Cloned fzf-tab to $plugin_dir"
}

symlink_gitui_config() {
  local source_gitui="$HOME/dotfiles/gitui"
  local target_gitui="$HOME/.config/gitui"

  mkdir -p "$HOME/.config"
  if [ -e "$target_gitui" ] && [ ! -L "$target_gitui" ]; then
    backup_path "$target_gitui"
  fi
  ln -sfn "$source_gitui" "$target_gitui"
  echo "Linked $target_gitui -> $source_gitui"
}

main() {
  echo "==== Bootstrapping development environment ===="

  # --- config symlinks + Neovim ---
  symlink_alacritty_config
  symlink_neovim_config
  build_neovim_plugins
  symlink_tmux_config
  install_tpm
  symlink_gitui_config
  symlink_zshrc
  install_zsh_autosuggestions
  install_zsh_syntax_highlighting
  install_fzf_tab

  # --- all CLI / app dependencies (Homebrew) ---
  install_jetbrains_mono_nerd_font
  install_bat_and_alias
  install_zoxide
  install_lsd
  install_fzf
  install_ripgrep
  install_gitui

  # --- language runtimes (baseline via Homebrew; you can still layer rustup/fnm/etc) ---
  install_java
  install_go
  install_node

  # --- language/tooling verification (uses whatever is on PATH) ---
  verify_installations

  echo "==== Bootstrap Complete ===="
}

main "$@"