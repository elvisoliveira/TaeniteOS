#!/bin/bash
chromium_version=`chromium --product-version`
user_agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chrome/$chromium_version $HOSTNAME ab"
tmpdir=/tmp/chrome_extranet
trap "rm -rf $tmpdir" EXIT
mkdir $tmpdir
touch "$tmpdir/First Run"
targetURL="https://extranet.toolstation.nl/v2.1/index.html"
chromium --user-agent="$user_agent" --user-data-dir=$tmpdir --password-store=basic --disable-print-preview --window-size=1024,1024 --app=$targetURL