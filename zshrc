# ==============================================================================
# SECRETS & ENVIRONMENT SETUP
# ==============================================================================

# Source secrets
test -f ~/.bash_profile_secrets && . ~/.bash_profile_secrets

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

# Path shortcuts
export CLOUD=$HOME/Dropbox/plycion/cloud

# Android
export ANDROID_HOME=/Users/Itai/Library/Android/sdk
export ANDROID_NDK_HOME=/Users/Itai/Library/Android/sdk/ndk-bundle
export ANDROID_BUILD=assembleGoogleNowearableDefaultbrandDebug

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

# Standard PATH
export PATH=/usr/bin
export PATH=$PATH:/bin
export PATH=$PATH:/usr/sbin
export PATH=$PATH:/sbin
export PATH=$PATH:/usr/local/bin

# Homebrew (Intel)
export PATH="/usr/local/bin:$PATH"

# Homebrew (Apple Silicon)
export PATH="/opt/homebrew/bin:$PATH"

# User binaries
export PATH=$PATH:~/bin

# Android SDK
export PATH=$PATH:/Users/Itai/Desktop/android/android-sdk-macosx/tools
export PATH=$PATH:/Users/Itai/Desktop/android/android-sdk-macosx/platform-tools

# Maven
export PATH=$PATH:/usr/local/bin/maven/bin

# ==============================================================================
# RUNTIME INITIALIZATION
# ==============================================================================

# Launch control environment setup (for Android Studio via Finder)
launchctl setenv PATH $PATH
launchctl setenv ANDROID_NDK_HOME $ANDROID_NDK_HOME

# Node version manager (nodenv)
which nodenv >/dev/null && eval "$(nodenv init -)"

# NVM
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

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

# Project navigation
alias d2='cd ~/Documents/code/duolingo-2 && . .pyenv/bin/activate'
alias dios='cd ~/Documents/code/duolingo-ios'
alias dandroid='cd ~/Documents/code/duolingo-android'
alias dweb='cd ~/Documents/code/duolingo-web'
alias dt='cd ~/Documents/code/athena-backend'

# Tool defaults
alias lk='goo -l'  # Google I'm feeling lucky
alias nosetests='nosetests --nocapture --nologcapture'
alias sedi="sed -i ''"
alias rg='rg -i'

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
alias grho='git reset --hard origin/`git_branch`'
alias gl='git log'
alias gls='git ls-files'
alias glsu='git ls-files --others --exclude-standard'
alias gp='git pull'
alias gs='git status'
alias gss="git status -s | grep ^[A-Z] | awk '{ print \$2 }'"
alias gca='git commit --amend --all --no-edit'
