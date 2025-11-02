#!/bin/sh
# Dynamic MOTD script for OpenWRT
# Displays welcome message, public IP, uptime, and build info on SSH login

# Skip if not interactive
[ -z "$PS1" ] && return

# Uptime
echo -n "Uptime: "
uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}' | sed 's/^[[:space:]]*//'

# Custom build info
if [ -x /usr/local/bin/build-info ]; then
    echo ""
    /usr/local/bin/build-info
fi

# Public IP
echo -n "Public IP: "
PUBLIC_IP=$(wget -qO- --timeout=3 ifconfig.me 2>/dev/null || curl -s --max-time 3 ifconfig.me 2>/dev/null)
if [ -n "$PUBLIC_IP" ]; then
    echo "$PUBLIC_IP"
else
    echo "Unable to fetch"
fi

echo ""
echo "================================"
echo ""
