<h1>POS Device Toolkit</h1>
<p>
A gnome extension and installation utils to transform a plain Ubuntu system to a closed POS system. The target platform is Ubuntu 22.04.
</p>
<h2>Components</h2>
<ul>
  <li>Gnome Extension which moves any window title containing "CustomerFacingDisplay" fullscreen to a second monitor</li>
  <li>An installation script which creates a desktop shortcut and autostart a browser in kiosk mode</li>
</ul>
<h2>Prerequisites</h2>
<ul>
  <li>GNOME Desktop Evirounment compatable with Gnome v42 extensions (example: Ubuntu 22.04)</li>
  <li>Odoo system where the popup customer display is named "CustomerFacingDisplay"</li>
  <li>Second monitor, marked as an extended display by gnome</li>
</ul>
<h2>Installation</h2>
<p>
  <ul>
    <li>Clone the project into a user folder.</li>
    <li><b>IMPORTANT: </b>Before running the install script, modify the <code>resources/pos.desktop</code> file to match your needs. You need to change the URL it's pointing to, and the name if desirable.</li>
    <li>Add executing permissions to the install script: <code>chmod +x ./install.sh</code></li>
    <li>Execute the install script: <code>./install.sh</code></li>
    <li>Log out of the system, and log back in again. A browser in kiosk mode will now open by default. You can navigate out of this by using ALT+tab, SUPER etc.</li>
    <li>Open a terminal and run the following command: <code>gnome-extensions enable pdt@kaivanmaurik.com</code></li>
    <li>Give the device a restart if nececairy.</li>
  </ul>
  If you are using a specific firefox profile to launch the POS, use the firefox-shell.desktop to launch firefox in normal mode.
</p>
