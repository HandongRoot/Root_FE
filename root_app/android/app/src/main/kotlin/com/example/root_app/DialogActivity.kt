package com.example.root_app

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.view.Gravity
import android.view.LayoutInflater
import android.view.Window
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.IOException

class DialogActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 공유된 텍스트 데이터 가져오기
        val sharedText = intent?.getStringExtra(Intent.EXTRA_TEXT) ?: ""
        println("📡 공유된 텍스트: $sharedText") // ✅ 로그 추가

        if (sharedText.isEmpty()) {
            println("🚨 공유된 텍스트가 비어 있음! 앱 종료")
            finish()
            return
        }

        // 다이얼로그 스타일 적용
        val dialogView = LayoutInflater.from(this).inflate(R.layout.dialog_share, null)
        val dialog = AlertDialog.Builder(this)
            .setView(dialogView)
            .setCancelable(true)
            .create()

        // 다이얼로그 창 스타일 변경 (아래에서 올라오는 애니메이션)
        val window = dialog.window
        if (window != null) {
            window.setGravity(Gravity.BOTTOM)
            window.setLayout(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.WRAP_CONTENT
            )
            window.attributes.windowAnimations = android.R.style.Animation_InputMethod // 애니메이션 추가
        }

        // XML 요소 가져오기
        val shareText = dialogView.findViewById<TextView>(R.id.share_text)
        val confirmButton = dialogView.findViewById<Button>(R.id.confirm_button)
        val cancelButton = dialogView.findViewById<Button>(R.id.cancel_button)

        shareText.text = "링크를 저장하시겠습니까?\n$sharedText"

        confirmButton.setOnClickListener {
            println("📡 저장 버튼 클릭됨, 서버 전송 시작!")
            sendToServer(sharedText)
            dialog.dismiss()
        }

        cancelButton.setOnClickListener {
            Toast.makeText(this, "저장 취소", Toast.LENGTH_SHORT).show()
            println("🚨 저장 취소됨")
            dialog.dismiss()
            finish()
        }

        dialog.show()
    }

    private fun sendToServer(sharedText: String) {
        val baseUrl = BuildConfig.BASE_URL  // ✅ BuildConfig에서 BASE_URL 가져오기
        val userId = BuildConfig.USER_ID    // ✅ BuildConfig에서 USER_ID 가져오기
        val url = "$baseUrl/api/v1/content/$userId"  // ✅ 올바른 엔드포인트 설정

        val client = OkHttpClient()

        val jsonObject = JSONObject().apply {
            put("title", "공유된 링크")
            put("thumbnail", "")
            put("linkedUrl", sharedText)
        }

        val jsonBody = jsonObject.toString()  // ✅ JSON 문자열로 변환
        println("📡 보낼 JSON 데이터: $jsonBody") // ✅ 요청 본문 확인 로그 추가

        // ✅ body 변수를 명확하게 선언
        val body: RequestBody = jsonBody.toRequestBody("application/json; charset=utf-8".toMediaType())

        val request = Request.Builder()
            .url(url)  // ✅ 최종 요청 URL
            .post(body)  // ✅ 여기에 body 변수를 올바르게 전달
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                runOnUiThread {
                    println("🚨 요청 실패: ${e.message}")
                    Toast.makeText(applicationContext, "저장 실패: ${e.message}", Toast.LENGTH_LONG).show()
                    finish()
                }
            }

            override fun onResponse(call: Call, response: Response) {
                runOnUiThread {
                    val responseBody = response.body?.string()
                    println("📡 서버 응답 코드: ${response.code}")  // ✅ 응답 코드 로그 출력
                    println("📡 서버 응답 본문: $responseBody")  // ✅ 응답 본문 로그 출력

                    if (response.isSuccessful) {
                        Toast.makeText(applicationContext, "✅ 저장 성공!", Toast.LENGTH_SHORT).show()
                    } else {
                        Toast.makeText(applicationContext, "❌ 저장 실패: ${response.code}", Toast.LENGTH_SHORT).show()
                    }

                    finish()
                }
            }
        })
    }
}
