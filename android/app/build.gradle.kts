import java.util.Properties
import java.io.FileInputStream

// 1. Definisikan semua plugin di blok plugins
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // Menggunakan ID Kotlin DSL yang benar
    id("com.google.gms.google-services") // Menerapkan plugin Firebase di sini
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Memuat keystore.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    // Menggunakan try-catch untuk memuat properties file
    try {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    } catch (e: Exception) {
        println("Warning: Could not load key.properties file: ${e.message}")
    }
} else {
    println("Warning: key.properties file not found.")
}


android {
    // Pastikan namespace ini sesuai dengan package name di AndroidManifest.xml
    namespace = "com.belajar.privateaja"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        // GANTI applicationId ini dengan ID aplikasi Anda yang sebenarnya
        applicationId = "com.belajar.privateaja"
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // KOREKSI ULANG GARIS MERAH: Menggunakan let dan cast yang lebih aman (sebagai String?)
            keyAlias = keystoreProperties.getProperty("keyAlias")?.trim() // Trim untuk menghapus spasi tersembunyi
            keyPassword = keystoreProperties.getProperty("keyPassword")?.trim() // Trim untuk menghapus spasi tersembunyi
            // Menggunakan getProperty untuk mendapatkan path, lalu menggunakan let dan file()
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) } 
            storePassword = keystoreProperties.getProperty("storePassword")?.trim() // Trim untuk menghapus spasi tersembunyi
        }
    }

    buildTypes {
        getByName("release") {
            // Gunakan konfigurasi release, bukan debug
            signingConfig = signingConfigs.getByName("release")
            
            isMinifyEnabled = true 
            isShrinkResources = true
            // Menggunakan defaultProguardFile dengan .txt dihilangkan sesuai praktik terbaru
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro") 
        }
    }
}

flutter {
    source = "../.."
}

// Semua 'apply plugin' Groovy Dihapus di bagian bawah.
// Semua dependensi dikonversi ke sintaks Kotlin DSL (double quotes dan parenthesis).
dependencies {
    implementation("com.google.android.material:material:1.13.0")
    
    // Firebase BOM (Menggunakan sintaks Kotlin DSL)
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    
    // Tambahkan library Firebase (Menggunakan sintaks Kotlin DSL)
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx") 
    implementation("com.google.firebase:firebase-auth-ktx") // Ditambahkan: ini penting untuk auth
    implementation("com.google.firebase:firebase-messaging-ktx")
}