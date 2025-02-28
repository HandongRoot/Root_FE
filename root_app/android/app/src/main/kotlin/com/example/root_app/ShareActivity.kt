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
        val url = "https://your-backend.com/api/v1/content"
        val client = OkHttpClient()

        val jsonObject = JSONObject().apply {
            put("title", "공유된 링크")
            put("thumbnail", "")
            put("linkedUrl", sharedText)
        }

        // ✅ MediaType 수정
        val mediaType = "application/json; charset=utf-8".toMediaType()
        val body = jsonObject.toString().toRequestBody(mediaType) // ✅ 최신 방식 적용

        val request = Request.Builder()
            .url(url)
            .post(body)
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                runOnUiThread {
                    Toast.makeText(applicationContext, "저장 실패", Toast.LENGTH_SHORT).show()
                    finish()
                }
            }

            override fun onResponse(call: Call, response: Response) {
                runOnUiThread {
                    Toast.makeText(applicationContext, "저장 성공!", Toast.LENGTH_SHORT).show()
                    finish()
                }
            }
        })
    }
}
