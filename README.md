# LSTracker Mobile

App Flutter compagnon de [LSTracker Web](https://github.com/ITECH-CI/LSTracker_web) — saisie terrain pour le suivi des échantillons médicaux en transport entre sites de collecte et laboratoires d'analyse (PNLS / PNLT / PNLP — Côte d'Ivoire).

Stack : **Flutter 3.8+** · **Dart 3** · **SQLite (sqflite)** · **Dio** · **Riverpod**

---

## Sommaire

1. [Architecture des environnements](#architecture-des-environnements)
2. [Prérequis](#prérequis)
3. [Installation](#installation)
4. [Développement local](#développement-local)
5. [Builds release (APK / AAB)](#builds-release-apk--aab)
6. [Signature et keystore](#signature-et-keystore)
7. [Publication Play Store](#publication-play-store)
8. [CI GitHub Actions](#ci-github-actions)
9. [Versioning](#versioning)

---

## Architecture des environnements

Trois entry-points Dart pointent vers trois backends différents — un seul `applicationId` Android (`ci.itech.lstracker`) pour rester compatible Play Store.

| Entry-point | API ciblée | Usage |
|---|---|---|
| `lib/main.dart` | `http://10.0.2.2:9200` (emulator → localhost) | Dev local, debug |
| `lib/main_demo.dart` | `http://38.242.195.91:9200` | Build APK distribué hors Play Store |
| `lib/main_prod.dart` | `https://lstracker.org` | Build AAB pour Play Store |

L'URL d'API est surchargée à l'init via `AppConfig.overrideBase(...)` dans chaque entry-point.

---

## Prérequis

- Flutter 3.8+ (`flutter --version`)
- Android SDK + emulator ou device physique
- JDK 17 (pour les builds release)
- macOS / Linux / Windows

---

## Installation

```bash
git clone git@github.com:ITECH-CI/LSTracker_mobile.git
cd LSTracker_mobile
flutter pub get
```

---

## Développement local

Démarrer l'app sur emulator/device avec hot reload :

```bash
# Default : main.dart, API locale (http://10.0.2.2:9200)
flutter run

# Ou explicitement
flutter run -t lib/main.dart
```

Tester sur l'env DEMO sans recompiler en release :

```bash
flutter run -t lib/main_demo.dart
```

Lancer les tests + analyze :

```bash
flutter analyze
flutter test
```

---

## Builds release (APK / AAB)

> **Prérequis :** keystore configuré (cf. [section suivante](#signature-et-keystore)).

### APK demo — distribution hors Play Store

```bash
flutter build apk --release --target=lib/main_demo.dart
```

Sortie : `build/app/outputs/flutter-apk/app-release.apk`

Renommer pour distribution :

```bash
mv build/app/outputs/flutter-apk/app-release.apk \
   ~/Desktop/lstracker-demo-v2.2.0.apk
```

### AAB prod — upload Play Store

```bash
flutter build appbundle --release --target=lib/main_prod.dart
```

Sortie : `build/app/outputs/bundle/release/app-release.aab`

### APK debug — tests internes rapides

```bash
flutter build apk --debug --target=lib/main.dart
```

Sortie : `build/app/outputs/flutter-apk/app-debug.apk`

### Build complet (les 3 en série)

```bash
# Demo + Prod en une commande
flutter build apk --release --target=lib/main_demo.dart && \
flutter build appbundle --release --target=lib/main_prod.dart
```

---

## Signature et keystore

Le keystore et son `key.properties` ne sont **jamais committés** (cf. `.gitignore`).

### Setup initial sur un nouveau poste

1. **Récupérer le keystore** depuis le coffre sécurisé (1Password / disque chiffré).
2. **Le placer en local** — emplacement recommandé : `~/dev/dnoApp/keystores/lstracker-demo.jks` (hors du repo).
3. **Créer `android/key.properties`** :

   ```properties
   storePassword=<mot-de-passe-keystore>
   keyPassword=<mot-de-passe-cle>
   keyAlias=lstracker
   storeFile=/Users/<vous>/dev/dnoApp/keystores/lstracker-demo.jks
   ```

   `storeFile` accepte un chemin absolu OU un chemin relatif au dossier `android/app/`.

4. **Vérifier** que `android/app/build.gradle.kts` lit bien ces propriétés (déjà configuré dans le projet).

### Empreinte du keystore (à archiver)

Le SHA1/SHA256 du certificat de signature **doit rester identique** entre toutes les releases, sinon Play Store refuse la mise à jour.

```bash
keytool -list -v \
  -keystore ~/dev/dnoApp/keystores/lstracker-demo.jks \
  -alias lstracker
```

⚠️ **Backup du keystore** : sans lui, plus aucune mise à jour Play Store n'est possible. Stocker dans **au moins 2 endroits** sécurisés (cloud chiffré + USB en sécurité physique).

---

## Publication Play Store

1. Bumper la version dans [pubspec.yaml](pubspec.yaml) :
   ```yaml
   version: 2.3.0+7        # versionName+versionCode (le code doit toujours augmenter)
   ```
2. Build le bundle :
   ```bash
   flutter build appbundle --release --target=lib/main_prod.dart
   ```
3. Upload sur [Play Console](https://play.google.com/console) → Release → Production → Create new release.
4. Joindre les notes de version (changelog).

---

## CI GitHub Actions

Un seul workflow tourne en CI : [.github/workflows/ci.yml](.github/workflows/ci.yml).

| Trigger | Job |
|---|---|
| Push sur `main` | `flutter analyze` + `flutter test` |
| Pull request vers `main` | `flutter analyze` + `flutter test` |

**Les builds release (APK demo, AAB prod) se font en local**, pas en CI. Le keystore reste sur le poste du mainteneur, jamais exposé à GitHub.

---

## Versioning

Format `pubspec.yaml` : `<semver>+<build-number>`

```yaml
version: 2.2.0+6
```

| Partie | Mapping Android | Mapping iOS | Quand bumper |
|---|---|---|---|
| `2.2.0` (semver) | `versionName` | `CFBundleShortVersionString` | À chaque release fonctionnelle |
| `+6` (build) | `versionCode` (int) | `CFBundleVersion` | À **chaque build uploadé** sur Play Store (doit strictement augmenter) |

Conventions :
- `MAJOR.MINOR.PATCH` standard semver
- Tag git correspondant : `git tag -a v2.3.0 -m "Release notes" && git push origin v2.3.0`
- Le tag sert de marqueur — il ne déclenche aucun build en CI (build local).
