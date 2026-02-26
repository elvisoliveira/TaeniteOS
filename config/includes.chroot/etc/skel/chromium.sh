#!/bin/bash

exec chromium \
  --password-store=basic \
  --disable-print-preview \
  --start-maximized
