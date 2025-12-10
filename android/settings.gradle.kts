pluginManagement {
    // 1. Mengambil lokasi Flutter SDK dari local.properties
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    // 2. Memasukkan konfigurasi Gradle dari Flutter SDK
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// 3. Mendefinisikan semua plugin yang digunakan dalam proyek
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    
    // Perbaikan Versi: Menggunakan AGP 8.1.0 agar konsisten dengan build.gradle.kts
    id("com.android.application") version "8.9.1" apply false 
    
    // START: FlutterFire Configuration
    // Perbaikan Versi: Menggunakan Google Services 4.4.1 agar konsisten
    id("com.google.gms.google-services") version "4.4.1" apply false 
    // END: FlutterFire Configuration
    
    // Perbaikan Versi: Menggunakan Kotlin 1.9.0 agar konsisten
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

// 4. Memasukkan module utama aplikasi
include(":app")