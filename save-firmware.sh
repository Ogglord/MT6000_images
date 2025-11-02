#!/bin/bash
# Save built OpenWRT firmware to git repository
# This script moves firmware from openwrt/bin/ to MT6000_images/ and commits it

set -e

# Configuration
OPENWRT_BIN="/home/builder/openwrt/bin"
OPENWRT_FILES="/home/builder/openwrt/files"
DEST_REPO="/home/builder/MT6000_images"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if openwrt/bin directory exists
if [ ! -d "$OPENWRT_BIN" ]; then
    echo -e "${RED}Error: $OPENWRT_BIN directory not found${NC}"
    exit 1
fi

# Check if destination repository exists
if [ ! -d "$DEST_REPO" ]; then
    echo -e "${YELLOW}Destination repository $DEST_REPO not found${NC}"
    read -p "Do you want to create it and initialize as git repo? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p "$DEST_REPO"
        cd "$DEST_REPO"
        git init
        echo -e "${GREEN}Created and initialized repository at $DEST_REPO${NC}"
    else
        echo -e "${RED}Aborted${NC}"
        exit 1
    fi
fi

# Check if destination is a git repository
if [ ! -d "$DEST_REPO/.git" ]; then
    echo -e "${RED}Error: $DEST_REPO is not a git repository${NC}"
    exit 1
fi

# List available firmware folders
echo -e "${BLUE}Available firmware builds in $OPENWRT_BIN:${NC}"
echo ""

# Get list of directories in bin/
mapfile -t FIRMWARE_DIRS < <(find "$OPENWRT_BIN" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)

# Check if any firmware directories exist
if [ ${#FIRMWARE_DIRS[@]} -eq 0 ]; then
    echo -e "${RED}No firmware directories found in $OPENWRT_BIN${NC}"
    exit 1
fi

# Display numbered list of firmware directories
for i in "${!FIRMWARE_DIRS[@]}"; do
    dir="${FIRMWARE_DIRS[$i]}"
    # Get size and file count
    size=$(du -sh "$OPENWRT_BIN/$dir" 2>/dev/null | cut -f1)
    file_count=$(find "$OPENWRT_BIN/$dir" -type f | wc -l)
    printf "${GREEN}%2d)${NC} %-30s ${YELLOW}[%s, %d files]${NC}\n" $((i+1)) "$dir" "$size" "$file_count"
done

echo ""
read -p "Select firmware to save (1-${#FIRMWARE_DIRS[@]}) or 'q' to quit: " selection

# Handle quit
if [[ "$selection" == "q" ]] || [[ "$selection" == "Q" ]]; then
    echo -e "${YELLOW}Aborted${NC}"
    exit 0
fi

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#FIRMWARE_DIRS[@]} ]; then
    echo -e "${RED}Error: Invalid selection${NC}"
    exit 1
fi

# Get selected firmware directory name
SELECTED_FIRMWARE="${FIRMWARE_DIRS[$((selection-1))]}"
SOURCE_PATH="$OPENWRT_BIN/$SELECTED_FIRMWARE"
DEST_PATH="$DEST_REPO/$SELECTED_FIRMWARE"

echo ""
echo -e "${BLUE}Selected firmware:${NC} $SELECTED_FIRMWARE"
echo -e "${BLUE}Source:${NC} $SOURCE_PATH"
echo -e "${BLUE}Destination:${NC} $DEST_PATH"
echo ""

# Check if destination already exists
if [ -d "$DEST_PATH" ]; then
    echo -e "${YELLOW}Warning: $DEST_PATH already exists${NC}"
    read -p "Do you want to replace it? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Removing existing directory...${NC}"
        rm -rf "$DEST_PATH"
    else
        echo -e "${YELLOW}Aborted${NC}"
        exit 0
    fi
fi

# Confirm before proceeding
read -p "Proceed with moving firmware to git repository? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Aborted${NC}"
    exit 0
fi

# Move firmware to destination
echo -e "${GREEN}Moving firmware...${NC}"
mv "$SOURCE_PATH" "$DEST_PATH"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to move firmware${NC}"
    exit 1
fi

echo -e "${GREEN}Firmware moved successfully${NC}"

# Backup overlay files if they exist
if [ -d "$OPENWRT_FILES" ]; then
    OVERLAY_DEST="$DEST_PATH/overlay-files"
    echo -e "${GREEN}Backing up overlay files...${NC}"

    # Copy overlay files to firmware directory
    mkdir -p "$OVERLAY_DEST"
    cp -a "$OPENWRT_FILES/"* "$OVERLAY_DEST/" 2>/dev/null || true

    # Count files copied
    OVERLAY_FILE_COUNT=$(find "$OVERLAY_DEST" -type f | wc -l)
    if [ $OVERLAY_FILE_COUNT -gt 0 ]; then
        echo -e "${GREEN}Backed up $OVERLAY_FILE_COUNT overlay files to $OVERLAY_DEST${NC}"
    else
        echo -e "${YELLOW}No overlay files found to backup${NC}"
        rmdir "$OVERLAY_DEST" 2>/dev/null || true
    fi
else
    echo -e "${YELLOW}Overlay directory not found at $OPENWRT_FILES${NC}"
fi

# Change to destination repository
cd "$DEST_REPO"

# Git add the new firmware directory
echo -e "${GREEN}Adding to git...${NC}"
git add "$SELECTED_FIRMWARE"

# Prompt for commit message (with default)
DEFAULT_COMMIT_MSG="Add firmware build: $SELECTED_FIRMWARE"
echo ""
echo -e "${BLUE}Default commit message:${NC} $DEFAULT_COMMIT_MSG"
read -p "Press Enter to use default, or type custom message: " CUSTOM_MSG

if [ -z "$CUSTOM_MSG" ]; then
    COMMIT_MSG="$DEFAULT_COMMIT_MSG"
else
    COMMIT_MSG="$CUSTOM_MSG"
fi

# Commit
echo -e "${GREEN}Committing...${NC}"
git commit -m "$COMMIT_MSG"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Success!${NC}"
    echo -e "${GREEN}Firmware saved and committed to repository${NC}"
    echo -e "${BLUE}Commit message:${NC} $COMMIT_MSG"
    echo ""
    echo -e "${GREEN}Pushing...${NC}"
    git push
else
    echo -e "${RED}Error: Git commit failed${NC}"
    exit 1
fi
