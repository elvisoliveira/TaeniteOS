#!/usr/bin/env python3

import base64
import json
import sys


def main() -> int:
  if len(sys.argv) != 5:
    print(
      "Usage: epos-next-settings-url.py <template_json> <next_url> <shop_id> <till_id>",
      file=sys.stderr,
    )
    return 2

  template_path, next_url, shop_id, till_id = sys.argv[1:]

  with open(template_path, "r", encoding="utf-8") as f:
    settings = json.load(f)

  settings["siteId"] = shop_id
  settings["tillId"] = till_id

  settings_json = json.dumps(settings, separators=(",", ":"))
  settings_base64 = base64.b64encode(settings_json.encode("utf-8")).decode("ascii")

  print(f"{next_url.rstrip('/')}/?settings={settings_base64}")
  return 0


if __name__ == "__main__":
  raise SystemExit(main())
