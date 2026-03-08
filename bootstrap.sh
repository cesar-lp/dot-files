#!/usr/bin/env bash
#
# Bootstrap: installs all dependencies and symlinks for this dotfiles setup.
# Run from repo root: ./bootstrap.sh
#
# What gets installed:
#   - asdf + plugins (nodejs, java, golang, rust, neovim)
#   - Languages via asdf: Node, Java, Go, Rust, Neovim; plus gopls (Go LSP) via go install
#   - Homebrew CLI: bat, zoxide, lsd, fzf, ripgrep, gitui, gnupg (for Node)
#   - Font: JetBrains Mono Nerd Font (for Neovim/icons)
#   - Symlinks: Alacritty, Neovim config, tmux, gitui theme, zshrc
#   - Tmux: TPM + plugins (sensible, resurrect, continuum, vim-tmux-navigator, catppuccin, yank)
#   - Zsh: zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab; Ctrl+R fuzzy history (fzf)
#   - Neovim: plugin build (Lazy)
#
# Prerequisites: Homebrew, asdf (install first if needed).
#
set -euo pipefail

ASDF_GLOBAL_TOOL_VERSIONS="${ASDF_GLOBAL_TOOL_VERSIONS:-$HOME/.tool-versions}"
ASDF_LOCAL_TOOL_VERSIONS="${ASDF_LOCAL_TOOL_VERSIONS:-$PWD/.tool-versions}"

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

ensure_asdf() {
  # Ensure asdf is available
  if ! command -v asdf >/dev/null 2>&1; then
    echo "ERROR: asdf is not installed or not in PATH"
    exit 1
  fi

  echo "Using asdf version: $(asdf --version)"
}

add_asdf_plugins() {
  echo "---- Adding plugins ----"
  asdf plugin add nodejs || echo "nodejs plugin already added"
  asdf plugin add java || echo "java plugin already added"
  asdf plugin add golang || echo "golang plugin already added"
  asdf plugin add rust || echo "rust plugin already added"
  asdf plugin add neovim || echo "neovim plugin already added"
}

ensure_tool_version() {
  local tool="$1"
  local version="$2"

  for file in "$ASDF_GLOBAL_TOOL_VERSIONS" "$ASDF_LOCAL_TOOL_VERSIONS"; do
    [ -z "$file" ] && continue

    mkdir -p "$(dirname "$file")"
    touch "$file"

    if ! grep -q "^${tool} " "$file"; then
      echo "${tool} ${version}" >>"$file"
    fi
  done
}

set_latest_as_global() {
  local tool="$1"

  # Resolve the concrete version string that "latest" maps to
  local resolved_version
  if ! resolved_version="$(asdf latest "$tool" 2>/dev/null)"; then
    echo "WARNING: Unable to resolve latest version for ${tool}; leaving .tool-versions unchanged."
    return
  fi

  ensure_tool_version "$tool" "$resolved_version"
}

install_node() {
  echo "---- Installing Node ----"

  # Node requires GPG
  if ! command -v gpg >/dev/null 2>&1; then
    echo "Installing gnupg via brew..."
    if ! brew install gnupg; then
      echo "WARNING: Failed to install gnupg; Node installation may fail."
    fi
  fi

  if ! asdf install nodejs latest; then
    echo "WARNING: 'asdf install nodejs latest' failed; Node not installed."
    return
  fi

  set_latest_as_global "nodejs"
}

install_java() {
  echo "---- Installing latest Java ----"

  echo "Resolving latest Java version..."
  local java_version
  if ! java_version="$(asdf latest java 2>/dev/null)"; then
    echo "WARNING: Unable to resolve latest Java version; Java not installed."
    return
  fi

  echo "Installing Java version: ${java_version}"
  if ! asdf install java "${java_version}"; then
    echo "WARNING: 'asdf install java ${java_version}' failed; Java not installed."
    return
  fi

  ensure_tool_version "java" "${java_version}"
}

