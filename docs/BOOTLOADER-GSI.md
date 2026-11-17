# Going further: a newer system? / Un système plus récent ?

**Short answer: probably not worth it on this phone.** Nothing here was flashed or tested. These are
notes from reading the device properties of one unit. Flashing erases all data and can brick the phone.

## Properties read on a BLU G90 (model U2)

| Property | Value | What it means |
|---|---|---|
| `ro.treble.enabled` | `true` | Treble is on: a generic system image (GSI) is not ruled out. |
| `ro.product.first_api_level` | `29` | Launched with Android 10. |
| `ro.vndk.version` | `29` | Vendor partition built for Android 10. |
| `ro.board.platform` | `mt6737m` | MediaTek MT6737M, a 2016 low-end chip. |
| `ro.product.cpu.abilist` | `armeabi-v7a,armeabi` | 32-bit only: a 32-bit GSI would be needed, the rarest kind. |
| `ro.boot.dynamic_partitions` | `true` | Dynamic partitions reported. |
| `ro.build.ab_update` | *(empty)* | A-only device: a failed flash leaves no fallback slot. |
| `ro.boot.verifiedbootstate` | `green` | Verified boot, locked. |
| `ro.boot.flash.locked` | `1` | **Bootloader locked.** Unlocking wipes the phone and needs "OEM unlocking" in Developer options; if that switch is greyed out, the path is closed. |
| `uname -r` | `4.9.188` | Old kernel. A GSI does not replace it. |

## Why it is not recommended
- A GSI replaces the Android framework only. The kernel (4.9, 2019 era), the bootloader and the
  vendor partition stay as shipped, so their known weaknesses stay too.
- Newer Android releases generally require newer kernels; my unverified estimate is that Android 12
  would be the ceiling here, with security patches ending in 2023 at best.
- A newer Android on a 2016-class 32-bit chip is likely to be slower, not faster.
- Typical losses on a GSI: camera, VoLTE, Wi-Fi hotspot, face unlock. A-only devices have no fallback if
  boot fails.

## If you still want to look
1. Check Developer options: if "OEM unlocking" cannot be switched on, stop.
2. Back up everything; unlocking factory-resets the phone.
3. Look for a community GSI built for 32-bit A-only devices (arm32 binder64 or binder32) and read the
   reports of other MT6737M owners before trying. Do not use your only phone.

## Realistic alternative
Keep the phone for low-stakes use after running `scripts/g90-harden.sh`, avoid banking and sensitive
logins, and replace it with a phone whose maker commits to several years of security updates.

---

## Français

**En bref : probablement pas rentable sur ce téléphone.** Rien n'a été flashé ni testé ici ; ce sont des
notes tirées des propriétés lues sur un exemplaire. Un flash efface toutes les données et peut bloquer
le téléphone.

Points bloquants : puce MediaTek MT6737M de 2016 en 32 bits seulement, téléphone à partition système
unique (pas de secours en cas d'échec), **chargeur de démarrage verrouillé** (le déverrouiller efface
tout et dépend de l'option « Déverrouillage OEM »), et noyau 4.9 que ni une image générique ni un autre
système ne mettent à jour. Au mieux, un correctif de sécurité d'environ 2023 pour un téléphone
probablement plus lent. Mon estimation, non vérifiée, est qu'Android 12 serait le plafond.

Alternative réaliste : garder le téléphone pour un usage sans enjeu après le script de nettoyage, éviter
la banque et les connexions sensibles, puis le remplacer par un modèle dont le constructeur garantit
plusieurs années de mises à jour de sécurité.
