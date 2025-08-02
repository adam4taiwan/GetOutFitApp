// @dart=2.12
// This file is used to configure your Android app's build process.
// It is written in Kotlin DSL, which is a modern way to configure Gradle builds.

fun getFlutterProjectProperty(name: String, defaultValue: String): String {
    return project.properties[name] as String? ?: defaultValue
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app"
    compileSdk = getFlutterProjectProperty("flutter.compileSdkVersion", "35").toInt()
    ndkVersion = "27.0.12077973" // 修復 NDK 版本不匹配問題

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.app"
        minSdk = getFlutterProjectProperty("flutter.minSdkVersion", "21").toInt()
        targetSdk = getFlutterProjectProperty("flutter.targetSdkVersion", "34").toInt()
        versionCode = getFlutterProjectProperty("flutter.versionCode", "1").toInt()
        versionName = getFlutterProjectProperty("flutter.versionName", "1.0.0")
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 解決日誌中的 ClassNotFoundException 錯誤
    implementation("androidx.window:window:1.0.0")
    // 其他依賴項...
}

