#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/kai-maurik/pos-device-toolkit.git"
REPO_DIR="/opt/posbox"
TARGET_DIR="${REPO_DIR}/pos-device-toolkit"

log() { printf "%s\n" "$*"; }
die() { printf "ERROR: %s\n" "$*" >&2; exit 1; }

# Determine the "real" desktop user and home, even if invoked via sudo
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

[[ "$REAL_USER" != "root" ]] || die "Run this as a normal user (sudo from that user is OK), not as root directly."

# Basic deps
command -v git >/dev/null 2>&1 || die "git is not installed. Install it first: sudo apt-get update && sudo apt-get install -y git"

log "Installing pos-device-toolkit for user: $REAL_USER"
log "User home: $REAL_HOME"

# Clone or update into the destination folder
sudo mkdir -p "$REPO_DIR"

if [[ -d "$TARGET_DIR/.git" ]]; then
  log "Repo exists. Updating..."
  sudo git -C "$TARGET_DIR" pull --ff-only
else
  log "Cloning repo..."
  sudo git clone "$REPO_URL" "$TARGET_DIR"
fi

# Ensure scripts are executable
sudo chmod +x \
  "$TARGET_DIR/scripts/pos-device-setup.sh" \
  "$TARGET_DIR/scripts/pywebdriver-installer.sh"

# Run installers (pos-device-setup likely needs sudo for /etc, /usr/local, icon cache, etc.)
log "Running pos-device-setup.sh..."
sudo -u "$REAL_USER" sudo -E "$TARGET_DIR/scripts/pos-device-setup.sh"

log "Running pywebdriver-installer.sh..."
sudo -u "$REAL_USER" sudo -E "$TARGET_DIR/scripts/pywebdriver-installer.sh"

log "Done."
log "Keeping repo at $TARGET_DIR";
