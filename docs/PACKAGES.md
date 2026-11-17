# Packages handled by the script / Paquets traités par le script

Observed on a BLU G90 (model U2), Android 10, build
`BLU/G90/G0310WW:10/QP1A.190711.020/1585383273:user/release-keys`, security patch 2020-02-05.
Other firmware versions may differ. "Observed" below means read with
`adb shell dumpsys package <name>` on that unit.

| Package | Observed permissions | Why it is disabled |
|---|---|---|
| `com.abfota.systemUpdate` | INTERNET + READ_SMS + READ_CALL_LOG + READ_CONTACTS (granted by default, system-fixed) | An update client has no need to read messages or contacts. BLU phones shipped a similar OTA module (Adups) in 2016 that sent such data to a server in China. **No evidence was found that this one does the same**; the permission combination is the reason for caution. |
| `za.co.flatrocksolutions.notifications` | INTERNET only | Unknown purpose, pushes data/notifications from a remote server. |
| `za.co.flatrocksolutions.appmanager` | INTERNET only | Likely remote app management (reseller / operator tooling). |
| `za.co.flatrocksolutions.deviceidentifier` | INTERNET only | Likely reports a device identifier. May be tied to an operator lock or instalment plan: re-enable it if something stops working. |
| `com.AgeTest` (optional) | n/a | Factory test leftover. |
| `com.example.switchbootanim` (optional) | n/a | Boot animation switcher, example package name. |

## Not touched
`com.mediatek.*`, `com.tyd.*` (normal platform components), `com.aiworks.faceidservice` and
`com.beanpodtech.tface` (face unlock), `com.google.android.verifier` (Google's Android Developer
Verifier, a legitimate system service).

## Limits
- Disabling is not removal: the apps stay in the system image and can be re-enabled.
- This reduces exposure; it does not fix kernel or framework vulnerabilities fixed after Feb 2020.
- Not tested on other firmware builds. Run `audit` first and read the result.

---

# Français

Relevé sur un BLU G90 (modèle U2) sous Android 10, correctif de sécurité de février 2020.
« Observé » signifie lu avec `adb shell dumpsys package <nom>` sur cet exemplaire.

Le module `com.abfota.systemUpdate` est désactivé par précaution : il combine Internet et la lecture
des SMS, du journal d'appels et des contacts, ce qu'un module de mise à jour n'a pas à faire.
**Rien ne prouve qu'il envoie des données.** Les applis `flatrocksolutions` n'ont que l'accès à Internet,
leur rôle exact est inconnu. Tout est réversible avec `./scripts/g90-harden.sh restore --optional`.
