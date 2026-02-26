#!/usr/bin/env python3

import re
import subprocess
import sys
from typing import List, Optional

def run(cmd: List[str], check: bool = False, capture_output: bool = False) -> subprocess.CompletedProcess:
  return subprocess.run(
    cmd,
    check=check,
    text=True,
    capture_output=capture_output,
  )

def is_valid_ipv4(value: str) -> bool:
  parts = value.split(".")
  if len(parts) != 4:
    return False
  for part in parts:
    if not part.isdigit():
      return False
    octet = int(part)
    if octet < 0 or octet > 255:
      return False
  return True

def ask_ipv4(prompt: str) -> str:
  while True:
    value = input(f"{prompt}: ").strip()
    if is_valid_ipv4(value):
      return value
    print("Please enter a valid IPv4 address (example: 192.168.1.100).")

def list_configured_printers() -> List[str]:
  result = run(["/usr/bin/lpstat", "-p"], capture_output=True)
  names: List[str] = []
  for line in result.stdout.splitlines():
    if not line.startswith("printer "):
      continue
    parts = line.split()
    if len(parts) < 2:
      continue
    queue = parts[1]
    if "LaserJet" in queue:
      continue
    names.append(queue)
  return names

def remove_existing_printers() -> None:
  for queue in list_configured_printers():
    run(["/usr/sbin/lpadmin", "-x", queue])

def enable_printer_queue(queue: str) -> None:
  print(f"Enabling {queue}")
  run(["/usr/sbin/cupsaccept", queue], check=True)
  run(["/usr/sbin/cupsenable", queue], check=True)

def fetch_network_printer_model(ip_address: str) -> str:
  result = run(
    [
      "snmpwalk",
      "-v",
      "1",
      "-c",
      "public",
      "-O",
      "v",
      ip_address,
      "iso.3.6.1.2.1.25.3.2.1.3.1",
    ],
    capture_output=True,
  )
  match = re.search(r'"([^"]+)"', result.stdout)
  return match.group(1) if match else "Unknown model"

def printer_exists(queue: str) -> bool:
  result = run(["/usr/bin/lpstat", "-p", queue])
  return result.returncode == 0

def ping_host(ip_address: str) -> bool:
  result = subprocess.run(
    ["ping", "-q", "-c", "2", "-W", "1", ip_address],
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL,
  )
  return result.returncode == 0

def configure_network_shop_printer(network_printer_ip: str) -> Optional[str]:
  if not ping_host(network_printer_ip):
    print(f"{network_printer_ip} not found")
    return None

  print("Discovered ", end="")
  network_printer_model = fetch_network_printer_model(network_printer_ip)
  print(f"{network_printer_model} on the network")

  printer_queue = "ip100"
  printer_class = "shop-printer"
  run(
    [
      "/usr/sbin/lpadmin",
      "-E",
      "-p",
      printer_queue,
      "-v",
      f"ipp://{network_printer_ip}:631/ipp/print",
      "-m",
      "everywhere",
    ],
    check=True,
  )
  enable_printer_queue(printer_queue)
  print(f"{network_printer_model} Printer Added")
  print(f"Adding {network_printer_model} to shop-printer class")
  run(["/usr/sbin/lpadmin", "-p", printer_queue, "-c", printer_class], check=True)
  return printer_queue

def parse_usb_product_id() -> Optional[str]:
  result = run(["lsusb", "-d", "04b8:"], capture_output=True)
  if result.returncode != 0 or not result.stdout.strip():
    return None
  parts = result.stdout.strip().split()
  if len(parts) < 6 or ":" not in parts[5]:
    return None
  return parts[5].split(":")[1]

def parse_usb_serial_number() -> str:
  result = run(["lsusb", "-v", "-d", "04b8:"], capture_output=True)
  for line in result.stdout.splitlines():
    if "Serial" in line:
      tokens = line.strip().split()
      if tokens:
        return tokens[-1]
  return ""

def configure_thermal_printer_if_epson_present() -> None:
  if run(["lsusb", "-d", "04b8:"]).returncode != 0:
    return

  print("Epson ", end="")
  printer_queue = "thermal-printer"
  usb_product_id = parse_usb_product_id()
  usb_serial_number = parse_usb_serial_number()

  product_name = None
  if usb_product_id == "0e15":
    product_name = "TM-T20II"
  elif usb_product_id == "0e28":
    product_name = "TM-T20III"

  if not product_name:
    return

  print(f"{product_name} Discovered")
  run(
    [
      "/usr/sbin/lpadmin",
      "-E",
      "-p",
      printer_queue,
      "-v",
      f"usb://EPSON/{product_name}?serial={usb_serial_number}",
      "-P",
      "/etc/cups/ppd/tm-t20ii.ppd",
      "-u",
      "allow:all",
    ],
    check=True,
  )
  enable_printer_queue(printer_queue)
  print(f"Epson {product_name} Printer Added")


def configure_star_tsp143_if_present() -> None:
  if run(["lsusb", "-d", "0519:0003"]).returncode != 0:
    return

  printer_queue = "thermal-printer"
  print("Star TSP143 Printer discovered")
  run(
    [
      "/usr/sbin/lpadmin",
      "-E",
      "-p",
      printer_queue,
      "-v",
      "usb://Star/TSP143%20(STR_T-001)",
      "-P",
      "/etc/cups/ppd/tsp143.ppd",
      "-u",
      "allow:all",
    ],
    check=True,
  )
  enable_printer_queue(printer_queue)
  print("Star TSP143 Printer Added")

def main() -> int:
  remove_existing_printers()
  network_printer_ip = ask_ipv4("IP address for ip100 network printer")
  shop_printer_queue = configure_network_shop_printer(network_printer_ip)

  if shop_printer_queue and printer_exists(shop_printer_queue):
    enable_printer_queue("shop-printer")

  configure_thermal_printer_if_epson_present()
  configure_star_tsp143_if_present()
  return 0

if __name__ == "__main__":
  try:
    raise SystemExit(main())
  except KeyboardInterrupt:
    print()
    raise SystemExit(130)
