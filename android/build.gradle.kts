// rootProject/build.gradle.kts (atau yang serupa)

buildscript {
    // Definisi versi yang disatukan di blok ini
    // Menggunakan versi Kotlin dan Google Services terbaru yang sudah kita gunakan di app/build.gradle.kts
    val kotlin_version = "1.9.0" 
    val google_services_version = "4.4.1" 
    val agp_version = "8.9.1" // Versi Android Gradle Plugin

    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Android Gradle Plugin
        classpath("com.android.tools.build:gradle:$agp_version")
        
        // Kotlin Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        
        // Google Services Plugin (Firebase)
        classpath("com.google.gms:google-services:$google_services_version") 
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Catatan: Kode di bawah ini (untuk mengatur ulang buildDir)
// biasanya ditempatkan di settings.gradle.kts, bukan build.gradle.kts, 
// dan sering kali tidak diperlukan dalam proyek Flutter standar. 
// Saya akan HILANGKAN bagian yang kompleks ini untuk meminimalisir risiko build error.

/* === PENGATURAN BUILD DIR ===
val newBuildDir: Directory =
     rootProject.layout.buildDirectory
         .dir("../../build")
         .get()
 rootProject.layout.buildDirectory.value(newBuildDir)
/ ... dst*/

// === DAFTAR TUGAS UTAMA ===
/* Default clean task — WAJIB ADA (menggunakan tipe task Delete)
tasks.register<Delete>("clean") {
    // Menghapus folder build root proyek
    delete(rootProject.layout.buildDirectory) 
}*/

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
