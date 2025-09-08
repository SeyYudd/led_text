import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}
android {
    namespace = "com.kakasey.digitaltextlumi"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

     compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.kakasey.digitaltextlumi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 4
        versionName = "1.0.4"
        multiDexEnabled = true
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

    }

    signingConfigs {
        create("release") {
            // // It's recommended to load these from a separate properties file (e.g., key.properties)
            // // that is excluded from version control (e.g., via .gitignore) for security.
            // // Example loading from a properties file:
            // val keystoreProperties = java.util.Properties().apply {
            //     load(java.io.FileInputStream(rootProject.file("key.properties")))
            // }

            storeFile = file("../app/my-key.jks")
            storePassword = "ledkonser"
            keyAlias = "my-key-alias"
            keyPassword = "ledkonser"
        }
    }
    buildTypes {
        getByName("debug") {
            // signingConfig = signingConfigs.getByName("debug")
            isDebuggable = true
        }
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
            isDebuggable = false

        }
    }
      // Split APK berdasarkan arsitektur (opsional)
    bundle {
        language {
            enableSplit = true
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }
}

flutter {
    source = "../.."
}
