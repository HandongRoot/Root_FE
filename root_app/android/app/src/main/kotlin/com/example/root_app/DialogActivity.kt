package com.example.root_app

import android.content.Intent
import android.app.Activity
import android.app.AlertDialog
import android.os.Bundle
import android.view.Gravity
import android.view.LayoutInflater
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import org.jsoup.Jsoup  // ✅ 웹사이트 HTML 파싱을 위한 Jsoup 추가
import java.io.IOException

class DialogActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 공유된 텍스트 데이터 가져오기
        val sharedText = intent?.getStringExtra(Intent.EXTRA_TEXT) ?: ""
        println("📡 공유된 텍스트: $sharedText")

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

        val window = dialog.window
        window?.setGravity(Gravity.BOTTOM)
        window?.setLayout(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT
        )
        window?.attributes?.windowAnimations = android.R.style.Animation_InputMethod

        // XML 요소 가져오기
        val shareText = dialogView.findViewById<TextView>(R.id.share_text)
        val confirmButton = dialogView.findViewById<Button>(R.id.confirm_button)
        val cancelButton = dialogView.findViewById<Button>(R.id.cancel_button)

        shareText.text = "링크를 저장하시겠습니까?\n$sharedText"

        confirmButton.setOnClickListener {
            println("📡 저장 버튼 클릭됨, 서버 전송 시작!")
            processLinkAndSend(sharedText)
            dialog.dismiss()
            finish()
        }

        cancelButton.setOnClickListener {
            Toast.makeText(this, "저장 취소", Toast.LENGTH_SHORT).show()
            println("🚨 저장 취소됨")
            dialog.dismiss()
            finish()
        }

        dialog.show()
    }

    private fun processLinkAndSend(url: String) {
        val youtubeId = extractYouTubeId(url)

        if (youtubeId != null) {
            fetchYoutubeData(youtubeId, url)
        } else {
            fetchWebPageData(url)
        }
    }

    // ✅ YouTube 링크 ID 추출
    private fun extractYouTubeId(url: String): String? {
        val patterns = listOf(
            "youtube\\.com/shorts/([0-9A-Za-z_-]{11})".toRegex(),
            "youtu\\.be/([0-9A-Za-z_-]{11})".toRegex(),
            "youtube\\.com/watch\\?v=([0-9A-Za-z_-]{11})".toRegex()
        )

        for (pattern in patterns) {
            val match = pattern.find(url)
            if (match != null) return match.groupValues[1]
        }
        return null
    }

    // ✅ YouTube API로 영상 정보 가져오기
    private fun fetchYoutubeData(videoId: String, originalUrl: String) {
        val apiKey = BuildConfig.YOUTUBE_API_KEY  // 🔹 local.properties → BuildConfig에서 가져오기
        val url = "https://www.googleapis.com/youtube/v3/videos?id=$videoId&key=$apiKey&part=snippet"

        val client = OkHttpClient()
        val request = Request.Builder().url(url).build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                println("🚨 YouTube API 요청 실패: ${e.message}")
                sendToServer("YouTube 영상", "https://img.youtube.com/vi/$videoId/hqdefault.jpg", originalUrl)
            }

            override fun onResponse(call: Call, response: Response) {
                response.body?.string()?.let { responseBody ->
                    val jsonResponse = JSONObject(responseBody)
                    val items = jsonResponse.optJSONArray("items")

                    if (items != null && items.length() > 0) {
                        val snippet = items.getJSONObject(0).getJSONObject("snippet")
                        val title = snippet.getString("title")
                        val thumbnail = snippet.getJSONObject("thumbnails").getJSONObject("high").getString("url")

                        sendToServer(title, thumbnail, originalUrl)
                    } else {
                        sendToServer("YouTube 영상", "https://img.youtube.com/vi/$videoId/hqdefault.jpg", originalUrl)
                    }
                }
            }
        })
    }

    private fun extractInstagramPostId(url: String): String? {
        val regex = "instagram\\.com/(p|reel)/([A-Za-z0-9_-]+)/?".toRegex()
        val match = regex.find(url)
        return match?.groupValues?.get(2)
    }

    // ✅ 일반 웹사이트 제목 및 썸네일 가져오기
    private fun fetchWebPageData(url: String) {
        Thread {
            try {
                val client = OkHttpClient()
                val request = Request.Builder()
                    .url(url)
                    .header(
                        "User-Agent",
                        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
                    )
                    .header("Accept-Language", "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7")
                    .build()

                val response = client.newCall(request).execute()
                val responseBody = response.body?.string()

                if (responseBody != null) {
                    val doc = Jsoup.parse(responseBody)
                    var title = doc.title()
                    var thumbnail = ""

                    // ✅ Open Graph (og:image) 가져오기
                    val metaTags = doc.select("meta[property=og:image], meta[name=og:image]")
                    if (metaTags.isNotEmpty()) {
                        thumbnail = metaTags.first()?.attr("content") ?: ""
                    }

                    // ✅ Instagram 게시물 & 릴스에서 제목(캡션) 가져오기
                    if (url.contains("instagram.com/p/") || url.contains("instagram.com/reel/")) {
                        val postId = extractInstagramPostId(url)
                        if (postId != null) {
                            thumbnail = "https://www.instagram.com/p/$postId/media/?size=l"
                        }

                        // 🔥 HTML에서 JSON 데이터 추출하여 캡션 가져오기
                        val scripts = doc.select("script[type=text/javascript]")
                        for (script in scripts) {
                            val scriptContent = script.html()
                            if (scriptContent.contains("window.__additionalDataLoaded")) {
                                val jsonStart = scriptContent.indexOf("{")
                                val jsonEnd = scriptContent.lastIndexOf("}") + 1
                                if (jsonStart != -1 && jsonEnd != -1) {
                                    val jsonData = scriptContent.substring(jsonStart, jsonEnd)
                                    val jsonObject = JSONObject(jsonData)

                                    // ✅ Instagram 게시물의 캡션 (텍스트) 가져오기
                                    val media = jsonObject.optJSONObject("graphql")?.optJSONObject("shortcode_media")
                                    if (media != null) {
                                        title = media.optJSONObject("edge_media_to_caption")
                                            ?.optJSONArray("edges")
                                            ?.optJSONObject(0)
                                            ?.optJSONObject("node")
                                            ?.optString("text", title) ?: title
                                    }
                                }
                            }
                        }
                    }

                    // ✅ 특정 사이트 (Instagram, Twitter, Facebook 등) 기본 썸네일 제공
                    if (thumbnail.isEmpty()) {
                        when {
                            url.contains("instagram.com") -> {
                                thumbnail = "https://www.instagram.com/static/images/ico/favicon-192.png"
                            }
                            url.contains("twitter.com") -> {
                                thumbnail = "https://abs.twimg.com/icons/apple-touch-icon-192x192.png"
                            }
                            url.contains("facebook.com") -> {
                                thumbnail = "https://www.facebook.com/images/fb_icon_325x325.png"
                            }
                            else -> {
                                thumbnail = "https://ssl.pstatic.net/static/pwe/address/img_profile.png"
                            }
                        }
                    }

                    println("📌 최종 제목(캡션): $title")
                    println("📌 최종 썸네일: $thumbnail")

                    sendToServer(title, thumbnail, url)
                } else {
                    println("🚨 응답 본문이 비어 있음")
                    sendToServer(url, "https://ssl.pstatic.net/static/pwe/address/img_profile.png", url)
                }
            } catch (e: Exception) {
                println("🚨 웹페이지 파싱 실패: ${e.message}")
                sendToServer(url, "https://ssl.pstatic.net/static/pwe/address/img_profile.png", url)
            }
        }.start()
    }

    // ✅ 서버로 데이터 전송
    private fun sendToServer(title: String, thumbnail: String, linkedUrl: String) {
        val baseUrl = BuildConfig.BASE_URL
        val userId = BuildConfig.USER_ID
        val url = "$baseUrl/api/v1/content/$userId"

        val client = OkHttpClient()

        val jsonObject = JSONObject().apply {
            put("title", title)
            put("thumbnail", thumbnail)
            put("linkedUrl", linkedUrl)
        }

        val body = jsonObject.toString().toRequestBody("application/json; charset=utf-8".toMediaType())

        val request = Request.Builder().url(url).post(body).build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                println("🚨 요청 실패: ${e.message}")
            }

            override fun onResponse(call: Call, response: Response) {
                println("📡 서버 응답 코드: ${response.code}")
            }
        })
    }
}