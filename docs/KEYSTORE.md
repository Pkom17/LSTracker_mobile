# Gestion du keystore Android — LSTracker Mobile

> Le keystore signe **toutes les APK/AAB** de l'app. Sans lui (ou sans son password), plus aucune mise à jour Play Store n'est possible. Ce document détaille la procédure complète : setup, backup, restauration, Play App Signing.

## Sommaire

1. [Concepts](#concepts)
2. [Setup sur un nouveau poste](#setup-sur-un-nouveau-poste)
3. [Backup du keystore](#backup-du-keystore)
4. [Restauration sur un nouveau poste](#restauration-sur-un-nouveau-poste)
5. [Play App Signing (recommandé)](#play-app-signing-recommandé)
6. [Rotation du keystore (exceptionnel)](#rotation-du-keystore-exceptionnel)
7. [Troubleshooting](#troubleshooting)

---

## Concepts

### Qu'est-ce qu'un keystore ?

Un fichier `.jks` qui contient une **paire de clés cryptographiques** (privée + certificat). La clé privée signe les builds, le certificat permet à Android de vérifier la signature.

### Pourquoi est-ce critique ?

Google Play **exige** que toutes les mises à jour d'une app soient signées avec la **même clé** que la version précédente. Si tu perds la clé :

- ❌ Plus aucune mise à jour possible sur Play Store
- ❌ Tu dois publier une **nouvelle app** (nouveau `applicationId`, perte de tous les utilisateurs, mauvais reviews, etc.)
- ✅ **Sauf si** Play App Signing était activé — Google a alors une copie de ta clé

### Quel keystore pour LSTracker ?

**Un seul** keystore pour toutes les versions (debug, demo, prod) car un seul `applicationId` = `ci.itech.lstracker`.

Configuration actuelle :

```properties
# android/key.properties (jamais committé)
storePassword=<password-keystore>
keyPassword=<password-cle>
keyAlias=lstracker
storeFile=/Users/<user>/dev/dnoApp/keystores/lstracker-demo.jks
```

> Le nom du fichier `lstracker-demo.jks` est historique mais trompeur — il signe **demo ET prod**.

---

## Setup sur un nouveau poste

À faire quand un nouveau mainteneur rejoint le projet ou lors d'un changement de machine.

### 1. Récupérer le keystore depuis le coffre

Selon où il est stocké (cf. [Backup du keystore](#backup-du-keystore)) :

```bash
# Si stocké chiffré GPG dans 1Password / Bitwarden
gpg --decrypt --output lstracker-demo.jks lstracker-keystore-backup.jks.gpg
# Mot de passe GPG demandé

# Placer hors du repo (recommandé)
mkdir -p ~/dev/dnoApp/keystores
mv lstracker-demo.jks ~/dev/dnoApp/keystores/
chmod 600 ~/dev/dnoApp/keystores/lstracker-demo.jks
```

### 2. Vérifier l'authenticité

```bash
keytool -list -v \
  -keystore ~/dev/dnoApp/keystores/lstracker-demo.jks \
  -alias lstracker \
  -storepass <password-keystore>
```

Comparer le **SHA-256 du certificat** avec celui archivé (cf. coffre / [section ci-dessous](#empreintes-de-référence)).

Si SHA-256 différent → **STOP**. Tu as un mauvais keystore. Ne signe rien avec.

### 3. Créer `android/key.properties`

```bash
cd <repo-mobile>/android
cat > key.properties <<EOF
storePassword=<password-keystore>
keyPassword=<password-cle>
keyAlias=lstracker
storeFile=$HOME/dev/dnoApp/keystores/lstracker-demo.jks
EOF
chmod 600 key.properties
```

### 4. Tester un build release

```bash
cd <repo-mobile>
flutter build apk --release --flavor demo --target=lib/main_demo.dart
```

Si pas d'erreur → setup OK. L'APK généré (`build/app/outputs/flutter-apk/app-demo-release.apk`) est signé.

### 5. Vérifier la signature de l'APK généré

```bash
$ANDROID_HOME/build-tools/<version>/apksigner verify --print-certs \
  build/app/outputs/flutter-apk/app-release.apk
```

Le SHA-256 affiché doit matcher l'empreinte de référence.

---

## Backup du keystore

### Stratégie 3-2-1 adaptée

3 copies, sur 2 supports différents, dont 1 hors site.

| Copie | Support | Localisation | Mise à jour |
|---|---|---|---|
| **Active** | Disque SSD du poste de dev (chiffré FileVault/LUKS) | `~/dev/dnoApp/keystores/` | Daily backup automatique |
| **Backup 1** | 1Password / Bitwarden — vault d'équipe ITECH-CI | Cloud chiffré E2E | 1 fois (immuable) |
| **Backup 2** | Clé USB chiffrée (VeraCrypt) | Coffre physique au bureau | 1 fois |

### Préparer la backup chiffrée

```bash
# 1. Chiffrer avec GPG symétrique (passphrase forte, stockée séparément)
gpg --symmetric --cipher-algo AES256 \
    --output lstracker-keystore-backup.jks.gpg \
    ~/dev/dnoApp/keystores/lstracker-demo.jks

# 2. Vérifier que tu peux re-déchiffrer (test critique)
gpg --decrypt lstracker-keystore-backup.jks.gpg > /tmp/test-restore.jks
diff /tmp/test-restore.jks ~/dev/dnoApp/keystores/lstracker-demo.jks
# Aucune différence attendue
rm /tmp/test-restore.jks
```

### Uploader dans 1Password / Bitwarden

Créer une entrée "LSTracker Android Keystore" dans le **vault d'équipe ITECH-CI** :

- **Attachement** : `lstracker-keystore-backup.jks.gpg`
- **Notes sécurisées** :
  ```
  Keystore Android — signe TOUTES les versions LSTracker Mobile (demo + prod).
  
  Fichier original   : ~/dev/dnoApp/keystores/lstracker-demo.jks
  Mot de passe keystore : <storePassword>
  Mot de passe key      : <keyPassword>
  Alias                  : lstracker
  Passphrase GPG (backup) : <gpg-passphrase>
  
  Empreintes (à vérifier après restauration) :
    SHA1   : XX:XX:XX:...
    SHA256 : YY:YY:YY:...
  
  Validité : YYYY-MM-DD à YYYY-MM-DD
  
  CRITIQUE — sans ce fichier ou son password, plus aucune update Play Store possible.
  ```

### Empreintes de référence

À générer **une fois** puis archiver dans 1Password :

```bash
keytool -list -v \
  -keystore ~/dev/dnoApp/keystores/lstracker-demo.jks \
  -alias lstracker | grep -E "(SHA1|SHA256|until):"
```

Copier les valeurs `SHA1`, `SHA256`, et la date d'expiration dans la note 1Password.

---

## Restauration sur un nouveau poste

Si ton Mac actuel meurt ou si un autre mainteneur prend le relais :

1. **Accès au vault ITECH-CI** dans 1Password / Bitwarden
2. **Télécharger** l'attachement `lstracker-keystore-backup.jks.gpg`
3. **Lire** la passphrase GPG depuis la note
4. **Déchiffrer** :
   ```bash
   gpg --decrypt --output lstracker-demo.jks lstracker-keystore-backup.jks.gpg
   mkdir -p ~/dev/dnoApp/keystores
   mv lstracker-demo.jks ~/dev/dnoApp/keystores/
   chmod 600 ~/dev/dnoApp/keystores/lstracker-demo.jks
   ```
5. **Vérifier empreinte** (cf. [Setup §2](#setup-sur-un-nouveau-poste))
6. **Créer `android/key.properties`** (cf. [Setup §3](#setup-sur-un-nouveau-poste))
7. **Tester un build** (cf. [Setup §4](#setup-sur-un-nouveau-poste))

---

## Play App Signing (recommandé)

### Pourquoi l'activer ?

Avec **Play App Signing**, Google génère et conserve une **clé de signature** dans son infrastructure sécurisée. Toi, tu signes les uploads avec une **upload key** secondaire.

Avantages :
- ✅ Si tu perds ta upload key → Google peut t'en regénérer une nouvelle
- ✅ Plus de risque de perdre l'accès à Play Store même en cas de vol/corruption
- ✅ Tu peux faire tourner la upload key périodiquement sans casser les mises à jour

Inconvénients :
- ⚠️ Une fois activé, on **ne peut plus revenir en arrière**
- ⚠️ Si l'app était déjà publiée avec une autre clé, il faut soit migrer cette clé (Google l'accepte une fois), soit la garder pour les anciennes versions

### Comment activer

Si LSTracker n'est **pas encore publiée** sur Play Store :

1. Lors du premier upload AAB sur Play Console
2. Play Console te propose **automatiquement** d'activer Play App Signing
3. Tu uploads ton AAB signé avec ta clé existante → Google la stocke comme upload key
4. Google génère sa propre clé de signature
5. Désormais, tu uploads avec ta upload key, Google re-signe avec sa clé

Si LSTracker est **déjà publiée** sans Play App Signing :

1. Play Console → app → Setup → App signing → **Use Play App Signing**
2. Upload ta clé existante (la même que tu utilises actuellement) — c'est la procédure "opt-in"
3. Google la transforme en clé de signature stockée chez eux
4. Tu peux ensuite générer une nouvelle upload key (ou garder l'existante comme upload key)

### Conséquences pour ce repo

**Aucune** côté code/Flutter — tu continues à signer tes builds avec `key.properties` exactement comme avant. La différence se fait côté Play Console.

> **Recommandation forte** : activer Play App Signing dès la prochaine release sur Play Store.

---

## Rotation du keystore (exceptionnel)

### Pourquoi ?

- Compromission suspectée
- Recommandation Google de rotation (rare)
- Migration d'un employé partant qui avait accès

### Avec Play App Signing activé

C'est facile : tu génères une **nouvelle upload key**, tu la déclares sur Play Console, et tu signes désormais avec elle. La clé de signature stockée chez Google **ne change pas** → les utilisateurs continuent de recevoir des updates normalement.

```bash
# Générer la nouvelle upload key
keytool -genkey -v \
  -keystore ~/dev/dnoApp/keystores/lstracker-upload-2026.jks \
  -alias lstracker-upload \
  -keyalg RSA -keysize 2048 -validity 10000

# Sur Play Console : Setup → App signing → Request upload key reset
# Google te répond sous 1-2 jours, tu uploads ton certificat
```

### Sans Play App Signing

**Impossible.** La clé de signature ne peut pas être changée — c'est l'identité de l'app pour Google.

---

## Troubleshooting

### `keystore was tampered with, or password was incorrect`

Mauvais password keystore. Vérifier dans 1Password.

```bash
# Tester juste l'accès keystore (sans alias)
keytool -list -keystore ~/dev/dnoApp/keystores/lstracker-demo.jks
# Demande storePassword
```

### `Alias <lstracker> does not exist`

Mauvais keystore. Lister les alias :

```bash
keytool -list -keystore ~/dev/dnoApp/keystores/lstracker-demo.jks -v \
  | grep -i "alias name"
```

Si l'alias affiché n'est pas `lstracker` → mauvais fichier, restaurer depuis backup.

### `Failed to read key <alias> from store`

Mauvais `keyPassword` dans `key.properties` (différent du `storePassword`).

### `apksigner verify` échoue après build

```bash
$ANDROID_HOME/build-tools/<version>/apksigner verify \
  --verbose --print-certs \
  build/app/outputs/flutter-apk/app-release.apk
```

Si erreur → le build n'a pas été signé. Vérifier que `android/key.properties` existe ET que `signingConfig` est appliqué dans `android/app/build.gradle.kts` (déjà configuré dans ce projet).

### Play Console refuse l'upload : "L'APK doit être signé avec le certificat <fingerprint>"

L'AAB est signé avec un keystore différent de celui enregistré sur Play Console. Soit :
- Tu as restauré un mauvais keystore → vérifier SHA-256
- Tu as activé Play App Signing avec une autre clé que ta clé actuelle

Comparer le SHA-256 de l'APK avec celui attendu sur Play Console.

### Le `key.properties` a été committé par erreur

```bash
# 1. Le retirer du suivi mais le garder en local
git rm --cached android/key.properties
git commit -m "fix: untrack key.properties"
git push

# 2. CRITIQUE : si commit déjà pushé sur un remote, considérer le keystore compromis.
#    Procédure de rotation requise (cf. ci-dessus), surtout si repo public.
```
