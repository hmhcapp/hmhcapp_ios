// android/app/build.gradle (Kotlin DSL)

import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load signing props from android/key.properties.
// In Codemagic UI, these values are injected as env vars into key.properties.
// For local builds you can point to ../keystore/key.jks, etc.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}

android {
    namespace = "com.collection.hmhcapp"

    // Use explicit SDKs to satisfy Play requirements; minSdk still comes from Flutter.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // AGP 8.x requires JDK 17; Codemagic images provide this by default.
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.collection.hmhcapp"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        // These are sourced from pubspec's version: x.y.z+build, unless you override.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                storeFile = file(keystoreProperties["storeFile"].toString())
                storePassword = keystoreProperties["storePassword"].toString()
                keyAlias = keystoreProperties["keyAlias"].toString()
                keyPassword = keystoreProperties["keyPassword"].toString()
            }
        }
    }

    buildTypes {
        release {
            // Sign with your real release key (Codemagic UI or local key.properties).
            signingConfig = signingConfigs.getByName("release")
            // Keep minification off by default to avoid surprises; enable later if desired.
            isMinifyEnabled = false
            isShrinkResources = false
            // If you turn minify on, keep these proguard files:
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
        debug {
            // Keep local device testing separate from the Play Store installation.
            applicationIdSuffix = ".sandbox"
            versionNameSuffix = "-sandbox"
        }
    }
}

flutter {
    source = "../.."
}
