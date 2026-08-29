pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("com.google.firebase.crashlytics") version "3.0.3" apply false
}

include(":app")

// Local MLC runtime produced by `mlc_llm package` under android/mlc (see docs/MLC_ANDROID_SETUP.md).
val mlc4jDir = file("mlc/dist/lib/mlc4j")
val mlcGradle = mlc4jDir.resolve("build.gradle")
val mlcGradleKts = mlc4jDir.resolve("build.gradle.kts")
if (mlc4jDir.exists() && (mlcGradle.exists() || mlcGradleKts.exists())) {
    include(":mlc4j")
    project(":mlc4j").projectDir = mlc4jDir
}
