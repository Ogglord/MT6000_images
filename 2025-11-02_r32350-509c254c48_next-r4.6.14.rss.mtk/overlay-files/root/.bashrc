#!/bin/bash
# .bashrc - Bash configuration with bash-it framework

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Bash-it installation directory
export BASH_IT="$HOME/.bash_it"

# Install bash-it if not present (interactive shells only)
if [[ $- == *i* ]] && [[ ! -d "$BASH_IT" ]]; then
    echo "bash-it framework not found. Installing..."
    if command -v git &> /dev/null; then
        git clone --depth=1 https://github.com/Bash-it/bash-it.git "$BASH_IT"
        if [[ $? -eq 0 ]]; then
            echo "bash-it installed successfully!"
            echo "Running initial setup..."
            "$BASH_IT/install.sh" --silent --no-modify-config
            echo "Please restart your shell or run: source ~/.bashrc"
        else
            echo "Failed to clone bash-it repository"
        fi
    else
        echo "Error: git is not installed. Please install git to use bash-it."
    fi
fi

# Load bash-it if installed
if [[ -d "$BASH_IT" ]]; then
    # Lock and Load a custom theme file.
    # Leave empty to disable theming.
    # location /.bash_it/themes/
    export BASH_IT_THEME='barbuk'

    # Set this to false to turn off version control status checking within the prompt for all themes
    export SCM_CHECK=true

    # Set this to false to turn off git status checking
    export SCM_GIT_SHOW_MINIMAL_INFO=false

    # Don't check mail when opening terminal.
    unset MAILCHECK

    # Set this to the command you use to start your editor
    export EDITOR='nano'   

    # Set this to the command you use for todo.txt-cli
    export TODO="t"

    # Set this to false to disable automatic update checks
    export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=true

    # Set Xterm/screen/Tmux title with only a short hostname.
    export SHORT_HOSTNAME=$(hostname -s)

    # Set Xterm/screen/Tmux title with only a short username.
    export SHORT_USER=${USER:0:8}

    # Set Xterm/screen/Tmux title with shortened command and directory.
    export SHORT_TERM_LINE=true

    # Set vcprompt executable path for scm advance info in prompt (demula theme)
    # https://github.com/djl/vcprompt
    #export VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

    # (Advanced): Uncomment this to make Bash-it reload itself automatically
    # after enabling or disabling aliases, plugins, and completions.
    # export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

    # Load Bash It
    source "$BASH_IT/bash_it.sh"

    # Enable bash-it components on first run
    # To enable plugins, aliases, and completions, use the bash-it command:
    # Examples:
    #   bash-it enable plugin git ssh sudo history
    #   bash-it enable alias general git
    #   bash-it enable completion git ssh system
    #
    # Or enable them programmatically on first run:
    if [ ! -f "$HOME/.bash_it_configured" ]; then
        # Enable commonly used plugins
        bash-it enable plugin base git ssh sudo history history-search 2>/dev/null

        # Enable useful aliases
        bash-it enable alias general git 2>/dev/null

        # Enable completions
        bash-it enable completion git ssh system 2>/dev/null

        # Mark as configured
        touch "$HOME/.bash_it_configured"
    fi
fi

# History configuration
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend

# Check window size after each command
shopt -s checkwinsize

# Enable ** pattern in pathname expansion
shopt -s globstar 2> /dev/null

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable color support for ls and other commands
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Custom aliases (in addition to bash-it aliases)
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'


# Add local bin to PATH if it exists
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Add user bin to PATH if it exists
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

# Source local bashrc if it exists
if [ -f "$HOME/.bashrc.local" ]; then
    source "$HOME/.bashrc.local"
fi

# OpenWRT specific settings (if applicable)
if [ -f /etc/openwrt_release ]; then
    # Add OpenWRT specific configurations here
    export PS1_HOSTNAME_COLOR="\[\033[01;32m\]"
fi
