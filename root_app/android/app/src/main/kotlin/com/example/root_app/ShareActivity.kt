package com.example.root_app

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import okhttp3.*
import org.json.JSONObject
import java.io.IOException
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody // ✅ 추가

class ShareActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 공유된 텍스트 데이터 가져오기
        if (intent?.action == Intent.ACTION_SEND) {
            val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
            if (sharedText != null) {
                showSaveDialog(sharedText)
            } else {
                finish() // 데이터 없으면 종료
            }
        } else {
            finish() // 다른 액션이면 종료
        }
    }

    private fun showSaveDialog(sharedText: String) {
        val dialog = AlertDialog.Builder(this)
            .setTitle("공유 저장")
            .setMessage("이 링크를 저장하시겠습니까?\n$sharedText")
            .setPositiveButton("저장") { _, _ ->
                sendToServer(sharedText)
            }
            .setNegativeButton("취소") { _, _ ->
                finish()
            }
            .setOnDismissListener {
                finish() // 다이얼로그 닫히면 종료
            }
            .create()

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
