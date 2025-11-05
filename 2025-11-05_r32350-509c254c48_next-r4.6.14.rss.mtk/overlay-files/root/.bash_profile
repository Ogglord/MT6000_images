# ~/.bash_profile
# Guard against recursive sourcing
[ -n "$BASHPROFILE_SOURCED" ] && return 0
export BASHPROFILE_SOURCED=1

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi