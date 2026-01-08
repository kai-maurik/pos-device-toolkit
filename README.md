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

It also includes an install script for correctly setting up [PyWebdriver](https://github.com/initOS/pywebdriver/tree/fix-printer-reconnect). See the official documentation for use and credits.

* Installs **pywebdriver** as a systemd service
* Sets up:
  * Python virtual environment
  * dedicated system user/group
  * udev rules for USB device access
  * automatic restart on failure
* Designed to be **safe to re-run** without breaking existing setups

### GNOME Shell extension (optional)

The GNOME extension, compatable with an Odoo system, moves a CustomerFacingDisplay to the second monitor and full screens it if detected. It searches for the `CustomerFacingDisplay` window name on window open events.

---

## Supported environment

Designed and tested for:

* Ubuntu 22.04
* GNOME (Wayland)
* Firefox (Deb)
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
* IMPORTANT: Official firefox .deb package (NO SNAP!)

### Install

Open an empty folder, and run the following commands:
```bash
wget https://raw.githubusercontent.com/kai-maurik/pos-device-toolkit/master/install.sh
chmod +x install.sh
./install.sh
```

During installation:

* The toolkit is cloned to `/opt/posbox/pos-device-toolkit`
* Firefox POS kiosk setup is installed
* pywebdriver is installed and started
* Autostart and GNOME extension are configured

Note: both installer scripts in the `/scripts` folder can also be run seperately, to install parts of the program. For these scripts to run succesfully, make sure the `/assets` folder is included next to the `/scripts` folder where the scripts reside. Easiest way is to just clone the project and run the scripts individually.

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

### Enable extension and re-login

Run this in the terminal to activate the gnome extension, moving the customer screen to the second display:
```
gnome-extensions enable pdt@kaivanmaurik.com
```

Then log out and back in to ensure:

* autostart is activated
* GNOME extension is fully loaded

### Optional: harden KIOSK experience by disabeling firefox features

Firefox has a lot of popups enabled by default. Many of them are disabled by the wrapper, but to ensure
a fully hardened POS experience it's recommended to add more flags to the user profile.

A help file has been provided in the root of this repo to provide this. To install simply:
1. Move `user.js` to the firefox POS profile folder
2. Restart firefox

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

## A note on Firefox DEB package vs SNAP

Make sure you have the deb version installed. For convinience, the official install
instructions have been provided in the home folder of this repo.

The deb package is necesairy to ensure proper task bar splitting. If you only use this
for the kiosk mode, snap could be used in theory, but I would still recommend disabling
it and installing the proper .deb package through the official documentation.

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