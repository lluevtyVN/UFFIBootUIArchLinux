#!/bin/bash
set -e
sudo pacman -Syu --noconfirm refind git
EFI_PART=$(lsblk -o NAME,FSTYPE,MOUNTPOINT | grep vfat | awk '{print $1}' | head -n1)
if [ -z "$EFI_PART" ]; then
  exit 1
fi
EFI_PATH="/boot"
if ! mount | grep -q " $EFI_PATH "; then
  sudo mount /dev/$EFI_PART $EFI_PATH
fi
sudo refind-install
sudo mkdir -p $EFI_PATH/EFI/refind/themes
cd $EFI_PATH/EFI/refind/themes
if [ ! -d "rEFInd-minimal" ]; then
  sudo git clone https://github.com/EvanPurkhiser/rEFInd-minimal.git
fi
CONF="$EFI_PATH/EFI/refind/refind.conf"
if ! grep -q "include themes/rEFInd-minimal/theme.conf" "$CONF"; then
  echo "include themes/rEFInd-minimal/theme.conf" | sudo tee -a "$CONF"
fi
sudo reboot
