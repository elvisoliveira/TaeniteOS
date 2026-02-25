#!/bin/bash

if gxmessage -center -title "Confirm Shutdown" \
  -buttons "Cancel:1,Shutdown:0" \
  -default "Cancel" \
  "Shut down this machine now?"; then
  sudo shutdown -h now
fi
