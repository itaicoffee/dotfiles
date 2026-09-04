# ==============================================================================
# MACHINE-SPECIFIC SETTINGS & SECRETS
# ==============================================================================

# ~/.profile is local to this machine (not managed by git) and holds env vars
# like the CHROME_PROFILE_* mappings
[ -f "$HOME/.profile" ] && . "$HOME/.profile"

# Source secrets if present
[ -f "$HOME/.bash_profile_secrets" ] && . "$HOME/.bash_profile_secrets"

# ==============================================================================
# ZSH CONFIGURATION
# ==============================================================================

# Enable colors
autoload -Uz colors && colors

# Enable vcs_info for git branch information
autoload -Uz vcs_info
precmd() { vcs_info }

# Configure git branch display in prompt
zstyle ':vcs_info:git:*' formats '%F{cyan}(%b)%f '
zstyle ':vcs_info:*' enable git

# Set up the prompt with colors and git info
setopt PROMPT_SUBST
PROMPT='%F{green}%~%f ${vcs_info_msg_0_}%F{yellow}λ%f '

# ==============================================================================
# ENVIRONMENT VARIABLES
# ==============================================================================

# Editor
export EDITOR=nvim

# Node version manager
export NVM_DIR="$HOME/.nvm"

# Ollama
export OLLAMA_MODEL=llama3.1:8b

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ==============================================================================
# PATH CONFIGURATION
# ==============================================================================

# Keep PATH free of duplicates
typeset -U path PATH

path=(
  $HOME/.opencode/bin
  $HOME/.local/bin
  /opt/homebrew/bin
  /usr/local/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  $path
)

# ==============================================================================
# RUNTIME INITIALIZATION
# ==============================================================================

# NVM (lazy-loaded on first `nvm` call to keep shell startup fast)
if [ -s "$NVM_DIR/nvm.sh" ]; then
  nvm() {
    unset -f nvm
    . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    nvm "$@"
  }
fi

# Zoxide (smarter cd)
eval "$(zoxide init zsh)"

# ==============================================================================
# FUNCTIONS
# ==============================================================================

# Sort file in place
sorti() {
    sort -o "$1" "$1"
}

# Open file from ripgrep results in nvim
vf() {
    rg -n --hidden --glob '!.git' "${1:-.}" | fzf | awk -F: '{print "+"$2" "$1}' | xargs -r nvim
}

# Jump to directory via fzf + zoxide
zz() {
    local d
    d="$(zoxide query -l | fzf --height=40% --reverse)" || return
    [ -n "$d" ] && z "$d"
}

# ==============================================================================
# ALIASES
# ==============================================================================

# Tool defaults
alias lk='goo -l'  # Google I'm feeling lucky
alias nosetests='nosetests --nocapture --nologcapture'
alias sedi="sed -i ''"
alias rgi='rg -i'  # case-insensitive search (rg keeps its own defaults)

# Application overrides
alias vim=nvim

# Git shortcuts
alias gd='git diff'
alias gdn='git diff --name-only | cat'
alias gdu='git ls-files --others --exclude-standard'  # List untracked files
alias gm='git merge'
alias gr='git reset'
alias grh='git reset --hard'
alias grhh='git reset --hard HEAD'
alias grho='git reset --hard "origin/$(git branch --show-current)"'
alias gl='git log'
alias gls='git ls-files'
alias glsu='git ls-files --others --exclude-standard'
alias gp='git pull'
alias gs='git status'
alias gss="git status -s | grep ^[A-Z] | awk '{ print \$2 }'"
alias gca='git commit --amend --all --no-edit'
