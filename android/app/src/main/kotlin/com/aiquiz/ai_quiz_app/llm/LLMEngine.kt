package com.aiquiz.ai_quiz_app.llm

/**
 * Abstraction so callers do not care whether inference is local (MLC) or cloud (Dart).
 * Cloud lives in Flutter; this interface is implemented by [LocalLLMEngine] on Android.
 */
interface LLMEngine {
    suspend fun generateResponse(prompt: String, systemPrompt: String): String
}
