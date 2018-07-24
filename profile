# Source secrets
test -f ~/.bash_profile_secrets && . ~/.bash_profile_secrets

# Display git branch inside git project directories
git_branch() {
    branch=$(git branch 2>/dev/null | sed '/^ /d; s/^* //g')
    test "$branch" && echo "$branch "
}
export PS1="\$(git_branch)λ "

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
alias gss='git status -s | grep ^A'
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

# Load nvm
export NVM_DIR="/Users/itai/.nvm"
test -s "$NVM_DIR/nvm.sh" & . "$NVM_DIR/nvm.sh"
