#!/bin/sh
# Switch to zsh for interactive shells (only if current shell is ash)

# Only switch to zsh if:
# - This is an interactive shell
# - zsh is installed
# - Current shell is ash (not bash or other shells)
# - Not already running zsh
if [ -n "$PS1" ] && [ -x /usr/bin/zsh ] && [ "$SHELL" = "/bin/ash" ]; then
    export SHELL=/usr/bin/zsh
    export ZDOTDIR=/etc/zsh
    exec /usr/bin/zsh
fi
