package com.example.root_app

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class ShareActivity : FlutterActivity() {

    private val CHANNEL = "com.example.root_app/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        handleShareIntent(flutterEngine)
    }

    private fun handleShareIntent(flutterEngine: FlutterEngine) {
        if (intent?.action == Intent.ACTION_SEND) {
            intent.getStringExtra(Intent.EXTRA_TEXT)?.let { sharedText ->
                val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

                // ✅ Flutter에서 데이터 처리가 끝났는지 확인하는 콜백 추가
                methodChannel.invokeMethod("sharedText", sharedText, object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        // 🟢 Flutter에서 데이터를 성공적으로 처리했으면 실행됨
                        Toast.makeText(applicationContext, "📤 공유 데이터 저장 완료!", Toast.LENGTH_SHORT).show()
                        finish() // 앱을 실행하지 않고 종료
                    }

                    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                        Toast.makeText(applicationContext, "❌ 공유 데이터 저장 실패!", Toast.LENGTH_SHORT).show()
                        finish() // 오류가 나도 종료
                    }

                    override fun notImplemented() {
                        Toast.makeText(applicationContext, "⚠️ 공유 기능이 지원되지 않음!", Toast.LENGTH_SHORT).show()
                        finish()
                    }
                })
            }
        }
    }
}
