#!/usr/bin/env bash
set -euo pipefail

# Creates:
# - Firefox profile "POS" (kiosk), with .desktop launcher with separate taskbar grouping on Wayland (via XWayland + WM_CLASS)
# - A wrapper script for the launcher.
# - An auto start launching for the .desktop launcher
# - A config file to customize the behaviour

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

POS_PROFILE="POS"
POS_CLASS="FirefoxPOS"

POS_CONF_DIR="/etc/pos-device"
POS_CONF_FILE="${POS_CONF_DIR}/pos-url.conf"
POS_WRAPPER="/usr/local/bin/pos-firefox"

APP_DIR="${REAL_HOME}/.local/share/applications"
POS_DESKTOP="${APP_DIR}/firefox-pos.desktop"
AUTOSTART_DIR="${REAL_HOME}/.config/autostart"
AUTOSTART_DESKTOP="${AUTOSTART_DIR}/firefox-pos.desktop"

ICON_SRC="${PROJECT_ROOT}/assets/icons/pos-browser.png"
ICON_DST="/usr/local/share/icons/hicolor/256x256/apps/pos-browser.png"

log() { printf "%s\n" "$*"; }
die() { printf "ERROR: %s\n" "$*" >&2; exit 1; }

[[ "$REAL_USER" != "root" ]] || die "Run this as a normal user (sudo from that user is OK), not as root directly."

# 1) Sanity checks
if pgrep -x firefox >/dev/null 2>&1; then
  die "Firefox is running. Close all Firefox windows and try again."
fi

command -v firefox >/dev/null 2>&1 || die "firefox not found in PATH."

# 2) Detect Snap vs Deb and choose command
FIREFOX_BIN="$(command -v firefox)"
FIREFOX_CMD="firefox"
if command -v snap >/dev/null 2>&1 && snap list 2>/dev/null | awk '{print $1}' | grep -qx "firefox"; then
  # On Ubuntu 22.04, firefox is often a snap. Using snap run can be more reliable in launchers.
  FIREFOX_CMD="snap run firefox"
fi

log "Using Firefox command: ${FIREFOX_CMD}"
log "Firefox binary path: ${FIREFOX_BIN}"

# 3) Ensure pos profile exists
log "Ensuring POS Firefox profile exists..."

sudo -u "$REAL_USER" bash -lc "${FIREFOX_CMD} --CreateProfile \"${POS_PROFILE}\"" >/dev/null 2>&1 || true
# --CreateProfile is idempotent; Firefox will ignore if it already exists

# 4) Install POS URL config
log "Installing POS URL config..."

sudo mkdir -p "${POS_CONF_DIR}"

if [[ ! -f "${POS_CONF_FILE}" ]]; then
  sudo tee "${POS_CONF_FILE}" >/dev/null <<EOF
# POS browser URL
# Adjust per shop / terminal
POS_URL="https://example.odoo.com/web"
EOF
  log "Created ${POS_CONF_FILE} (please edit POS_URL)"
else
  log "Config ${POS_CONF_FILE} already exists; leaving untouched."
fi

sudo chmod 644 "${POS_CONF_FILE}"

# 5) Install wrapper
log "Installing POS Firefox wrapper..."

sudo tee "${POS_WRAPPER}" >/dev/null <<EOF
#!/usr/bin/env bash
set -e

CONF_SYSTEM="${POS_CONF_FILE}"
CONF_USER="\$HOME/.config/pos-device/pos-url.conf"

if [[ -r "\$CONF_USER" ]]; then
  source "\$CONF_USER"
elif [[ -r "\$CONF_SYSTEM" ]]; then
  source "\$CONF_SYSTEM"
fi

if [[ -z "\${POS_URL:-}" ]]; then
  echo "POS_URL not set. Edit pos-url.conf." >&2
  exec env MOZ_ENABLE_WAYLAND=0 \
    ${FIREFOX_CMD} --no-remote -P "${POS_PROFILE}" --kiosk --class="${POS_CLASS}" about:blank
fi

exec env MOZ_ENABLE_WAYLAND=0 \
  ${FIREFOX_CMD} --no-remote -P "${POS_PROFILE}" --kiosk --class="${POS_CLASS}" "\$POS_URL"
EOF

sudo chmod 755 "${POS_WRAPPER}"

# 6) Creating desktop launcher
log "Creating POS desktop launcher..."

sudo -u "$REAL_USER" mkdir -p "${APP_DIR}"

sudo -u "$REAL_USER" tee "${POS_DESKTOP}" >/dev/null <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=POS Browser
Comment=Firefox POS Profile (Kiosk)
Exec=${POS_WRAPPER}
Icon=pos-browser
Terminal=false
Categories=Network;WebBrowser;
StartupWMClass=${POS_CLASS}
EOF

sudo -u "$REAL_USER" chmod 644 "${POS_DESKTOP}"

# 7) Installing icon
log "Installing POS icon..."
[[ -f "$ICON_SRC" ]] || die "Icon not found at: $ICON_SRC"

sudo install -Dm644 "$ICON_SRC" "$ICON_DST"
sudo gtk-update-icon-cache -f /usr/local/share/icons/hicolor >/dev/null 2>&1 || true

if command -v update-desktop-database >/dev/null 2>&1; then
  sudo -u "$REAL_USER" update-desktop-database "${APP_DIR}" >/dev/null 2>&1 || true
fi

# 8) Installing auto start
log "Installing POS autostart entry..."

sudo -u "$REAL_USER" mkdir -p "${AUTOSTART_DIR}"

sudo -u "$REAL_USER" tee "${AUTOSTART_DESKTOP}" >/dev/null <<EOF
[Desktop Entry]
Type=Application
Name=POS Browser
Exec=${POS_WRAPPER}
Icon=pos-browser
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=5
EOF

sudo -u "$REAL_USER" chmod 644 "${AUTOSTART_DESKTOP}"

# 9) Installing gnome extension
log "Installing GNOME extension (user-level)..."

EXT_UUID="pdt@kaivanmaurik.com"
EXT_SRC="${PROJECT_ROOT}/assets/gnome-extension/${EXT_UUID}"
EXT_BASE="${REAL_HOME}/.local/share/gnome-shell/extensions"
EXT_DST="${EXT_BASE}/${EXT_UUID}"

# Sanity check
[[ -d "$EXT_SRC" ]] || die "GNOME extension source not found: $EXT_SRC"

# Ensure extensions base directory exists
sudo -u "$REAL_USER" mkdir -p "$EXT_BASE"

# Install extension if not present
if [[ ! -d "$EXT_DST" ]]; then
  sudo -u "$REAL_USER" cp -r "$EXT_SRC" "$EXT_DST"
  log "GNOME extension copied to user directory."
else
  log "GNOME extension already installed; skipping copy."
fi

# Best-effort enable (requires active GNOME session)
if sudo -u "$REAL_USER" gnome-extensions list >/dev/null 2>&1; then
  sudo -u "$REAL_USER" gnome-extensions enable "$EXT_UUID" || \
    log "Extension installed but could not be enabled automatically (re-login required)."
else
  log "gnome-extensions command not available in this session."
fi

log "GNOME extension installed. Re-login required to fully activate."

log ""
log "Done. POS Kiosk will autostart via ${AUTOSTART_DESKTOP}."
log "Next: edit the URL in: ${POS_CONF_FILE}."
