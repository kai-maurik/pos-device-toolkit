# POS Device Toolkit (PDT)

**POS Device Toolkit**
by **Kai van Maurik**
HueCreate - [https://huecreate.nl](https://huecreate.nl)
Personal - [https://kaivanmaurik.com](https://kaivanmaurik.com)

POS Device Toolkit (PDT) is a practical, production-oriented toolkit for configuring and maintaining Linux-based Point-of-Sale (POS) devices.
It is designed to turn a standard Ubuntu installation into a **stable, kiosk-style POS workstation** with minimal ongoing maintenance.

This toolkit is used in real-world organic retail environments and prioritizes:

* reliability
* re-runnability
* explicit configuration
* low operational overhead

---

## What this toolkit does

### Firefox POS Kiosk

* Creates a dedicated **Firefox POS profile**
* Launches Firefox in **kiosk mode**
* Forces **XWayland + custom WM_CLASS** so:

  * the POS browser never merges with normal Firefox
  * taskbar icons remain separate
* Installs:

  * a `.desktop` launcher
  * automatic startup on login
  * a custom application icon
* Keeps the POS URL **outside the launcher** in a system config file

### POS URL configuration

* URL is stored in:

  ```
  /etc/pos-device/pos-url.conf
  ```
* Makes it easy to reuse the same system image for multiple shops or terminals
* No hard-coded URLs in scripts or desktop files

### PyWebDriver system service

* Installs **pywebdriver** as a systemd service
* Sets up:

  * Python virtual environment
  * dedicated system user/group
  * udev rules for USB device access
  * automatic restart on failure
* Designed to be **safe to re-run** without breaking existing setups

### GNOME Shell extension (optional)

* Installs a user-level GNOME extension
* Enables it when possible (best-effort)
* Falls back gracefully if no active GNOME session is available

---

## Supported environment

Designed and tested for:

* Ubuntu 22.04
* GNOME (Wayland)
* Firefox (Snap or Deb)
* Single-user POS terminals

Other Ubuntu-based systems may work but are not officially supported.

---

## Repository structure

```
pos-device-toolkit/
├── install.sh
├── scripts/
│   ├── pos-device-setup.sh
│   └── pywebdriver-installer.sh
└── assets/
    ├── icons/
    │   └── pos-browser.png
    └── gnome-extension/
        └── pdt@kaivanmaurik.com
```

---

## Installation

### Requirements

* Ubuntu system with GNOME
* User account with `sudo` privileges
* Internet connection

### Install

```bash
git clone https://github.com/kai-maurik/pos-device-toolkit.git
cd pos-device-toolkit
chmod +x install.sh
./install.sh
```

During installation:

* The toolkit is cloned to `/opt/posbox/pos-device-toolkit`
* Firefox POS kiosk setup is installed
* pywebdriver is installed and started
* Autostart and GNOME extension are configured

---

## Post-installation steps

### Configure POS URL

Edit the configuration file:

```bash
sudo nano /etc/pos-device/pos-url.conf
```

Example:

```bash
POS_URL="https://your-pos.example.com/web"
```

### Re-login

Log out and back in to ensure:

* autostart is activated
* GNOME extension is fully loaded

---

## Daily usage

* **POS Browser** starts automatically after login
* Normal Firefox remains available for admin tasks
* POS browser always runs in kiosk mode
* Services automatically recover after crashes

---

## Re-running the installers

All scripts are designed to be **re-runnable**:

* Existing profiles are preserved
* Config files are not overwritten if already present
* Services and launchers are safely updated

This allows:

* recovery after partial failures
* iterative improvements
* system maintenance without reinstallation

---

## Maintenance & debugging

### Check pywebdriver service

```bash
sudo systemctl status pywebdriver.service
```

### View logs

```bash
sudo journalctl -u pywebdriver.service -f
```

### Disable POS autostart (temporary)

```bash
rm ~/.config/autostart/firefox-pos.desktop
```

---

## Design philosophy

* POS systems should behave like **appliances**
* Explicit configuration over hidden state
* Clear separation between:

  * system state (`/etc`, `/opt`)
  * user state (`~/.local`, `~/.config`)
* Safe defaults and predictable behavior
* Minimal manual intervention after setup

---

## License

This project is licensed under the **PDT Program Licence (Non-Commercial Use)**.

### PDT Program Licence (Non-Commercial Use)

Copyright © 2025
**De Nieuwe Graanschuur**, Amersfoort, The Netherlands.
All rights reserved.

See `LICENSE.txt` for the full licence text.

---

## Author

**Kai van Maurik**
HueCreate - [https://huecreate.nl](https://huecreate.nl)
Personal - [https://kaivanmaurik.com](https://kaivanmaurik.com)
GitHub - [https://github.com/kai-maurik](https://github.com/kai-maurik)