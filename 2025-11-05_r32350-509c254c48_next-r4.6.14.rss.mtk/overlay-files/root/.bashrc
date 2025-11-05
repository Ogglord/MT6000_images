#!/bin/bash
# .bashrc - Bash configuration with bash-it framework

# Guard against recursive sourcing
[ -n "$BASHRC_SOURCED" ] && return 0
export BASHRC_SOURCED=1

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# set history file, right
export HISTFILE="$HOME/.bash_history"

# Bash-it installation directory
export BASH_IT="$HOME/.bash_it"

# Install bash-it if not present (interactive shells only)
# Safe installation with network checks and non-blocking behavior
if [[ $- == *i* ]] && [[ ! -d "$BASH_IT" ]]; then
    # Check if git is available
    if ! command -v git &> /dev/null; then
        echo "Note: git not found. bash-it will not be installed."
        echo "Install git to enable bash-it framework: opkg install git-http"
        return 0
    fi
    
    # Quick network connectivity check (non-blocking)
    # Try multiple methods with short timeouts
    local network_ok=false
    if command -v timeout >/dev/null 2>&1; then
        # Use timeout if available (BusyBox timeout)
        timeout 2 getent hosts github.com >/dev/null 2>&1 && network_ok=true
        [[ "$network_ok" == false ]] && timeout 2 ping -c 1 -W 1 github.com >/dev/null 2>&1 && network_ok=true
    else
        # Fallback: quick DNS check without timeout (should be fast or fail quickly)
        # Use background process to avoid blocking
        (getent hosts github.com >/dev/null 2>&1 || ping -c 1 -W 2 github.com >/dev/null 2>&1) && network_ok=true
    fi
    
    if [[ "$network_ok" == false ]]; then
        echo "Note: Network connectivity check failed. bash-it installation skipped."
        echo "bash-it will be installed automatically when network is available."
        return 0
    fi
    
    echo "bash-it framework not found. Installing..."
    echo "This may take a moment (downloading from github.com)..."
    
    # Clone with limited output and error handling
    # Use background process approach if timeout not available for better control
    local clone_success=false
    if command -v timeout >/dev/null 2>&1; then
        # Use timeout if available (30 seconds max)
        if timeout 30 git clone --depth=1 --quiet https://github.com/Bash-it/bash-it.git "$BASH_IT" 2>&1; then
            clone_success=true
        else
            local clone_status=$?
            if [[ $clone_status -eq 124 ]]; then
                echo "Warning: bash-it installation timed out (network may be slow)"
                [[ -d "$BASH_IT" ]] && rm -rf "$BASH_IT" 2>/dev/null
            fi
        fi
    else
        # Fallback: run normally but with quiet flag and error handling
        # Git has built-in timeout behavior, won't hang indefinitely
        if git clone --depth=1 --quiet https://github.com/Bash-it/bash-it.git "$BASH_IT" 2>&1; then
            clone_success=true
        fi
    fi
    
    if [[ "$clone_success" == true ]] && [[ -d "$BASH_IT" ]]; then
        echo "bash-it installed successfully!"
        echo "Running initial setup..."
        # Run install script (with timeout if available)
        if command -v timeout >/dev/null 2>&1; then
            timeout 10 "$BASH_IT/install.sh" --silent --no-modify-config 2>/dev/null || true
        else
            "$BASH_IT/install.sh" --silent --no-modify-config 2>/dev/null || true
        fi
        echo "bash-it ready! Restart shell or run: source ~/.bashrc"
    else
        echo "Note: bash-it installation failed (network issue or git error)"
        # Clean up partial clone
        [[ -d "$BASH_IT" ]] && rm -rf "$BASH_IT" 2>/dev/null
        echo "bash-it will be installed automatically on next shell startup when ready"
    fi
fi

# Load bash-it if installed
if [[ -d "$BASH_IT" ]]; then
    # Lock and Load a custom theme file.
    # Leave empty to disable theming.
    # location /.bash_it/themes/
    export BASH_IT_THEME='barbuk'

    # Set this to false to turn off version control status checking within the prompt for all themes
    export SCM_CHECK=false

    # Set this to false to turn off git status checking
    export SCM_GIT_SHOW_MINIMAL_INFO=true

    # Don't check mail when opening terminal.
    unset MAILCHECK

    # Set this to the command you use to start your editor
    export EDITOR='nano'   

    # Set this to the command you use for todo.txt-cli
    export TODO="t"

    # Set this to false to disable automatic update checks
    export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=false

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

    # Load Bash It (with loop protection)
    # Prevent bash-it from sourcing bashrc/bash_profile again
    export BASH_IT_NO_BASHRC=1
    export BASH_IT_NO_BASH_PROFILE=1
    if [ -f "$BASH_IT/bash_it.sh" ]; then
        if ! source "$BASH_IT/bash_it.sh" 2>/dev/null; then
            echo "Warning: Error loading bash-it, continuing without it"
        fi
    fi

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
