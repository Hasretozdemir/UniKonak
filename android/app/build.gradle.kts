plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase için gerekli
}

android {
    namespace = "com.example.flutter_application_1" // Paket adın
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.example.flutter_application_1"
        // Harita ve Firebase için genelde en az 21 önerilir ama 
        // flutter.minSdkVersion hata verirse burayı elle 'minSdk = 21' yapabilirsin.
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // --- KRİTİK DÜZELTME BURADA YAPILDI ---
            // Hata almamak için her ikisi de FALSE olmalı
            isMinifyEnabled = false
            isShrinkResources = false 
            
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            // Release modunda çalışırken imza hatası almamak için debug anahtarını kullanıyoruz:
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Flutter projelerinde burası genelde boş kalır,
    // paketler pubspec.yaml üzerinden otomatik eklenir.
}