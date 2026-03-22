// App-level build.gradle.kts
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Updated to fix build issue with plugins

    compileOptions {
        // Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing with debug keys for now
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Add core library desugaring dependency with updated version
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.2.2")
    
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
    
    // Add Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")
    
    // Add Firebase Messaging for notifications
    implementation("com.google.firebase:firebase-messaging")
}
