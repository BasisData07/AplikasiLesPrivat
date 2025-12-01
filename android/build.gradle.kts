buildscript {
    ext.kotlin_version = '1.7.10' // Sesuaikan versi Kotlin
    dependencies {
        // 🔥 PASTIKAN BARIS INI ADA DI buildscript > dependencies
        classpath 'com.google.gms:google-services:4.4.0' // Versi terbaru, periksa Firebase docs jika ada versi baru
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

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