install_go() {
  echo "---- Installing latest Go ----"
  echo "Installing Go version: latest"

  if ! asdf install golang latest; then
    echo "WARNING: 'asdf install golang latest' failed; Go not installed."
    return
  fi
  set_latest_as_global "golang"
}

install_gopls() {
  echo "---- Installing gopls (Go language server) ----"
  # Mason often fails to install gopls when Neovim is launched from a GUI (Go not in PATH). Install via go so LSP finds it.
  if ! command -v go >/dev/null 2>&1; then
    echo "WARNING: go not in PATH; skipping gopls. Run bootstrap again or: go install golang.org/x/tools/gopls@latest"
    return
  fi
  go install golang.org/x/tools/gopls@latest
  echo "gopls installed to $(go env GOPATH)/bin"
}

install_rust() {
  echo "---- Installing latest Rust ----"

  # Skip if this version is already installed (idempotent re-runs).
  if asdf list rust 2>/dev/null | grep -q "latest\|[0-9]"; then
    echo "Rust already installed via asdf; skipping."
    set_latest_as_global "rust" 2>/dev/null || true
    return
  fi

  # Rustup sees asdf shims in PATH and errors "cannot install while Rust is installed".
  # Tell rustup to skip that check so the install can proceed.
  export RUSTUP_INIT_SKIP_PATH_CHECK=yes
  echo "Installing Rust version: latest"

  if ! asdf install rust latest; then
    echo "WARNING: 'asdf install rust latest' failed; Rust not installed."
  else
    set_latest_as_global "rust"
  fi
}

install_neovim() {
  echo "---- Installing latest Neovim ----"
  echo "Installing Neovim version: latest"

  if ! asdf install neovim latest; then
    echo "WARNING: 'asdf install neovim latest' failed; Neovim not installed."
  else
    set_latest_as_global "neovim"
  fi
}

build_neovim_plugins() {
  echo "---- Building Neovim plugins (lazy.nvim) ----"

  if ! command -v nvim >/dev/null 2>&1; then
    echo "WARNING: nvim not available; skipping plugin build."
    return
  fi

  if ! nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1; then
    echo "WARNING: Failed to run 'Lazy sync'; Neovim plugins may not be fully installed."
  fi
}

reshim_asdf() {
  echo "---- Reshimming ----"
  asdf reshim
}

verify_installations() {
  echo "==== Verification ===="

  if command -v node >/dev/null 2>&1; then
    echo "Node: $(node --version)"
  else
    echo "Node: not available"
  fi

  if command -v java >/dev/null 2>&1; then
    echo "Java: $(java --version | head -n 1)"
  else
    echo "Java: not available"
  fi

  if command -v go >/dev/null 2>&1; then
    echo "Go:   $(go version)"
  else
    echo "Go:   not available"
  fi

  if command -v rustc >/dev/null 2>&1; then
    echo "Rust: $(rustc --version)"
  else
    echo "Rust: not available"
  fi

  if command -v nvim >/dev/null 2>&1; then
    echo "Neovim: $(nvim --version | head -n 1)"
  else
    echo "Neovim: not available"
  fi
}

symlink_alacritty_config() {
  echo "---- Symlinking Alacritty config ----"

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
  echo "---- Symlinking Neovim config ----"

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
  echo "---- Installing JetBrains Mono Nerd Font ----"

  if ! brew list --cask | grep -q "font-jetbrains-mono-nerd-font"; then
    brew tap homebrew/cask-fonts 2>/dev/null || true
    brew install --cask font-jetbrains-mono-nerd-font
    echo "JetBrains Mono Nerd Font installed"
  else
    echo "JetBrains Mono Nerd Font already installed"
  fi
}

install_bat_and_alias() {
  echo "---- Installing bat ----"

  if command -v brew >/dev/null 2>&1; then
    if ! brew list bat >/dev/null 2>&1; then
      echo "Installing bat via Homebrew..."
      brew install bat
    else
      echo "bat already installed via Homebrew"
    fi
  else
    echo "WARNING: Homebrew is not installed; skipping bat installation."
  fi
}

