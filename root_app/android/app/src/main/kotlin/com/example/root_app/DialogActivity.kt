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

        // 다이얼로그 스타일 적용
        val dialogView = LayoutInflater.from(this).inflate(R.layout.dialog_share, null)
        val dialog = AlertDialog.Builder(this)
            .setView(dialogView)
            .setCancelable(true)
            .create()

        // 다이얼로그 창 스타일 변경 (아래에서 올라오는 애니메이션)
        val window = dialog.window
        if (window != null) {
            window.setGravity(Gravity.BOTTOM)  // 아래에서 올라오도록 설정
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

        val sharedText = intent?.getStringExtra(Intent.EXTRA_TEXT) ?: ""
        shareText.text = "링크를 저장하시겠습니까?\n$sharedText"

        confirmButton.setOnClickListener {
            sendToServer(sharedText)
            dialog.dismiss()
        }

        cancelButton.setOnClickListener {
            Toast.makeText(this, "저장 취소", Toast.LENGTH_SHORT).show()
            dialog.dismiss()
            finish()
        }

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

        val body = jsonObject.toString().toRequestBody("application/json; charset=utf-8".toMediaType())

        val request = Request.Builder()
            .url(url)
            .post(body)
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                runOnUiThread {
                    Toast.makeText(applicationContext, "저장 실패: ${e.message}", Toast.LENGTH_LONG).show()
                    finish()
                }
            }

            override fun onResponse(call: Call, response: Response) {
                runOnUiThread {
                    if (response.isSuccessful) {
                        Toast.makeText(applicationContext, "저장 성공!", Toast.LENGTH_SHORT).show()
                    } else {
                        Toast.makeText(applicationContext, "저장 실패: 서버 응답 오류", Toast.LENGTH_SHORT).show()
                    }
                    finish()
                }
            }
        })
    }
}
