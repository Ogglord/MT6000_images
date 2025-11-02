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

# eth1 IP
echo -n "eth1 IP: "
ETH1_IP=$(ip -4 addr show eth1 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
if [ -n "$ETH1_IP" ]; then
    echo "$ETH1_IP"
else
    echo "Not configured"
fi

echo ""
echo "================================"
echo ""
