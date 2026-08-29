package com.aiquiz.ai_quiz_app

import com.aiquiz.ai_quiz_app.llm.LlmMethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        LlmMethodChannel(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
    }
}
