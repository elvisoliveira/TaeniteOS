#!/bin/bash

if zenity --question \
  --title="Confirm Shutdown" \
  --text="Shut down this machine now?" \
  --ok-label="Shutdown" \
  --cancel-label="Cancel"; then
  sudo shutdown -h now
fi
