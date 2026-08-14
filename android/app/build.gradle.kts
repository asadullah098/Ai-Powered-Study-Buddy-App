plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.yourcompany.study_buddy"
    compileSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Changed from 1_8
        targetCompatibility = JavaVersion.VERSION_17  // Changed from 1_8
    }

    kotlinOptions {
        jvmTarget = "17"  // Changed from "1.8"
    }

    defaultConfig {
        applicationId = "com.yourcompany.study_buddy"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
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
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("androidx.multidex:multidex:2.0.1")
}

apply(plugin = "com.google.gms.google-services")
