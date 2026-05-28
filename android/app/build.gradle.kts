import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Le plugin Flutter doit rester après Android + Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "ci.itech.lstracker"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "ci.itech.lstracker"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        multiDexEnabled = true
        vectorDrawables.useSupportLibrary = true
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    // Flavors = 3 environnements alignés sur les entry-points Dart
    // (lib/main.dart, main_demo.dart, main_prod.dart).
    //  - prod : applicationId INCHANGÉ (ci.itech.lstracker) → compatible avec
    //           l'app déjà publiée sur le Play Store (même signature requise).
    //  - dev / demo : suffixe d'applicationId → s'installent À CÔTÉ de la prod
    //           sur un même appareil, sans conflit de package.
    // Le label (nom sous l'icône) est injecté via manifestPlaceholders[appLabel]
    // que le AndroidManifest référence en android:label="${appLabel}".
    flavorDimensions += "env"
    productFlavors {
        create("prod") {
            dimension = "env"
            // pas de suffixe : reste ci.itech.lstracker
            manifestPlaceholders["appLabel"] = "LSTracker"
        }
        create("demo") {
            dimension = "env"
            applicationIdSuffix = ".demo"
            versionNameSuffix = "-demo"
            manifestPlaceholders["appLabel"] = "LSTracker DEMO"
        }
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["appLabel"] = "LSTracker DEV"
        }
    }

    // Signature release (facultatif mais propre)
    val keystoreProps = Properties()
    val keystoreFile = rootProject.file("key.properties")
    if (keystoreFile.exists()) {
        keystoreProps.load(FileInputStream(keystoreFile))
    }

    signingConfigs {
        create("release") {
            if (keystoreFile.exists()) {
                storeFile = file(keystoreProps["storeFile"] as String)
                storePassword = keystoreProps["storePassword"] as String
                keyAlias = keystoreProps["keyAlias"] as String
                keyPassword = keystoreProps["keyPassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            // si pas de keystore, commente la ligne suivante:
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
        getByName("debug") {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/AL2.0",
                "META-INF/LGPL2.1"
            )
        }
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.core:core-ktx:1.13.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
