plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.my_wird"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.my_wird"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = "sara_omar" // اسم المفتاح
            keyPassword = "Saavedra04012021" // كلمة مرور المفتاح
            storeFile = file("C:\\Users\\Data Analyst\\my_wird\\my-wird-key.jks") // مسار Keystore الصحيح
            storePassword = "Saavedra04012021" // كلمة مرور Keystore
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release") // الإصلاح هنا
        }
    }
}

flutter {
    source = "../.."
}