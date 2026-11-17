# BLU G90 hardening (audit + reversible clean-up)

> **This is not a security update.** It cannot patch Android. It audits the phone and disables a few
> preinstalled apps that have network access and no benefit for the user. Everything is reversible.

Target: BLU G90 (model `U2`), Android 10, security patch February 2020. Tested by hand on one unit.

## What you need
- A Mac or Linux computer with [Android platform-tools](https://developer.android.com/tools/releases/platform-tools) (`adb`)
- USB debugging enabled on the phone, and the authorisation prompt accepted
  (if `adb devices` shows `unauthorized`: unlock the phone, accept the prompt, or revoke USB debugging
  authorisations in Developer options and reconnect)

## Use
```
chmod +x scripts/g90-harden.sh
./scripts/g90-harden.sh audit                 # read-only report, changes nothing
./scripts/g90-harden.sh apply --dry-run       # shows what would be disabled
./scripts/g90-harden.sh apply                 # disables the core list
./scripts/g90-harden.sh apply --optional      # also factory leftovers
./scripts/g90-harden.sh restore --optional    # undo everything
```
Reboot afterwards. The script refuses to run on another model unless you pass `--force`.

## What it does and does not do
- Does: report device admins, accessibility services, notification listeners, default keyboard, third-party apps; disable the packages listed in [docs/PACKAGES.md](docs/PACKAGES.md).
- Does not: fix vulnerabilities, remove apps from the system image, or prove the phone is clean.
  It found no classic spyware on the author's unit, which says nothing about yours.
- The listed apps are flagged for their permissions, not proven malicious.

## Staying safe on an unpatched phone
Avoid banking apps and sensitive logins, keep Google Play Protect on, install apps only from Google
Play, and plan to replace the phone. For a newer system, see [docs/BOOTLOADER-GSI.md](docs/BOOTLOADER-GSI.md)
(untested research notes, risky).

## Licence
MIT. Use at your own risk. No affiliation with BLU Products.

---

## Français

**Ce n'est pas une mise à jour de sécurité.** Le script audite le téléphone et désactive quelques applis
préinstallées qui ont accès à Internet et ne servent à rien. Tout est réversible.

```
./scripts/g90-harden.sh audit                 # rapport en lecture seule
./scripts/g90-harden.sh apply --dry-run       # simulation
./scripts/g90-harden.sh apply                 # désactive la liste principale
./scripts/g90-harden.sh restore --optional    # annule tout
```

Prérequis : `adb`, débogage USB activé et autorisé sur le téléphone. Redémarrez ensuite le téléphone.
Le script ne corrige aucune faille et ne prouve pas que le téléphone est sain. Sur un téléphone sans
correctif depuis 2020, évitez la banque en ligne et les connexions sensibles, et prévoyez de le remplacer.
