package com.aiquiz.ai_quiz_app.llm

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

/**
 * Stub when `mlc4j` is not packaged. Keeps the Flutter channel API stable.
 * See docs/MLC_ANDROID_SETUP.md to enable the real [MLCEngine] binding.
 */
class LocalLLMEngine(
    private val modelPath: String,
    private val modelLib: String = ModelCatalog.MODEL_LIB,
) : LLMEngine {

    val isRuntimeAvailable: Boolean = false

    fun ensureInitialized() {
        if (!File(modelPath).exists()) {
            throw IllegalStateException("Model path missing: $modelPath")
        }
        throw IllegalStateException(
            "MLC native runtime not packaged. Run mlc_llm package and sync Gradle " +
                "(see docs/MLC_ANDROID_SETUP.md).",
        )
    }

    override suspend fun generateResponse(prompt: String, systemPrompt: String): String =
        withContext(Dispatchers.Default) {
            ensureInitialized()
            error("unreachable")
        }
}
