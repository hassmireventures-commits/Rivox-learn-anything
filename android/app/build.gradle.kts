import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

val hasMlc4j = findProject(":mlc4j") != null

val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

val allowDebugSigning =
    (project.findProperty("ALLOW_DEBUG_SIGNING") as String?) == "true" ||
        System.getenv("ALLOW_DEBUG_SIGNING") == "true"

android {
    namespace = "com.aiquiz.ai_quiz_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.aiquiz.ai_quiz_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Floor at 21 for youtube_player_flutter / WebView (user requirement ≥ 20).
        minSdk = maxOf(flutter.minSdkVersion, 21)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        resValue("string", "app_name", "Rivox")

        // Do not set ndk.abiFilters here — it conflicts with
        // `flutter build apk --release --split-per-abi`. Prefer split-per-abi
        // (or `--target-platform=android-arm64`) to control ABIs.

        buildConfigField("boolean", "HAS_MLC4J", hasMlc4j.toString())
    }

    buildFeatures {
        buildConfig = true
    }

    // Real MLCEngine binding when mlc4j is packaged; stub otherwise (see docs/MLC_ANDROID_SETUP.md).
    sourceSets {
        getByName("main") {
            java.srcDir(if (hasMlc4j) "src/mlcEnabled/kotlin" else "src/mlcStub/kotlin")
        }
    }

    packaging {
        jniLibs {
            // Uncompressed native libs for mmap / 16 KB page alignment compliance.
            useLegacyPackaging = false
        }
    }

    signingConfigs {
        create("release") {
            if (keyPropertiesFile.exists()) {
                keyAlias = keyProperties["keyAlias"] as String
                keyPassword = keyProperties["keyPassword"] as String
                storeFile = file(keyProperties["storeFile"] as String)
                storePassword = keyProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Prefer android/key.properties (gitignored). CI compile checks may set
            // ALLOW_DEBUG_SIGNING=true; Play Store uploads must use a real upload key.
            signingConfig = when {
                keyPropertiesFile.exists() -> signingConfigs.getByName("release")
                allowDebugSigning -> signingConfigs.getByName("debug")
                else -> throw GradleException(
                    "Release signing required. Add android/key.properties " +
                        "(see android/key.properties.example) or set ALLOW_DEBUG_SIGNING=true " +
                        "for local/CI compile-only builds.",
                )
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            // Skip mapping upload for local release APKs (can hang without Crashlytics DNS).
            // Re-enable for Play Store CI if you need deobfuscated crash stacks.
            firebaseCrashlytics {
                mappingFileUploadEnabled = false
            }
        }
    }
}

// Hard-disable Crashlytics mapping upload tasks (plugin may still schedule them).
tasks.configureEach {
    if (name.startsWith("uploadCrashlyticsMappingFile")) {
        enabled = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
    if (hasMlc4j) {
        implementation(project(":mlc4j"))
    }
}
