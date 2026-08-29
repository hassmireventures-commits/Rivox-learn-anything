package com.aiquiz.ai_quiz_app.llm

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class LlmMethodChannel(
    private val context: Context,
    messenger: BinaryMessenger,
) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private val downloads = ModelDownloadService(context)
    private var engine: LocalLLMEngine? = null

    private val channel = MethodChannel(messenger, CHANNEL_NAME)

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkRam" -> {
                    val ram = DeviceRamGuard.check(context)
                    result.success(
                        mapOf(
                            "ok" to ram.ok,
                            "totalRamBytes" to ram.totalRamBytes,
                            "minRequiredBytes" to ram.minRequiredBytes,
                        ),
                    )
                }
                "isModelReady" -> {
                    val modelId = call.argument<String>("modelId") ?: ModelCatalog.MODEL_ID
                    result.success(downloads.isModelReady(modelId))
                }
                "startModelDownload" -> {
                    val url = call.argument<String>("url")
                    val modelId = call.argument<String>("modelId") ?: ModelCatalog.MODEL_ID
                    try {
                        val id = downloads.startDownload(url, modelId)
                        result.success(mapOf("downloadId" to id))
                    } catch (e: Exception) {
                        result.error(
                            "download_failed",
                            e.message?.takeIf { it.isNotBlank() && !it.contains("/data/") }
                                ?: "Could not start model download. Check network and try again.",
                            null,
                        )
                    }
                }
                "getDownloadStatus" -> {
                    val id = (call.argument<Number>("downloadId"))?.toLong()
                    result.success(downloads.queryStatus(id ?: -1L))
                }
                "modelPath" -> {
                    val modelId = call.argument<String>("modelId") ?: ModelCatalog.MODEL_ID
                    result.success(downloads.modelDir(modelId).absolutePath)
                }
                "deleteModel" -> {
                    val modelId = call.argument<String>("modelId") ?: ModelCatalog.MODEL_ID
                    try {
                        engine = null
                        val ok = downloads.deleteModel(modelId)
                        result.success(ok)
                    } catch (e: Exception) {
                        result.error("delete_failed", e.message ?: "Could not delete model", null)
                    }
                }
                "generate" -> {
                    val prompt = call.argument<String>("prompt")
                    val systemPrompt = call.argument<String>("systemPrompt")
                        ?: DEFAULT_SYSTEM_PROMPT
                    if (prompt.isNullOrBlank()) {
                        result.error("bad_args", "prompt is required", null)
                        return@setMethodCallHandler
                    }
                    scope.launch {
                        try {
                            val text = generateOnDevice(prompt, systemPrompt)
                            result.success(text)
                        } catch (e: Exception) {
                            result.error("generate_failed", e.message, null)
                        }
                    }
                }
                "hasMlcRuntime" -> {
                    result.success(
                        try {
                            LocalLLMEngine(
                                downloads.modelDir().absolutePath,
                            ).isRuntimeAvailable
                        } catch (_: Exception) {
                            false
                        },
                    )
                }
                else -> result.notImplemented()
            }
        }
    }

    private suspend fun generateOnDevice(prompt: String, systemPrompt: String): String {
        val ram = DeviceRamGuard.check(context)
        if (!ram.ok) {
            throw IllegalStateException(
                "Device has insufficient RAM for on-device LLM " +
                    "(need at least ${ram.minRequiredBytes / (1024 * 1024 * 1024)} GB total).",
            )
        }
        if (!downloads.isModelReady()) {
            throw IllegalStateException(
                "On-device model is not ready. Download weights first.",
            )
        }
        val local = engine ?: LocalLLMEngine(downloads.modelDir().absolutePath).also { engine = it }
        return local.generateResponse(prompt, systemPrompt)
    }

    companion object {
        const val CHANNEL_NAME = "com.aiquiz.ai_quiz_app/local_llm"
        const val DEFAULT_SYSTEM_PROMPT =
            "You are a helpful, safe app assistant. Do not generate harmful content."
    }
}
