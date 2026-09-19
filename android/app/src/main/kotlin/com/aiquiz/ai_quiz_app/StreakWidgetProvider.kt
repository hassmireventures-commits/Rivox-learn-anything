package com.aiquiz.ai_quiz_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * B19 — home-screen widget showing the learner's current streak.
 *
 * Deliberately does NOT use home_widget's own [es.antonborri.home_widget.HomeWidgetLaunchIntent]
 * (which tags the launch Intent with a custom action the app doesn't otherwise listen for).
 * Instead it fires a plain ACTION_VIEW intent carrying the same "learnanything://…" URI this
 * app's existing app_links-based deep link handling already understands (see
 * MainActivity's intent-filter in AndroidManifest.xml and DeepLinkHandler on the Dart side) —
 * reusing infrastructure that already works, rather than adopting a second, parallel
 * widget-click-to-Dart mechanism just for this one tap target.
 */
class StreakWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val streak = widgetData.getInt("currentStreak", 0)
        val deepLink = widgetData.getString("deepLink", null) ?: "learnanything://dashboard"

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.streak_widget).apply {
                setTextViewText(R.id.streak_widget_count, streak.toString())
                setTextViewText(R.id.streak_widget_label, "day streak. Tap to continue")

                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    action = Intent.ACTION_VIEW
                    data = Uri.parse(deepLink)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                var flags = PendingIntent.FLAG_UPDATE_CURRENT
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    flags = flags or PendingIntent.FLAG_IMMUTABLE
                }
                val pendingIntent = PendingIntent.getActivity(context, 0, launchIntent, flags)
                setOnClickPendingIntent(R.id.streak_widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
