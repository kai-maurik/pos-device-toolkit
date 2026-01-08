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

log ""
log "Install complete - POS Device Toolkit"
log ""
log "Repo location:"
log "- ${TARGET_DIR}"
log ""
log "Firefox POS kiosk:"
log "- POS URL config:      /etc/pos-device/pos-url.conf"
log "- POS launcher:        ${REAL_HOME}/.local/share/applications/firefox-pos.desktop"
log "- Autostart:           ${REAL_HOME}/.config/autostart/firefox-pos.desktop"
log "- Wrapper:             /usr/local/bin/pos-firefox"
log "- Icon:                /usr/local/share/icons/hicolor/256x256/apps/pos-browser.png"
log ""
log "GNOME extension:"
log "- Installed to:        ${REAL_HOME}/.local/share/gnome-shell/extensions/pdt@kaivanmaurik.com"
log "- !Enable extension    gnome-extensions enable pdt@kaivanmaurik.com"
log "- !Note: re-login required to fully activate GNOME extensions"
log ""
log "PyWebDriver service:"
log "- Install dir:         /opt/posbox/pywebdriver"
log "- Config:              /etc/pywebdriver/config.ini"
log "- Service:             /etc/systemd/system/pywebdriver.service"
log "- Logs:                sudo journalctl -u pywebdriver.service -f"
log "- Status:              sudo systemctl status pywebdriver.service"
log ""
log "!!!!IMPORTANT!!!! Next steps:"
log "- Enable extension:    gnome-extensions enable pdt@kaivanmaurik.com"
log "- Set POS URL:         sudo nano /etc/pos-device/pos-url.conf"
log "- Re-login to apply autostart and GNOME extension changes"
log ""
