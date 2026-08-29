package com.aiquiz.ai_quiz_app.llm

import ai.mlc.mlcllm.MLCEngine
import ai.mlc.mlcllm.OpenAIProtocol
import ai.mlc.mlcllm.OpenAIProtocol.ChatCompletionMessage
import ai.mlc.mlcllm.OpenAIProtocol.ChatCompletionRole
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

/**
 * On-device engine backed by MLC [MLCEngine] (OpenAI-compatible chat completions).
 * Requires packaged `mlc4j` — see docs/MLC_ANDROID_SETUP.md.
 */
class LocalLLMEngine(
    private val modelPath: String,
    private val modelLib: String = ModelCatalog.MODEL_LIB,
) : LLMEngine {

    val isRuntimeAvailable: Boolean = true

    private val engine = MLCEngine()
    @Volatile private var loaded = false

    @Synchronized
    fun ensureInitialized() {
        if (loaded) return
        if (!File(modelPath).exists()) {
            throw IllegalStateException("Model path missing: $modelPath")
        }
        engine.unload()
        engine.reload(modelPath, modelLib)
        loaded = true
    }

    override suspend fun generateResponse(prompt: String, systemPrompt: String): String =
        withContext(Dispatchers.Default) {
            ensureInitialized()
            val messages = buildList {
                if (systemPrompt.isNotBlank()) {
                    add(
                        ChatCompletionMessage(
                            role = ChatCompletionRole.system,
                            content = systemPrompt,
                        ),
                    )
                }
                add(
                    ChatCompletionMessage(
                        role = ChatCompletionRole.user,
                        content = prompt,
                    ),
                )
            }

            val channel = engine.chat.completions.create(
                messages = messages,
                stream_options = OpenAIProtocol.StreamOptions(include_usage = false),
            )

            val sb = StringBuilder()
            for (response in channel) {
                if (response.choices.isNotEmpty()) {
                    sb.append(response.choices[0].delta.content?.asText().orEmpty())
                }
            }
            val text = sb.toString().trim()
            text.ifEmpty { "Error: No response generated locally." }
        }
}
