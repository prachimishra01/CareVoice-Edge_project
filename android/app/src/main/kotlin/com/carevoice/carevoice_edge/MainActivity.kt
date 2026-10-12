package com.carevoice.carevoice_edge

import android.content.Intent
import android.net.Uri
import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.carevoice.edge/telephony"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendNativeSms" -> {
                    val number = call.argument<String>("number")
                    val message = call.argument<String>("message")
                    if (number != null && message != null) {
                        try {
                            val smsManager: SmsManager = this.getSystemService(SmsManager::class.java)
                            smsManager.sendTextMessage(number, null, message, null, null)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SMS_FAILED", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Number or message missing", null)
                    }
                }
                "makeNativeCall" -> {
                    val number = call.argument<String>("number")
                    if (number != null) {
                        try {
                            val intent = Intent(Intent.ACTION_CALL)
                            intent.data = Uri.parse("tel:$number")
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("CALL_FAILED", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Number missing", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
