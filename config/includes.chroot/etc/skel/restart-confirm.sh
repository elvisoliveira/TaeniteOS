#!/bin/bash

if gxmessage -center -title "Confirm Reboot" \
  -buttons "Cancel:1,Reboot:0" \
  -default "Cancel" \
  "Reboot this machine now?"; then
  sudo shutdown -r now
fi
