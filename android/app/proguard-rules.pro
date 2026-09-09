# Flutter engine embedding — required (the framework calls into these by
# exact name from native code); narrower than a blanket io.flutter.** keep.
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Firebase, Play Services, and AdMob all ship their own consumer ProGuard
# rules bundled in their AARs, applied automatically by R8 regardless of
# this file — the app has no custom Firestore POJOs, no Crashlytics NDK, and
# no third-party ad-mediation adapters (only Google's own google_mobile_ads),
# none of which need an app-level reflection keep. The blanket
# `-keep class com.google.**.** { *; }` rules previously here kept every
# class in these (large) packages fully unobfuscated and unshrunk, which is
# what was suppressing Play Console's obfuscation score (24%, below the 25%
# minimum). -dontwarn stays — it only silences build-time missing-class
# warnings and has no effect on shrinking/obfuscation.
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# MLC LLM / TVM JNI — genuinely required: native code calls into these by
# exact class/method name.
-keep class ai.mlc.** { *; }
-keep class org.apache.tvm.** { *; }
-dontwarn ai.mlc.**
-dontwarn org.apache.tvm.**

# Play Core (optional deferred components — not bundled)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
