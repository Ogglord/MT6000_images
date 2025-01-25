# Check if oh-my-zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh not found. Installing..."
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-completions.git ~/.oh-my-zsh/custom/plugins/zsh-completions
    git clone https://github.com/zsh-users/zsh-history-substring-search.git ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search
    chmod go-w -R .oh-my-zsh
fi

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"
export ZSH_DISABLE_COMPFIX="true"
# Set theme (change to your preferred theme)
ZSH_THEME="robbyrussell"

# Enable plugins (add or remove plugins as needed)
plugins=(
        git
        z
        zsh-autosuggestions
        zsh-completions
        zsh-history-substring-search
        zsh-syntax-highlighting
)
# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Aliases
alias ll='ls -lh'
alias la='ls -lAh'
alias ..='cd ..'
alias btop="btop --utf-force"

# Editor
export EDITOR="nano"

# Add custom PATH
export PATH="$HOME/bin:/usr/local/bin:$PATH"

# History settings
HISTSIZE=1000
SAVEHIST=2000
HISTFILE=~/.zsh_history
setopt appendhistory

# Prompt
autoload -Uz promptinit
promptinit

# Completion
compaudit | xargs chmod go-w 2>/dev/null
autoload -Uz compinit && compinit
