#!/usr/bin/env bash
set -euo pipefail

# Config - adjust if you want
PYW_DIR="/opt/posbox/pywebdriver"
RUN_SH="$PYW_DIR/run_pywebdriver.sh"
UNIT_FILE="/etc/systemd/system/pywebdriver.service"
UDEV_FILE="/etc/udev/rules.d/99-pywebdriver.rules"
# Config file hardcoded into pywebdriver
CFG_LOC="/etc/pywebdriver"

# Optional: lock to a specific branch/tag you know works
PYW_REPO="https://github.com/initOS/pywebdriver.git"
PYW_BRANCH="initOS:fix-printer-reconnect"

echo "[1/9] Install OS dependencies (build + cups + usb + python dev)"
apt update
apt install -y \
  git python3 python3-venv python3-dev \
  build-essential pkg-config \
  libffi-dev libusb-1.0-0-dev libcups2-dev \
  ca-certificates

echo "[2/9] Ensure system user/group exists"
# If your .deb already creates this user, this will just do nothing
if ! id -u pywebdriver >/dev/null 2>&1; then
  adduser --system --group --no-create-home --home /nonexistent pywebdriver
fi

echo "[3/9] Install base deb (optional, if present next to this script)"
# If you have a pywebdriver_*.deb, place it in the same folder as provision.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEB_PATH="$(ls -1 "$SCRIPT_DIR"/pywebdriver_*.deb 2>/dev/null || true)"
if [[ -n "${DEB_PATH}" ]]; then
  dpkg -i ${DEB_PATH} || apt -f install -y
fi

echo "[4/9] Clone pywebdriver into $PYW_DIR (or update if it already exists)"
mkdir -p /opt/posbox
if [[ ! -d "$PYW_DIR/.git" ]]; then
  git clone "$PYW_REPO" "$PYW_DIR"
fi
cd "$PYW_DIR"
git fetch --all --prune
# Branch name contains ":" so we handle failures gracefully
git checkout "$PYW_BRANCH" 2>/dev/null || true

echo "[5/9] Create venv and install Python deps inside venv (no sudo pip)"
python3 -m venv "$PYW_DIR/venv"
# Make sure service user can read everything
chown -R pywebdriver:pywebdriver "$PYW_DIR"

# Install deps as root but targeting venv's pip explicitly (still not "sudo pip" system-wide)
"$PYW_DIR/venv/bin/pip" install -U pip setuptools wheel
"$PYW_DIR/venv/bin/pip" install -r "$PYW_DIR/requirements.txt"
"$PYW_DIR/venv/bin/pip" install .

echo "[6/9] Ensure config exists at $CFG_LOC/config.ini"
mkdir -p "$CFG_LOC"

if [[ ! -f "$CFG_LOC/config.ini" ]]; then
  cp "$PYW_DIR/config/config.ini.tmpl" "$CFG_LOC/config.ini"
  echo "Created $CFG_LOC/config.ini from template."
else
  echo "Config already exists at $CFG_LOC/config.ini; leaving untouched."
fi

chown -R pywebdriver:pywebdriver "$CFG_LOC"

echo "[7/9] Wrapper script (activates venv for systemd)"
cat >"$RUN_SH" <<'EOF'
#!/bin/bash
set -euo pipefail
source /opt/posbox/pywebdriver/venv/bin/activate
exec python /opt/posbox/pywebdriver/venv/bin/pywebdriverd \
  --config /etc/pywebdriver/config.ini
EOF
chmod +x "$RUN_SH"
chown pywebdriver:pywebdriver "$RUN_SH"

echo "[8/9] Udev rule for USB access (generic)"
# Better: replace with a specific VID/PID rule for your printer.
cat >"$UDEV_FILE" <<'EOF'
# Generic: allow pywebdriver group to access USB devices.
# For tighter security, replace with a printer-specific rule:
# SUBSYSTEM=="usb", ATTR{idVendor}=="VVVV", ATTR{idProduct}=="PPPP", MODE="0660", GROUP="pywebdriver"
SUBSYSTEM=="usb", MODE="0660", GROUP="pywebdriver", TAG+="uaccess"
EOF

udevadm control --reload-rules
udevadm trigger

echo "[9/9] systemd unit + enable"
cat >"$UNIT_FILE" <<'EOF'
[Unit]
Description=PyWebdriver
After=network.target

[Service]
User=pywebdriver
Group=pywebdriver
WorkingDirectory=/opt/posbox/pywebdriver
Environment="PATH=/opt/posbox/pywebdriver/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="PYTHONUNBUFFERED=1"
ExecStart=/opt/posbox/pywebdriver/run_pywebdriver.sh
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

# If it was masked before, unmask it
systemctl unmask pywebdriver.service >/dev/null 2>&1 || true

systemctl enable --now pywebdriver.service

echo "Done. Test with: curl -I http://127.0.0.1:8069"
echo "Logs: sudo journalctl -u pywebdriver.service -f"
