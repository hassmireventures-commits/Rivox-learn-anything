package com.aiquiz.ai_quiz_app.llm

import android.app.DownloadManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import com.aiquiz.ai_quiz_app.BuildConfig
import java.io.BufferedInputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.security.MessageDigest
import java.util.zip.ZipInputStream
import kotlin.concurrent.thread

/**
 * Streams model weights via [DownloadManager] into app-specific external files,
 * then copies into filesDir/models for LocalLLMEngine.
 */
class ModelDownloadService(private val context: Context) {

    private val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
    private val dm = context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager

    fun modelDir(modelId: String = ModelCatalog.MODEL_ID): File {
        return File(context.filesDir, "models/$modelId").also { it.mkdirs() }
    }

    fun isModelReady(modelId: String = ModelCatalog.MODEL_ID): Boolean {
        val dir = modelDir(modelId)
        // Strict: full MLC weight tree requires chat config (single shard is incomplete).
        return File(dir, "mlc-chat-config.json").exists()
    }

    /** Deletes on-disk weights, cancels in-flight download, clears download prefs. */
    fun deleteModel(modelId: String = ModelCatalog.MODEL_ID): Boolean {
        val downloadId = prefs.getLong(KEY_DOWNLOAD_ID, -1L)
        if (downloadId >= 0) {
            try {
                dm.remove(downloadId)
            } catch (_: Exception) {
            }
        }
        val destPath = prefs.getString(KEY_DEST, null)
        if (!destPath.isNullOrBlank()) {
            File(destPath).delete()
        }
        val externalRoot = context.getExternalFilesDir(null)
        if (externalRoot != null) {
            File(externalRoot, "$modelId-download.bin").delete()
        }
        val dir = File(context.filesDir, "models/$modelId")
        val deleted = if (dir.exists()) dir.deleteRecursively() else true
        prefs.edit()
            .remove(KEY_DOWNLOAD_ID)
            .remove(KEY_MODEL_ID)
            .remove(KEY_DEST)
            .apply()
        return deleted
    }

    fun startDownload(url: String? = null, modelId: String = ModelCatalog.MODEL_ID): Long {
        val existing = prefs.getLong(KEY_DOWNLOAD_ID, -1L)
        if (existing >= 0 && queryStatus(existing)["status"] == "running") {
            return existing
        }

        val archiveUrl = url?.takeIf { it.isNotBlank() } ?: ModelCatalog.DEFAULT_WEIGHTS_ARCHIVE_URL
        val fileName = "$modelId-download.bin"
        // DownloadManager cannot write to internal cache/filesDir — use app external files.
        val externalRoot = context.getExternalFilesDir(null)
            ?: throw IllegalStateException("External storage unavailable for model download.")
        val dest = File(externalRoot, fileName)
        if (dest.exists()) dest.delete()

        val request = DownloadManager.Request(Uri.parse(archiveUrl))
            .setTitle("Rivox model")
            .setDescription("Downloading on-device LLM weights")
            .setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE)
            .setAllowedOverMetered(true)
            .setAllowedOverRoaming(false)
            .setDestinationInExternalFilesDir(context, null, fileName)

        val id = try {
            dm.enqueue(request)
        } catch (e: IllegalArgumentException) {
            throw IllegalStateException("Could not start model download. Check network and try again.")
        }

        prefs.edit()
            .putLong(KEY_DOWNLOAD_ID, id)
            .putString(KEY_MODEL_ID, modelId)
            .putString(KEY_DEST, dest.absolutePath)
            .apply()

