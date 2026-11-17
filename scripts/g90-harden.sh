#!/usr/bin/env bash
# g90-harden.sh - audit and reversible clean-up for the BLU G90 (model U2, Android 10)
#
# This is NOT a security update. It does not patch the system. It only:
#   audit   : read-only report of risky settings (nothing is changed)
#   apply   : disables a short list of preinstalled apps (reversible)
#   restore : re-enables the apps disabled by "apply"
#
# Requirements: adb (Android platform-tools), USB debugging enabled and authorised.
# Usage: ./g90-harden.sh audit|apply|restore [--optional] [--dry-run] [--force]

set -u

# Preinstalled apps with network access and no benefit for the user.
# See docs/PACKAGES.md for the reason behind each one.
CORE=(
  com.abfota.systemUpdate
  za.co.flatrocksolutions.notifications
  za.co.flatrocksolutions.appmanager
  za.co.flatrocksolutions.deviceidentifier
)
# Harmless leftovers from manufacturing. Only touched with --optional.
OPTIONAL=(
  com.AgeTest
  com.example.switchbootanim
)

CMD="${1:-}"
shift || true
DRY=0; FORCE=0; USE_OPTIONAL=0
for a in "$@"; do
  case "$a" in
    --dry-run)  DRY=1 ;;
    --force)    FORCE=1 ;;
    --optional) USE_OPTIONAL=1 ;;
    *) echo "Unknown option: $a"; exit 2 ;;
  esac
done

find_adb() {
  if [ -n "${ADB:-}" ] && [ -x "$ADB" ]; then return 0; fi
  if command -v adb >/dev/null 2>&1; then ADB="$(command -v adb)"; return 0; fi
  for p in "$HOME/Library/Android/sdk/platform-tools/adb" \
           "$HOME/Android/Sdk/platform-tools/adb"; do
    if [ -x "$p" ]; then ADB="$p"; return 0; fi
  done
  echo "adb not found. Install Android platform-tools or set ADB=/path/to/adb"
  exit 1
}

sh() { "$ADB" shell "$@" | tr -d '\r'; }

require_device() {
  local state
  state="$("$ADB" get-state 2>&1 | tr -d '\r')"
  if [ "$state" != "device" ]; then
    echo "No authorised device (adb says: $state)."
    echo "Unlock the phone, accept the USB debugging prompt, then retry."
    exit 1
  fi
  local model fp
  model="$(sh getprop ro.product.model)"
  fp="$(sh getprop ro.build.fingerprint)"
  echo "Device: $model  ($fp)"
  if [ "$FORCE" -ne 1 ] && ! echo "$fp" | grep -q "BLU/G90"; then
    echo "This script targets the BLU G90 (fingerprint BLU/G90/...). Aborting."
    echo "Use --force at your own risk on another device."
    exit 1
  fi
}

installed() { sh pm list packages | sed 's/^package://' ; }

targets() {
  printf '%s\n' "${CORE[@]}"
  if [ "$USE_OPTIONAL" -eq 1 ]; then printf '%s\n' "${OPTIONAL[@]}"; fi
}

apply() {
  local have; have="$(installed)"
  while read -r pkg; do
    [ -z "$pkg" ] && continue
    if ! echo "$have" | grep -qx "$pkg"; then echo "skip (not installed): $pkg"; continue; fi
    if [ "$DRY" -eq 1 ]; then echo "[dry-run] would disable: $pkg"; continue; fi
    echo -n "disable $pkg ... "
    sh pm disable-user --user 0 "$pkg" | tail -n1
  done < <(targets)
  echo; echo "Disabled packages now:"; sh pm list packages -d
  echo; echo "Reboot the phone. To undo: $0 restore --optional"
}

restore() {
  # Always restore both lists so that nothing stays disabled by mistake.
  USE_OPTIONAL=1
  local have; have="$(installed; sh pm list packages -d | sed 's/^package://')"
  while read -r pkg; do
    [ -z "$pkg" ] && continue
    if ! echo "$have" | grep -qx "$pkg"; then continue; fi
    if [ "$DRY" -eq 1 ]; then echo "[dry-run] would enable: $pkg"; continue; fi
    echo -n "enable $pkg ... "
    sh pm enable "$pkg" | tail -n1
  done < <(targets)
}

audit() {
  echo "== Android / patch level =="
  echo "Android: $(sh getprop ro.build.version.release)  patch: $(sh getprop ro.build.version.security_patch)"
  echo "debuggable: $(sh getprop ro.debuggable)  verified boot: $(sh getprop ro.boot.verifiedbootstate)"
  echo; echo "== Device administrators =="
  sh dumpsys device_policy | grep -iA3 "Enabled Device Admins"
  echo; echo "== Accessibility services (classic spyware entry point) =="
  sh settings get secure enabled_accessibility_services
  echo; echo "== Notification listeners =="
  sh settings get secure enabled_notification_listeners
  echo; echo "== Default keyboard =="
  sh settings get secure default_input_method
  echo; echo "== Third-party apps =="
  sh pm list packages -3
  echo; echo "== Disabled packages =="
  sh pm list packages -d
  echo; echo "== Preinstalled apps that can read SMS / contacts / call log AND use the Internet =="
  for pkg in $(sh pm list packages -s | sed 's/^package://'); do
    out="$(sh dumpsys package "$pkg" | grep -E "INTERNET: granted=true|READ_SMS: granted=true|READ_CONTACTS: granted=true|READ_CALL_LOG: granted=true")"
    if echo "$out" | grep -q INTERNET && echo "$out" | grep -qE "READ_SMS|READ_CONTACTS|READ_CALL_LOG"; then
      echo "- $pkg"
    fi
  done
  echo; echo "Note: many legitimate system apps appear in the last list (Messages, Contacts, Dialer, Google apps)."
  echo "Look for names you do not recognise, and read docs/PACKAGES.md."
}

find_adb
case "$CMD" in
  audit)   require_device; audit ;;
  apply)   require_device; apply ;;
  restore) require_device; restore ;;
  *) echo "Usage: $0 audit|apply|restore [--optional] [--dry-run] [--force]"; exit 2 ;;
esac
