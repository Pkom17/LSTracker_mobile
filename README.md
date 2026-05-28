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

Trois **flavors Android** alignés sur trois entry-points Dart. Chaque flavor a son propre `applicationId` (sauf prod, inchangé pour rester compatible Play Store) → demo et dev s'installent **à côté** de la prod sur un même appareil, sans conflit de package.

| Flavor | Entry-point | applicationId | Label | API ciblée |
|---|---|---|---|---|
| `dev` | `lib/main.dart` | `ci.itech.lstracker.dev` | LSTracker DEV | `http://10.0.2.2:9200` (emulator → localhost) |
| `demo` | `lib/main_demo.dart` | `ci.itech.lstracker.demo` | LSTracker DEMO | `https://lstracker-demo.itech-civ.org` |
| `prod` | `lib/main_prod.dart` | `ci.itech.lstracker` | LSTracker | `https://lstracker.org` |

L'URL d'API est surchargée à l'init via `AppConfig.overrideBase(...)` dans chaque entry-point. Le `applicationId` et le label sont gérés par les flavors dans `android/app/build.gradle.kts`.

> ⚠️ Le flavor **prod garde `ci.itech.lstracker`** (identique à l'app publiée). NE PAS lui ajouter de suffixe, sinon les mises à jour Play Store casseraient.

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

Démarrer l'app sur emulator/device avec hot reload. Avec les flavors, il faut
préciser `--flavor` ET `--target` :

```bash
# Dev (API locale http://10.0.2.2:9200)
flutter run --flavor dev --target=lib/main.dart

# Tester sur l'env DEMO (API lstracker-demo.itech-civ.org)
flutter run --flavor demo --target=lib/main_demo.dart
```

Lancer les tests + analyze (pas besoin de flavor) :

```bash
flutter analyze
flutter test
```

---

## Builds release (APK / AAB)

> **Prérequis :** keystore configuré (cf. [section suivante](#signature-et-keystore)).
> Toujours associer `--flavor X` au bon `--target` (sinon mismatch env/applicationId).

### APK demo — distribution hors Play Store

```bash
flutter build apk --release --flavor demo --target=lib/main_demo.dart
```

Sortie : `build/app/outputs/flutter-apk/app-demo-release.apk`
applicationId : `ci.itech.lstracker.demo` (s'installe à côté de la prod)

Renommer pour distribution :

```bash
mv build/app/outputs/flutter-apk/app-demo-release.apk \
   ~/Desktop/lstracker-demo-v2.2.0.apk
```

### AAB prod — upload Play Store

```bash
flutter build appbundle --release --flavor prod --target=lib/main_prod.dart
```

Sortie : `build/app/outputs/bundle/prodRelease/app-prod-release.aab`
applicationId : `ci.itech.lstracker` (compatible avec l'app publiée)

### APK dev — tests internes rapides

```bash
flutter build apk --debug --flavor dev --target=lib/main.dart
```

Sortie : `build/app/outputs/flutter-apk/app-dev-debug.apk`

### Build demo + prod en série

```bash
flutter build apk --release --flavor demo --target=lib/main_demo.dart && \
flutter build appbundle --release --flavor prod --target=lib/main_prod.dart
```

---

## Signature et keystore

> Voir [docs/KEYSTORE.md](docs/KEYSTORE.md) pour la procédure complète : backup, restauration sur nouveau poste, Play App Signing, rotation.

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
2. Build le bundle (flavor **prod** → applicationId `ci.itech.lstracker`) :
   ```bash
   flutter build appbundle --release --flavor prod --target=lib/main_prod.dart
   ```
   Sortie : `build/app/outputs/bundle/prodRelease/app-prod-release.aab`
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
