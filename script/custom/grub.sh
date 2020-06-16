#!/bin/bash
set -e

if [[ ! "$DISABLE_BOOT_SPLASH" =~ ^(true|yes|on|1|TRUE|YES|ON)$ ]]; then
  exit
fi

grub_timeout=8

echo "==> Disabling boot splash"
echo "==> Setting grub menu timeout to $grub_timeout sec."
sed -i \
    -e '\!^GRUB_CMDLINE_LINUX_DEFAULT=!s!=.*!=""!' \
    -e '\!^GRUB_TIMEOUT=!s!=.*!='"$grub_timeout"'!' \
    /etc/default/grub
update-grub