install_zoxide() {
  echo "---- Installing zoxide ----"

  if command -v brew >/dev/null 2>&1; then
    if ! brew list zoxide >/dev/null 2>&1; then
      echo "Installing zoxide via Homebrew..."
      brew install zoxide
    else
      echo "zoxide already installed via Homebrew"
    fi
  else
    echo "WARNING: Homebrew is not installed; skipping zoxide installation."
  fi
}

install_lsd() {
  echo "---- Installing lsd ----"

  if command -v brew >/dev/null 2>&1; then
    if ! brew list lsd >/dev/null 2>&1; then
      echo "Installing lsd via Homebrew..."
      brew install lsd
    else
      echo "lsd already installed via Homebrew"
    fi
  else
    echo "WARNING: Homebrew is not installed; skipping lsd installation."
  fi
}

install_fzf() {
  echo "---- Installing fzf ----"

  if command -v brew >/dev/null 2>&1; then
    if ! brew list fzf >/dev/null 2>&1; then
      echo "Installing fzf via Homebrew..."
      brew install fzf
    else
      echo "fzf already installed via Homebrew"
    fi
  else
    echo "WARNING: Homebrew is not installed; skipping fzf installation."
  fi
}

install_ripgrep() {
  echo "---- Installing ripgrep (required for Telescope live_grep) ----"

  if command -v brew >/dev/null 2>&1; then
    if ! brew list ripgrep >/dev/null 2>&1; then
      echo "Installing ripgrep via Homebrew..."
      brew install ripgrep
    else
      echo "ripgrep already installed via Homebrew"
    fi
  else
    echo "WARNING: Homebrew is not installed; skipping ripgrep installation."
  fi
}

install_gitui() {
  echo "---- Installing gitui (TUI for git, <leader>gi in Neovim) ----"

  if command -v brew >/dev/null 2>&1; then
    if ! brew list gitui >/dev/null 2>&1; then
      echo "Installing gitui via Homebrew..."
      brew install gitui
    else
      echo "gitui already installed via Homebrew"
    fi
  else
    echo "WARNING: Homebrew is not installed; skipping gitui installation."
  fi
}

symlink_zshrc() {
  echo "---- Symlinking .zshrc ----"

  local source_zshrc="$HOME/dotfiles/zsh/.zshrc"
  local target_zshrc="$HOME/.zshrc"

  if [ -e "$target_zshrc" ] && [ ! -L "$target_zshrc" ]; then
    backup_path "$target_zshrc"
  fi

  ln -sfn "$source_zshrc" "$target_zshrc"
  echo "Linked $target_zshrc -> $source_zshrc"
}

symlink_tmux_config() {
  echo "---- Symlinking tmux config ----"

  local source_tmux_conf="$HOME/dotfiles/tmux/.tmux.conf"
  local target_tmux_conf="$HOME/.tmux.conf"

  if [ -e "$target_tmux_conf" ] && [ ! -L "$target_tmux_conf" ]; then
    backup_path "$target_tmux_conf"
  fi

  ln -sfn "$source_tmux_conf" "$target_tmux_conf"
  echo "Linked $target_tmux_conf -> $source_tmux_conf"
}

install_tpm() {
  echo "---- Installing Tmux Plugin Manager (TPM) ----"
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
  echo "---- Installing zsh-autosuggestions ----"
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
  echo "---- Installing zsh-syntax-highlighting ----"
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
  echo "---- Installing fzf-tab ----"
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
  echo "---- Symlinking gitui config (theme) ----"

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

  # --- asdf + language runtimes ---
  ensure_asdf
  add_asdf_plugins
  install_node
  install_java
  install_go
  install_rust
  install_neovim
  reshim_asdf
  install_gopls
  verify_installations

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

  echo "==== Bootstrap Complete ===="
}

main "$@"