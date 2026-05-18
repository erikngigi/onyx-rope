plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// F-Droid ABI split version code generation
val abiCodes = mapOf("armeabi-v7a" to 1, "arm64-v8a" to 2, "x86_64" to 3)

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

    // 1. Dynamic signing — uses env vars on CI, falls back to debug locally
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
            // Reduce APK size
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }

    // 2. Strip Google's proprietary dependency metadata (required by F-Droid)
    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }
}

// 3. ABI-specific version codes for split APKs (F-Droid requirement)
// armeabi-v7a → versionCode * 10 + 1
// arm64-v8a   → versionCode * 10 + 2
// x86_64      → versionCode * 10 + 3
android.applicationVariants.configureEach {
    val variant = this
    variant.outputs.forEach { output ->
        val abiVersionCode = abiCodes[output.filters.find { it.filterType == "ABI" }?.identifier]
        if (abiVersionCode != null) {
            (output as com.android.build.gradle.internal.api.ApkVariantOutputImpl)
                .versionCodeOverride = variant.versionCode * 10 + abiVersionCode
        }
    }
}

flutter { source = "../.." }
