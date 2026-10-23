#!/usr/bin/env bash
# Link the tray script into ~/.local/bin, add an application menu entry and start it with the desktop session.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bin_dir="${HOME}/.local/bin"
autostart_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/autostart"
applications_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/applications"

mkdir -p "${bin_dir}" "${autostart_dir}" "${applications_dir}"
ln -sfn "${repo_dir}/dev-stack-tray" "${bin_dir}/dev-stack-tray"

cat > "${applications_dir}/dev-stack-tray.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Dev Stack Tray
Comment=Toggle nginx, PHP-FPM, PostgreSQL, Valkey and OpenSearch from the system tray
Exec=${bin_dir}/dev-stack-tray
Icon=preferences-system-services
Terminal=false
Categories=Development;
DESKTOP

cat > "${autostart_dir}/dev-stack-tray.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Dev Stack Tray
Comment=Toggle nginx, PHP-FPM, PostgreSQL, Valkey and OpenSearch from the system tray
Exec=${bin_dir}/dev-stack-tray
Icon=preferences-system-services
Terminal=false
X-KDE-autostart-after=panel
DESKTOP

rules_target="/etc/polkit-1/rules.d/50-dev-stack.rules"
read -r -p "Allow ${USER} to start/stop the services without a password (installs ${rules_target} with sudo)? [y/N] " answer || answer=""
if [[ "${answer}" =~ ^[Yy]$ ]]; then
    units_json="$("${repo_dir}/dev-stack-tray" --list-units | sed 's/.*/"&"/' | paste -sd, | sed 's/^/[/; s/$/]/')"
    sed -e "s/@USER@/${USER}/g" -e "s/@UNITS@/${units_json}/" "${repo_dir}/polkit/50-dev-stack.rules" | sudo tee "${rules_target}" >/dev/null
    echo "Installed polkit rule."
fi

echo "Installed. Start it now with: ${bin_dir}/dev-stack-tray"
