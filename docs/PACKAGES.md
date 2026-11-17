# Packages handled by the script / Paquets traités par le script

Observed on a BLU G90 (model U2), Android 10, build
`BLU/G90/G0310WW:10/QP1A.190711.020/1585383273:user/release-keys`, security patch 2020-02-05.
Other firmware versions may differ. "Observed" below means read with
`adb shell dumpsys package <name>` on that unit.

| Package | Observed permissions | Why it is disabled |
|---|---|---|
| `com.abfota.systemUpdate` | Runs with the system identity (`sharedUser=android.uid.system`), installed in `/system/app/Rsota`. `dumpsys` shows INTERNET, READ_SMS, READ_CALL_LOG and READ_CONTACTS as granted, but these are inherited from the shared system identity, so they do not show what the app itself requests. | An update client running with full system privileges and network access is a high-trust component. BLU phones shipped a similar OTA module (Adups, also a system-identity app) in 2016 that sent personal data to a server in China. **No evidence was found that this one does the same**; the privilege level and the maker's history are the reason for caution. |
| `za.co.flatrocksolutions.notifications` | INTERNET only | Unknown purpose, pushes data/notifications from a remote server. |
| `za.co.flatrocksolutions.appmanager` | INTERNET only | Likely remote app management (reseller / operator tooling). |
| `za.co.flatrocksolutions.deviceidentifier` | INTERNET only | Likely reports a device identifier. May be tied to an operator lock or instalment plan: re-enable it if something stops working. |
| `com.AgeTest` (optional) | System identity, `/system/app/AgeTest1` | Factory test app with no user function, but it runs with system privileges. |
| `com.example.switchbootanim` (optional) | System identity, `/system/app/SwitchBootAnim` | Boot animation switcher with an example package name; no user function, system privileges. |

## Not touched
`com.mediatek.*`, `com.tyd.*` (normal platform components), `com.aiworks.faceidservice` and
`com.beanpodtech.tface` (face unlock), `com.tyd.configdisplay` (display configuration),
`com.mediatek.factorymode` (factory test menu), `com.google.android.verifier` (Google's Android
Developer Verifier, a legitimate system service). Several of these also run with the system identity;
that is common on cheap phones and is not proof of misbehaviour, only a reason to keep the list short.

## Reading the permissions correctly
On Android, apps sharing the system identity inherit all of its permissions, and `dumpsys package`
displays them as if the app held them. The app's own manifest requests are what matters, and they are
not shown by that output. The first version of this document treated inherited permissions as the app's
own; that was wrong and is corrected here.

## Limits
- Disabling is not removal: the apps stay in the system image and can be re-enabled.
- This reduces exposure; it does not fix kernel or framework vulnerabilities fixed after Feb 2020.
- Not tested on other firmware builds. Run `audit` first and read the result.

---

# Français

Relevé sur un BLU G90 (modèle U2) sous Android 10, correctif de sécurité de février 2020.
« Observé » signifie lu avec `adb shell dumpsys package <nom>` sur cet exemplaire.

Le module `com.abfota.systemUpdate` est désactivé par précaution : il tourne avec l'identité système
(droits maximaux) et a accès à Internet, comme le module Adups de BLU en 2016. Les droits SMS, contacts
et appels que `dumpsys` lui attribue sont **hérités de l'identité système** et ne prouvent rien sur
l'appli elle-même (correction d'une première version de ce document).
**Rien ne prouve qu'il envoie des données.** Les applis `flatrocksolutions` n'ont que l'accès à Internet,
leur rôle exact est inconnu. Tout est réversible avec `./scripts/g90-harden.sh restore --optional`.
