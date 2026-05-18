plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.onyx_rope"
    compileSdk = 36
    buildToolsVersion = "36.0.0"
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions { jvmTarget = "17" }

    defaultConfig {
        applicationId = "com.example.onyx_rope"
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Dynamic signing — uses env vars on CI, falls back to debug locally
    signingConfigs {
        if (System.getenv("CI") == "true") {
            create("release") {
                keyAlias = System.getenv("KEY_ALIAS")
                keyPassword = System.getenv("KEY_PASSWORD")
                storeFile = System.getenv("KEYSTORE_PATH")?.let { file(it) }
                storePassword = System.getenv("KEYSTORE_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (System.getenv("CI") == "true") {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
            // Minification is disabled because Flutter compiles Dart to native
            // AOT via the engine — R8 has no Dart bytecode to shrink, and it
            // strips the Java/Kotlin entry-point classes that Android needs to
            // launch the app, causing a ClassNotFoundException on startup.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // Strip Google's proprietary dependency metadata (required by F-Droid)
    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }
}

flutter { source = "../.." }
