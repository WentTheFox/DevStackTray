# DevStackTray

A system tray indicator for switching local dev services on and off without letting them start at boot.
It talks to systemd, shows the state of each service in the tray icon, and lets you start or stop everything
at once or one service at a time.

The icon is a grid with one square per service:

| Color | Meaning |
|-------|---------|
| Green | running |
| Grey  | stopped |
| Amber | starting, stopping or reloading |
| Red   | failed  |

Right-click (or left-click) the icon for a menu with **Start all**, **Stop all** and a checkbox per service.
Hover the icon to see every service's state.

The default services are `postgresql`, `valkey`, `php-fpm`, `nginx` and `opensearch`.

## Setup from scratch

These steps assume Arch Linux with KDE Plasma. Other distributions and desktops work as long as the desktop
shows StatusNotifierItem tray icons and the packages below have equivalents.

### 1. Install the services and PyQt6

```sh
sudo pacman -S nginx php php-fpm postgresql valkey opensearch python-pyqt6
```

OpenSearch is the Apache-licensed fork of Elasticsearch and is API-compatible for most dev use. Recent
Elasticsearch client libraries may refuse to talk to it, so use the OpenSearch client if that happens.
Drop it from `SERVICES` if you don't need it. It needs a fair amount of RAM, which is a good reason to keep
it off until you need it.

PostgreSQL needs its data directory initialised once:

```sh
sudo -iu postgres initdb --locale=C.UTF-8 -E UTF8 -D /var/lib/postgres/data
```

### 2. Keep the services off at boot

The tray toggles services on demand, so they should not be enabled:

```sh
sudo systemctl disable nginx php-fpm postgresql valkey opensearch
```

### 3. Get the code and install the indicator

```sh
git clone git@github.com:WentTheFox/DevStackTray.git ~/git/WentTheFox/DevStackTray
cd ~/git/WentTheFox/DevStackTray
./install.sh
```

`install.sh` symlinks `dev-stack-tray` into `~/.local/bin` and adds an application menu entry and an autostart entry, so the indicator
starts with your desktop session. Launch it right away without logging out again:

```sh
~/.local/bin/dev-stack-tray
```

### 4. Allow toggling without a password (optional)

By default each start or stop asks for authentication through polkit. To skip the prompt for the listed
services, answer `y` when `install.sh` asks about it, or install the rule by hand with your user name substituted for the `@USER@` placeholder:

```sh
sed "s/@USER@/$USER/g" polkit/50-dev-stack.rules | sudo tee /etc/polkit-1/rules.d/50-dev-stack.rules >/dev/null
```

The rule only covers the local, active session of that user, the units listed in the file, and the
`start`, `stop` and `restart` actions.

## Changing the services

To add your own services without touching the tracked code, copy the example to an untracked file:

```sh
cp services.example.txt services.local.txt
```

`services.local.txt` is git-ignored and holds one service per line as `unit Label`, with `#` comments allowed
(the example adds `jellyfin-server`). They are appended after the defaults; restart the indicator to
pick up changes. Re-run `./install.sh` and answer `y` to the polkit prompt so the passwordless rule covers the new units.

To change the built-in defaults, edit the `SERVICES` list at the top of `dev-stack-tray`.

## Uninstall

```sh
rm ~/.local/bin/dev-stack-tray ~/.config/autostart/dev-stack-tray.desktop ~/.local/share/applications/dev-stack-tray.desktop
sudo rm -f /etc/polkit-1/rules.d/50-dev-stack.rules
```

## License

MIT
