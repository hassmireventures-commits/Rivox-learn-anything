# MLC LLM Android setup (on-device engine)

Learn Anything uses [MLC LLM](https://llm.mlc.ai/docs/deploy/android.html) for optional **on-device** inference. There is **no public Maven artifact**; you must package a local `mlc4j` Gradle module, then point this app at it.

**Product status:** On-device LLM is currently marked **Coming soon** in the app (`kLocalLlmComingSoon` in `lib/core/services/local_llm_flags.dart`). Users cannot select it in onboarding or Settings until packaging/`mlc4j` is ready; flip that flag to `false` to re-enable.

Cloud providers stay in Dart. Native Android only runs local MLC inference, RAM checks, and model downloads.

## Prerequisites

- Physical arm64 Android device with a real GPU (emulator is not supported)
- Android NDK (demo builds use NDK 27.x), CMake, Rust (`rustc` / `cargo` / `rustup`)
- OpenJDK 17+ — prefer Android Studio’s JBR; on Windows copy JBR to a path **without spaces**
- Conda env with the [MLC LLM Python package](https://llm.mlc.ai/docs/install/mlc_llm.html)

Environment variables (adjust paths):

```bash
export ANDROID_NDK=.../ndk/27.0.11718014
export TVM_NDK_CC=$ANDROID_NDK/toolchains/llvm/prebuilt/<host>/bin/aarch64-linux-android24-clang
export JAVA_HOME=...   # no spaces on Windows
export TVM_SOURCE_DIR=/path/to/mlc-llm/3rdparty/tvm
export MLC_LLM_SOURCE_DIR=/path/to/mlc-llm
```

## Package `mlc4j` into this repo

1. Clone MLC LLM and init submodules:

```bash
git clone https://github.com/mlc-ai/mlc-llm.git
cd mlc-llm && git submodule update --init --recursive
```

2. Copy or edit [`android/mlc/mlc-package-config.json`](../android/mlc/mlc-package-config.json) (small q4f16 chat model).

3. From `android/mlc` in **this** project:

```bash
cd /path/to/learn-anything/android/mlc
export MLC_LLM_SOURCE_DIR=/absolute/path/to/mlc-llm
mlc_llm package
```

Expected output: `android/mlc/dist/lib/mlc4j/` with `libtvm4j_runtime_packed.so`, `tvm4j_core.jar`, and Java sources.

4. Re-sync Gradle. [`settings.gradle.kts`](../android/settings.gradle.kts) includes `:mlc4j` **only when** that directory exists. The app then compiles the real `LocalLLMEngine` against `MLCEngine`.

**Windows helper:** from the repo root (after setting `MLC_LLM_SOURCE_DIR`):

```powershell
powershell -ExecutionPolicy Bypass -File scripts\package_mlc.ps1
```

### Windows host packaging caveats (2026-07)

Packaging on Windows with PyPI `apache-tvm-ffi==0.1.12` + current `mlc-ai-nightly-cpu` win wheels is **blocked**: `tvm_compiler.dll` expects a newer `json::Stringify(Any, const Optional<int>&)` ABI; rewriting import names to the 0.1.12 by-value export loads TVM but **access-violates in `tvm_ffi.dll`** when the compiler parses TIR (`attach_sampler`). Prefer one of:

1. **Linux or WSL2** — install matching `mlc-llm-nightly-cpu` + `mlc-ai-nightly-cpu` manylinux wheels, set `MLC_LLM_SOURCE_DIR` / NDK, run `mlc_llm package` (or `scripts/package_mlc.ps1` via WSL).
2. **Build a newer `apache-tvm-ffi`** from [apache/tvm-ffi](https://github.com/apache/tvm-ffi) `main` with MSVC Build Tools, replace `site-packages/tvm_ffi/lib/tvm_ffi.dll`, then re-run package (do **not** binary-rename Stringify imports).
3. **Drop-in prebuilt** `android/mlc/dist/lib/mlc4j` from a machine that already packaged successfully.

Repo helpers: `scripts/mlc_package_launch.py`, `scripts/mlc_compile_launch.py`, `scripts/mlc_tvm_compat.py` (PrimExpr / SizeVar / `is_size_var` kwargs only — they cannot fix the native FFI ABI).

Without `mlc4j`, the app still builds: local generate returns a clear “native runtime not packaged” error. Drop a prebuilt `android/mlc/dist/lib/mlc4j` (with `build.gradle` / `build.gradle.kts`) into place to enable the engine without re-running package.

## Model weights

MLC uses **MLC-converted Hugging Face weight folders**, not GGUF.

- Default download URL and `model_lib` id are in `ModelCatalog` (Kotlin) / mirrored in Dart config.
- On first local-engine selection, `DownloadManager` fetches the configured archive into `filesDir/models/<model_id>/`.
- **Required:** host a **zip of the entire weight directory** (must include `mlc-chat-config.json` + all shards). A single `params_shard_*.bin` is incomplete — the app will not mark the model ready.
- How to produce the zip: download the HF folder for your model (e.g. `mlc-ai/phi-2-q4f16_1-MLC`), zip its contents, host it (HTTPS), set `ModelCatalog.DEFAULT_WEIGHTS_ARCHIVE_URL`.
- Or use `bundle_weight` + MLC’s `bundle_weight.py` for release APKs.
- Settings → AI Providers shows storage path, download progress, Online/runtime status, and **Delete model** to free space.

## Delete on-device model

Channel method `deleteModel` removes `filesDir/models/<model_id>/`, cancels any DownloadManager job, and clears partial external download files.
## 16 KB page size / packaging

App module uses:

```kotlin
packaging {
    jniLibs {
        useLegacyPackaging = false
    }
}
```

so native libs can be memory-mapped. ABI is limited to `arm64-v8a`.

## ProGuard

Release keeps `ai.mlc.**` and TVM JNI symbols (see `proguard-rules.pro`).

## Flutter bridge

Channel name: `com.aiquiz.ai_quiz_app/local_llm`

| Method | Purpose |
|--------|---------|
| `checkRam` | `{ ok, totalRamBytes, minRequiredBytes }` — requires ≥ 6 GB total RAM |
| `isModelReady` | whether weights exist under `filesDir` |
| `startModelDownload` | enqueue DownloadManager; returns download id |
| `getDownloadStatus` | poll download / extract status |
| `generate` | `{ prompt, systemPrompt }` → completion text |
