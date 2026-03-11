# =========================================
# Homebrew
# =========================================

if [[ "$(uname -m)" == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

export PATH="$HOME/bin:$PATH"

# =========================================
# History
# =========================================

HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt HIST_REDUCE_BLANKS

# =========================================
# Completion
# =========================================

autoload -Uz compinit
compinit

# =========================================
# fzf-tab (fuzzy tab completion; load after compinit)
# =========================================

FZF_TAB_DIR="${FZF_TAB_DIR:-$HOME/.zsh/plugins/fzf-tab}"
[ -f "$FZF_TAB_DIR/fzf-tab.zsh" ] && source "$FZF_TAB_DIR/fzf-tab.zsh"

# =========================================
# Aliases
# =========================================

alias cd="z"
alias ls="lsd"
alias ll="ls -la"
alias l="lsd -l"
alias la="lsd -a"
alias lla="lsd -la"
alias lt="lsd --tree"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias v="nvim"
alias cat="bat"

# =========================================
# zoxide
# =========================================

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# =========================================
# fzf (Ctrl+R = fuzzy history, Ctrl+T = files, Alt+C = cd)
# =========================================

if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
elif command -v brew >/dev/null 2>&1 && [ -f "$(brew --prefix fzf)/shell/key-bindings.zsh" ]; then
  source "$(brew --prefix fzf)/shell/key-bindings.zsh"
fi

# =========================================
# zsh-autosuggestions (→ to accept suggestion)
# =========================================

ZSH_AUTOSUGGESTIONS="${ZSH_AUTOSUGGESTIONS:-$HOME/.zsh/plugins/zsh-autosuggestions}"
[ -f "$ZSH_AUTOSUGGESTIONS/zsh-autosuggestions.zsh" ] && source "$ZSH_AUTOSUGGESTIONS/zsh-autosuggestions.zsh"

# =========================================
# zsh-syntax-highlighting (must be sourced last)
# =========================================

ZSH_SYNTAX_HIGHLIGHTING="${ZSH_SYNTAX_HIGHLIGHTING:-$HOME/.zsh/plugins/zsh-syntax-highlighting}"
[ -f "$ZSH_SYNTAX_HIGHLIGHTING/zsh-syntax-highlighting.zsh" ] && source "$ZSH_SYNTAX_HIGHLIGHTING/zsh-syntax-highlighting.zsh"

# =========================================
# Prompt (simple, no background highlight for readability in Alacritty)
# =========================================
# Hostname in prompt: set PROMPT_HOST in .zshrc.local to override (e.g. PROMPT_HOST="home")
# Otherwise uses system hostname (%m). Requires prompt_subst so ${PROMPT_HOST:-%m} expands.

setopt prompt_subst
autoload -Uz promptinit
promptinit
PROMPT='%F{cyan}%n@${PROMPT_HOST:-%m}%f %F{blue}%~%f %# '

# =========================================
# Machine-specific overrides
# =========================================

LOCAL_ZSH="$HOME/dotfiles/zsh/.zshrc.local"
[ -f "$LOCAL_ZSH" ] && source "$LOCAL_ZSH"

if [[ -n "${DOTFILES_ENV:-}" ]]; then
  ENV_FILE="$HOME/dotfiles/env/${DOTFILES_ENV}.env"
  [ -f "$ENV_FILE" ] && source "$ENV_FILE"
fi

# =========================================
# tmux auto-start
# =========================================

if [[ -z "${TMUX:-}" ]] && [[ -t 1 ]]; then
  exec tmux
fi