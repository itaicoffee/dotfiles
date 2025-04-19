# Source secrets
test -f ~/.bash_profile_secrets && . ~/.bash_profile_secrets

# Enable colors
autoload -Uz colors && colors

# Enable vcs_info for git branch information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats '%F{cyan}(%b)%f '
zstyle ':vcs_info:*' enable git

# Set up the prompt with colors and git info
setopt PROMPT_SUBST
PROMPT='%F{green}%~%f ${vcs_info_msg_0_}%F{yellow}λ%f '

# Sort in place
sorti() {
    sort -o "$1" "$1"
}

# Aliases
alias d2='cd ~/Documents/code/duolingo-2 && . .pyenv/bin/activate'
alias dios='cd ~/Documents/code/duolingo-ios'
alias dandroid='cd ~/Documents/code/duolingo-android'
alias dweb='cd ~/Documents/code/duolingo-web'
alias dt='cd ~/Documents/code/athena-backend'
# Default arguments
alias lk='goo -l'  # Google I'm feeling lucky
alias nosetests='nosetests --nocapture --nologcapture'
alias sedi="sed -i ''"
alias rg='rg -i'
# Applications
alias vim=nvim
# Git
alias gd='git diff'
alias gdn='git diff --name-only | cat'
alias gdu='git ls-files --others --exclude-standard'  # Lists untracked files
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
alias gss="git status -s | grep ^[A-Z] | awk '{ print $2 }'"
alias gca='git commit --amend --all --no-edit'
# Path shortcuts
export CLOUD=$HOME/Dropbox/plycion/cloud

# Standard PATH
export PATH=/usr/bin
export PATH=$PATH:/bin
export PATH=$PATH:/usr/sbin
export PATH=$PATH:/sbin
export PATH=$PATH:/usr/local/bin

# Editor
export EDITOR=nvim

# Augmented PATH
export PATH=$PATH:~/bin
# export PATH=$PATH:~/Desktop/dotfiles  # Phase this out
export PATH=$PATH:/Users/Itai/Desktop/android/android-sdk-macosx/tools
export PATH=$PATH:/Users/Itai/Desktop/android/android-sdk-macosx/platform-tools
export PATH=$PATH:/usr/local/bin/maven/bin

# Android PATH
export ANDROID_HOME=/Users/Itai/Library/Android/sdk
export ANDROID_NDK_HOME=/Users/Itai/Library/Android/sdk/ndk-bundle
export ANDROID_BUILD=assembleGoogleNowearableDefaultbrandDebug

# To launch Android Studio from Finder
launchctl setenv PATH $PATH
launchctl setenv ANDROID_NDK_HOME $ANDROID_NDK_HOME

# nodenv
which nodenv >/dev/null && eval "$(nodenv init -)"
export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"  # For Apple Silicon Macs

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