        registerCompletionReceiver(id, modelId, dest)
        return id
    }

    fun queryStatus(downloadId: Long = prefs.getLong(KEY_DOWNLOAD_ID, -1L)): Map<String, Any?> {
        if (downloadId < 0) {
            return mapOf(
                "status" to if (isModelReady()) "ready" else "idle",
                "downloadId" to downloadId,
                "bytesDownloaded" to 0L,
                "bytesTotal" to -1L,
            )
        }

        val query = DownloadManager.Query().setFilterById(downloadId)
        dm.query(query)?.use { cursor ->
            if (!cursor.moveToFirst()) {
                return mapOf("status" to "unknown", "downloadId" to downloadId)
            }
            val status = cursor.getInt(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_STATUS))
            val downloaded = cursor.getLong(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR))
            val total = cursor.getLong(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_TOTAL_SIZE_BYTES))
            val reason = if (status == DownloadManager.STATUS_FAILED) {
                cursor.getInt(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_REASON))
            } else {
                0
            }

            val mapped = when (status) {
                DownloadManager.STATUS_SUCCESSFUL -> {
                    val modelId = prefs.getString(KEY_MODEL_ID, ModelCatalog.MODEL_ID) ?: ModelCatalog.MODEL_ID
                    val destPath = prefs.getString(KEY_DEST, null)
                    if (destPath != null && !isModelReady(modelId)) {
                        finalizeDownload(File(destPath), modelId)
                    }
                    if (isModelReady(modelId)) "ready" else "extracting"
                }
                DownloadManager.STATUS_FAILED -> "failed"
                DownloadManager.STATUS_PAUSED -> "paused"
                DownloadManager.STATUS_PENDING -> "pending"
                DownloadManager.STATUS_RUNNING -> "running"
                else -> "unknown"
            }

            return mapOf(
                "status" to mapped,
                "downloadId" to downloadId,
                "bytesDownloaded" to downloaded,
                "bytesTotal" to total,
                "reason" to reason,
            )
        }
        return mapOf("status" to "unknown", "downloadId" to downloadId)
    }

    private fun registerCompletionReceiver(id: Long, modelId: String, dest: File) {
        val filter = IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE)
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context?, intent: Intent?) {
                val completedId = intent?.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1L) ?: return
                if (completedId != id) return
                try {
                    context.unregisterReceiver(this)
                } catch (_: Exception) {
                }
                thread {
                    finalizeDownload(dest, modelId)
                }
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            context.registerReceiver(receiver, filter)
        }
    }

    private fun finalizeDownload(archive: File, modelId: String) {
        if (!archive.exists()) return
        val outDir = modelDir(modelId)
        try {
            verifyArchiveSha256(archive)
            if (isZip(archive)) {
                unzip(archive, outDir)
            } else {
                val safeName = archive.name.replace(Regex("[^a-zA-Z0-9._-]"), "_")
                val target = File(outDir, safeName).canonicalFile
                if (!target.path.startsWith(outDir.canonicalFile.path + File.separator) &&
                    target.path != outDir.canonicalFile.path
                ) {
                    throw SecurityException("Refusing to write model file outside target directory")
                }
                archive.copyTo(target, overwrite = true)
            }
            // Only mark ready when a complete MLC weight tree is present.
            if (File(outDir, "mlc-chat-config.json").exists()) {
                File(outDir, READY_MARKER).writeText("ok")
            } else {
                File(outDir, READY_MARKER).delete()
            }
        } catch (_: Exception) {
            // Status stays non-ready; Flutter can surface retry.
        } finally {
            archive.delete()
        }
    }

    private fun verifyArchiveSha256(archive: File) {
        val expected = ModelCatalog.EXPECTED_ARCHIVE_SHA256.trim().lowercase()
        if (expected.isEmpty()) {
            // Dev may skip the pin; release builds must not extract unpinned archives.
            if (!BuildConfig.DEBUG) {
                throw SecurityException(
                    "Model archive SHA-256 pin is required in release builds"
                )
            }
            return
        }
        val digest = MessageDigest.getInstance("SHA-256")
        FileInputStream(archive).use { fis ->
            val buffer = ByteArray(DEFAULT_BUFFER_SIZE)
            while (true) {
                val read = fis.read(buffer)
                if (read <= 0) break
                digest.update(buffer, 0, read)
            }
        }
        val actual = digest.digest().joinToString("") { b -> "%02x".format(b) }
        if (actual != expected) {
            throw SecurityException("Model archive SHA-256 mismatch (expected pin failed)")
        }
    }

    private fun isZip(file: File): Boolean {
        if (!file.exists() || file.length() < 4) return false
        FileInputStream(file).use { fis ->
            val sig = ByteArray(4)
            if (fis.read(sig) != 4) return false
            return sig[0] == 0x50.toByte() && sig[1] == 0x4B.toByte()
        }
    }

    /** Zip Slip–safe extraction: reject `..`, absolute paths, and escapes from [targetDir]. */
    private fun unzip(zipFile: File, targetDir: File) {
        val canonicalTarget = targetDir.canonicalFile
        canonicalTarget.mkdirs()
        ZipInputStream(BufferedInputStream(FileInputStream(zipFile))).use { zis ->
            var entry = zis.nextEntry
            while (entry != null) {
                val name = entry.name.replace('\\', '/')
                if (name.isBlank() || name.startsWith("/") || name.contains("..")) {
                    throw SecurityException("Unsafe zip entry rejected: $name")
                }
                val outFile = File(canonicalTarget, name).canonicalFile
                if (!outFile.path.startsWith(canonicalTarget.path + File.separator) &&
                    outFile.path != canonicalTarget.path
                ) {
                    throw SecurityException("Zip Slip rejected: $name")
                }
                if (entry.isDirectory) {
                    outFile.mkdirs()
                } else {
                    outFile.parentFile?.mkdirs()
                    FileOutputStream(outFile).use { fos ->
                        zis.copyTo(fos)
                    }
                }
                zis.closeEntry()
                entry = zis.nextEntry
            }
        }
    }

    companion object {
        private const val PREFS = "local_llm_download"
        private const val KEY_DOWNLOAD_ID = "download_id"
        private const val KEY_MODEL_ID = "model_id"
        private const val KEY_DEST = "dest_path"
        private const val READY_MARKER = ".model_ready"
    }
}
