#!/usr/bin/env bash
# Link the tray script into ~/.local/bin and register it to start with the desktop session.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bin_dir="${HOME}/.local/bin"
autostart_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/autostart"

mkdir -p "${bin_dir}" "${autostart_dir}"
ln -sfn "${repo_dir}/dev-stack-tray" "${bin_dir}/dev-stack-tray"

cat > "${autostart_dir}/dev-stack-tray.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Dev Stack Tray
Comment=Toggle nginx, PHP-FPM, PostgreSQL, Valkey and Elasticsearch from the system tray
Exec=${bin_dir}/dev-stack-tray
Icon=preferences-system-services
Terminal=false
X-KDE-autostart-after=panel
DESKTOP

echo "Installed. Start it now with: ${bin_dir}/dev-stack-tray"
