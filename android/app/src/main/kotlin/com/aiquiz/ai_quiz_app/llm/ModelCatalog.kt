package com.aiquiz.ai_quiz_app.llm

/**
 * Catalog for the default on-device MLC model.
 *
 * [weightsArchiveUrl] must be a **zip of the full MLC weight directory**
 * (containing `mlc-chat-config.json` + shards), not a single GGUF or one shard `.bin`.
 * Host that zip and set [DEFAULT_WEIGHTS_ARCHIVE_URL] — see docs/MLC_ANDROID_SETUP.md.
 *
 * [modelLib] must match the system library prefix compiled into mlc4j for this model.
 */
object ModelCatalog {
    const val MODEL_ID = "phi-2-q4f16_1-MLC"
    const val MODEL_LIB = "phi_msft_q4f16_1"

    /** Minimum total device RAM before initializing the local engine. */
    const val MIN_TOTAL_RAM_BYTES: Long = 6L * 1024L * 1024L * 1024L

    /**
     * Must point at a zip of the HF MLC weight folder for [MODEL_ID].
     * A single shard URL will download but will NOT be treated as ready
     * (missing `mlc-chat-config.json`).
     *
     * Placeholder — replace with your hosted full-weight zip before relying on Download.
     */
    const val DEFAULT_WEIGHTS_ARCHIVE_URL =
        "https://huggingface.co/mlc-ai/phi-2-q4f16_1-MLC/resolve/main/params_shard_0.bin"

    /**
     * Lowercase hex SHA-256 of [DEFAULT_WEIGHTS_ARCHIVE_URL] contents.
     * Empty = skip pin in **debug** only. Release builds refuse download/extract
     * when this is empty (see [ModelDownloadService.verifyArchiveSha256]).
     */
    const val EXPECTED_ARCHIVE_SHA256: String = ""
}
