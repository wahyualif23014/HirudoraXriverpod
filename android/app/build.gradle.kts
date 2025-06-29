// C:\HirudoraXriverpod\hirudorax\android\app\build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") version "4.4.3"
}

android {
    namespace = "Hirudora.tm"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "Hirudora.tm"
        minSdk = 23 // Pastikan ini sudah 23 atau lebih
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
    // Selalu gunakan versi BoM terbaru untuk mengelola versi library Firebase.
    // Ini memastikan semua library Firebase Anda menggunakan versi yang kompatibel satu sama lain.
    implementation(platform("com.google.firebase:firebase-bom:33.16.0"))
    implementation("com.google.firebase:firebase-analytics")
    
    // Anda juga perlu menambahkan dependensi Firebase yang spesifik di sini,
    // yang mengacu pada BOM di atas. Contoh:
   

    // Kemungkinan Anda juga perlu menambahkan ini jika belum ada (misal untuk auth:email/password)
    // implementation("com.google.firebase:firebase-auth-ktx") // Jika menggunakan Kotlin Extensions (opsional)
}