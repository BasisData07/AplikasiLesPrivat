import java.util.Properties
import java.io.FileInputStream


plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Memuat keystore.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
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
            // Menggunakan safe cast (as String?) untuk menghindari crash jika key.properties kosong
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            // Gunakan konfigurasi release, bukan debug
            signingConfig = signingConfigs.getByName("release")
            
            // Opsional: Aktifkan ini untuk mengecilkan ukuran APK (Proguard/R8)
            isMinifyEnabled = true 
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

//apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation("com.google.android.material:material:1.13.0")
    implementation(platform('com.google.firebase:firebase-bom:32.7.0'))
    // Tambahkan library yang Anda pakai
    implementation 'com.google.firebase:firebase-analytics-ktx'
    implementation 'com.google.firebase:firebase-firestore-ktx' // Untuk Fires
    // Tambahkan dependensi lain jika perlu
}

apply plugin: 'com.google.gms.google-services'