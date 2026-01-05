plugins {
    id("com.android.application")
    // تفعيل خدمات جوجل لربط Firebase
    id("com.google.gms.google-services")
    id("kotlin-android")
    // محرك فلاتر أندرويد
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // معرف التطبيق الفريد
    namespace = "com.example.mindtrack"

    // تم التحديث لـ 36 لأن المكتبات الجديدة تطلبه برمجياً
    compileSdk = 36
    ndkVersion = "27.3.13750724"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        // استخدام Java 17 لحل مشكلة فشل البناء السابقة
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.mindtrack"

        // يسمح بالتثبيت على أجهزة قديمة جداً (Android 5.0+)
        minSdk = flutter.minSdkVersion

        // النسخة المستهدفة للتوافق مع قوانين متجر تطبيقات جوجل
        targetSdk = 34

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}