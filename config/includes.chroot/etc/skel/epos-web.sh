#!/bin/bash
tmpdir="/var/lib/eposnextweb_nl"
targetURL="https://epos-web-next.gke.internal.toolstation.nl/"

chromium --user-data-dir=$tmpdir --password-store=basic --disable-print-preview --start-maximized --allow-insecure-localhost --app=$targetURL
