# OpenWRT Firmware Builds for MT6000

Custom OpenWRT firmware builds for the GL.iNet MT6000 (Flint 2) router.

## Source

Built from the fork: https://github.com/pesa1234/openwrt

## Repository Structure

Each firmware build is stored in a separate directory with the following structure:

```
targets/
└── mediatek/
    └── filogic/
        ├── packages/          # IPK packages
        ├── *.bin              # Firmware images
        ├── *.img.gz           # Compressed images
        ├── sha256sums         # Checksums
        └── overlay-files/     # 
            ├── etc/
            │   ├── ssh/
            │   ├── profile.d/
            │   └── uci-defaults/
            └── root/
```
### Key Customizations

- **Default Shell**: Bash (Zsh included too)
- **SSH Server**: OpenSSH with compatibility for Dropbear authorized_keys
- **CLI apps**: btop, nano, chsh, tree and more
- **Tailscale**: VPN installed by default
- **SQM scripts**: SQM scripts installed by default
- **PBR**: Policy Based Routing is enabled by default

and some files added...

## Overlay Files

Each build includes the `overlay-files/` directory containing all custom configurations:

- **Shell Configuration**: Bash with bash-it framework automatically installed
- **MOTD Script**: Dynamic welcome message showing uptime, public IP, and build info
- **First-boot Scripts**: Auto-configuration scripts in `uci-defaults/` sets default shell to bash
- **Some tweaks**: `rc.local`
```
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.
# Uneven distribution is by design in DSA setups, where queues are assigned per switch port and not load-balanced via hashing as used with tc-mq
tc qdisc replace dev eth0 root fq_codel
# Resolve rx errors via ethtool -S <iface>
for ETH in eth0 eth1; do ethtool -K $ETH rx off; done
exit 0
```





## Installation

1. Download the appropriate firmware image (`.bin` or `.img.gz`)
2. Flash to your MT6000 router via:
   - Web UI: System → Backup/Flash Firmware
   - U-Boot recovery mode
   - Command line: `sysupgrade -n <firmware.bin>`

## Build Script

Build as a normal OpenWRT

Firmware builds are saved to this repo using `save-firmware.sh`




## License

OpenWRT is licensed under GPL-2.0. Custom configurations in this repository are provided as-is.

