#!/bin/bash

if zenity --question \
  --title="Confirm Reboot" \
  --text="Reboot this machine now?" \
  --ok-label="Reboot" \
  --cancel-label="Cancel"; then
  sudo shutdown -r now
fi
