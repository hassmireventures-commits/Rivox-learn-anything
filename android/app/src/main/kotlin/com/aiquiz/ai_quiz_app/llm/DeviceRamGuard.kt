package com.aiquiz.ai_quiz_app.llm

import android.app.ActivityManager
import android.content.Context

/** Refuses local LLM init on devices with insufficient total RAM to reduce OOM risk. */
object DeviceRamGuard {
    data class Result(
        val ok: Boolean,
        val totalRamBytes: Long,
        val minRequiredBytes: Long = ModelCatalog.MIN_TOTAL_RAM_BYTES,
    )

    fun check(context: Context): Result {
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val info = ActivityManager.MemoryInfo()
        am.getMemoryInfo(info)
        val total = info.totalMem
        return Result(
            ok = total >= ModelCatalog.MIN_TOTAL_RAM_BYTES,
            totalRamBytes = total,
        )
    }
}
