#!/bin/bash

# Best-effort helper to fetch the current Wi-Fi SSID without requiring elevated
# privileges. Tries multiple strategies because Apple keeps locking down the
# simple ones (networksetup/ipconfig now return "<redacted>" on new macOS
# releases). Falls back silently if we still can't get the name so the caller
# can decide how to handle "unknown".

set -uo pipefail

IFACE="${1:-en0}"

trim_and_validate() {
  local raw="$1"
  local cleaned
  cleaned="$(printf '%s' "$raw" | tr -d '\r')"
  cleaned="$(printf '%s' "$cleaned" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  if [[ -n "$cleaned" && "$cleaned" != "<redacted>" ]]; then
    printf '%s\n' "$cleaned"
    return 0
  fi
  return 1
}

try_corewlan() {
  if ! command -v python3 >/dev/null 2>&1; then
    return 1
  fi
  python3 - "$IFACE" <<'PY'
import ctypes
import sys

iface_name = sys.argv[1] if len(sys.argv) > 1 else "en0"

try:
  objc = ctypes.cdll.LoadLibrary('/usr/lib/libobjc.A.dylib')
  ctypes.cdll.LoadLibrary('/System/Library/Frameworks/CoreWLAN.framework/CoreWLAN')
except OSError:
  sys.exit(0)

VoidP = ctypes.c_void_p
CharP = ctypes.c_char_p

objc_getClass = objc.objc_getClass
objc_getClass.restype = VoidP
objc_getClass.argtypes = [CharP]

sel_registerName = objc.sel_registerName
sel_registerName.restype = VoidP
sel_registerName.argtypes = [CharP]

objc_msgSend = objc.objc_msgSend
objc_msgSend.restype = VoidP
objc_msgSend.argtypes = [VoidP, VoidP]

objc_msgSend_c = ctypes.CFUNCTYPE(VoidP, VoidP, VoidP, VoidP)(("objc_msgSend", objc))
objc_msgSend_string = ctypes.CFUNCTYPE(CharP, VoidP, VoidP)(("objc_msgSend", objc))

CWWiFiClient = objc_getClass(b"CWWiFiClient")
if not CWWiFiClient:
  sys.exit(0)

shared_sel = sel_registerName(b"sharedWiFiClient")
client = objc_msgSend(CWWiFiClient, shared_sel)
if not client:
  sys.exit(0)

NSString = objc_getClass(b"NSString")
if not NSString:
  sys.exit(0)

str_sel = sel_registerName(b"stringWithUTF8String:")
iface_name_cf = objc_msgSend_c(NSString, str_sel, CharP(iface_name.encode("utf-8")))

iface_sel = sel_registerName(b"interfaceWithName:")
interface = objc_msgSend_c(client, iface_sel, iface_name_cf)
if not interface:
  # Fall back to the default interface if we couldn't get a named one.
  default_iface_sel = sel_registerName(b"interface")
  interface = objc_msgSend(client, default_iface_sel)
  if not interface:
    sys.exit(0)

ssid_sel = sel_registerName(b"ssid")
ssid_nsstring = objc_msgSend(interface, ssid_sel)
if not ssid_nsstring:
  sys.exit(0)

utf_sel = sel_registerName(b"UTF8String")
ssid_bytes = objc_msgSend_string(ssid_nsstring, utf_sel)
if ssid_bytes:
  sys.stdout.write(ssid_bytes.decode("utf-8"))
PY
}

try_airport() {
  local airport_cmd="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
  if [[ -x "$airport_cmd" ]]; then
    "$airport_cmd" -I 2>/dev/null | awk -F': +' '/ SSID/ {print $2; exit}'
  fi
}

try_system_profiler() {
  /usr/sbin/system_profiler SPAirPortDataType 2>/dev/null | awk -F': ' '
    /Current Network Information:/ { in_block=1; next }
    in_block && /[[:space:]]+SSID/ { print $2; exit }
  '
}

try_system_profiler_json() {
  if ! command -v python3 >/dev/null 2>&1; then
    return 1
  fi
  python3 - "$IFACE" <<'PY'
import json
import subprocess
import sys

iface = sys.argv[1] if len(sys.argv) > 1 else "en0"

try:
  raw = subprocess.check_output(
    ["/usr/sbin/system_profiler", "-json", "SPAirPortDataType"],
    stderr=subprocess.DEVNULL,
    timeout=5,
  )
except Exception:
  sys.exit(0)

try:
  data = json.loads(raw)
except Exception:
  sys.exit(0)

for airport in data.get("SPAirPortDataType", []):
  for interface in airport.get("spairport_airport_interfaces", []):
    name = interface.get("_name")
    if iface and name and iface != name:
      continue
    current = interface.get("spairport_current_network_information") or {}
    ssid = current.get("spairport_network_name") or current.get("spairport_network_ssid")
    if ssid:
      sys.stdout.write(ssid)
      sys.exit(0)
sys.exit(0)
PY
}

try_ipconfig() {
  /usr/sbin/ipconfig getsummary "$IFACE" 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2; exit}'
}

for strategy in try_corewlan try_airport try_system_profiler_json try_system_profiler try_ipconfig; do
  if result="$($strategy 2>/dev/null)"; then
    if trim_and_validate "$result"; then
      exit 0
    fi
  fi
done

exit 0
