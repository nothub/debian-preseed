#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

files_url="https://nothub.github.io/debian-autoinstall/files"
ssh_keys_url="https://github.com/nothub.keys"

# find user (from default userid)
user=$(id -u -n -- "1000")
user_home=$(getent passwd "${user}" | cut -d: -f6)

# expire user passwort (requires password to be defined on next login)
passwd --delete "${user}"
passwd --expire "${user}"

# download some config
curl -fslo "/etc/ssh/sshd_config" "${files_url}/sshd_config"
curl -fslo "${user_home}/.bashrc" "${files_url}/bashrc"

# authorize ssh login
mkdir -p "${user_home}/.ssh"
chmod 700 "${user_home}/.ssh"
curl -fslo "${user_home}/.ssh/authorized_keys" "${ssh_keys_url}"
chmod 644 "${user_home}/.ssh/authorized_keys"

# reset user homedir owner
chown -R "$(stat --format "%U:%G" "${user_home}")" "${user_home}"

# motd banner
curl -fslo "/etc/motd" "${files_url}/motd"

# install docker
curl -fsl https://get.docker.com | sh -s

# install nix
sh <(curl -fsl https://nixos.org/nix/install) --daemon
