# DevStackTray

A system tray indicator for switching local dev services on and off without letting them start at boot.
It talks to systemd, shows the state of each service in the tray icon, and lets you start or stop everything
at once or one service at a time.

The icon is a 2x2 grid with one square per service:

| Color | Meaning |
|-------|---------|
| Green | running |
| Grey  | stopped |
| Amber | starting, stopping or reloading |
| Red   | failed  |

Right-click (or left-click) the icon for a menu with **Start all**, **Stop all** and a checkbox per service.
Hover the icon to see every service's state.

The default services are `postgresql`, `valkey`, `php-fpm` and `nginx`.

## Setup from scratch

These steps assume Arch Linux with KDE Plasma. Other distributions and desktops work as long as the desktop
shows StatusNotifierItem tray icons and the packages below have equivalents.

### 1. Install the services and PyQt6

```sh
sudo pacman -S nginx php php-fpm postgresql valkey python-pyqt6
```

PostgreSQL needs its data directory initialised once:

```sh
sudo -iu postgres initdb --locale=C.UTF-8 -E UTF8 -D /var/lib/postgres/data
```

### 2. Keep the services off at boot

The tray toggles services on demand, so they should not be enabled:

```sh
sudo systemctl disable nginx php-fpm postgresql valkey
```

### 3. Get the code and install the indicator

```sh
git clone git@github.com:WentTheFox/DevStackTray.git ~/git/WentTheFox/DevStackTray
cd ~/git/WentTheFox/DevStackTray
./install.sh
```

`install.sh` symlinks `dev-stack-tray` into `~/.local/bin` and adds an autostart entry, so the indicator
starts with your desktop session. Launch it right away without logging out again:

```sh
~/.local/bin/dev-stack-tray
```

### 4. Allow toggling without a password (optional)

By default each start or stop asks for authentication through polkit. To skip the prompt for the listed
services, edit `polkit/50-dev-stack.rules` and set your user name, then install it:

```sh
sudo install -m 644 polkit/50-dev-stack.rules /etc/polkit-1/rules.d/
```

The rule only covers the local, active session of that user, the four units listed in the file, and the
`start`, `stop` and `restart` actions.

## Changing the services

Edit the `SERVICES` list at the top of `dev-stack-tray`. Each entry is a systemd unit name (without
`.service`) and the label shown in the menu. If you change the list, update the `units` array in
`polkit/50-dev-stack.rules` to match.

## Uninstall

```sh
rm ~/.local/bin/dev-stack-tray ~/.config/autostart/dev-stack-tray.desktop
sudo rm -f /etc/polkit-1/rules.d/50-dev-stack.rules
```

## License

MIT
