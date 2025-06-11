import Flutter
import UIKit
import KakaoSDKCommon
import KakaoSDKAuth

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // ✅ Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: Config.kakaoNativeKey)
        // // print("🧪 KakaoNativeKey from Config: \(Config.kakaoNativeKey)")

        // ✅ cold start 리디렉션 처리
        if let url = launchOptions?[.url] as? URL {
            // // print("📩 [Cold Start] launchOptions URL: \(url.absoluteString)")
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }

        if let controller = window?.rootViewController as? FlutterViewController {
            // // print("FlutterViewController 연결됨")
            
            let methodChannel = FlutterMethodChannel(
                name: "com.example.root_app/share",
                binaryMessenger: controller.binaryMessenger
            )

            methodChannel.setMethodCallHandler { (call, result) in
                if call.method == "sharedText" {
                    if let sharedText = call.arguments as? String {
                        // // print("공유된 텍스트: \(sharedText)")
                    }
                    result(nil)
                }

                else if call.method == "saveAccessToken" {
                    // // print("saveAccessToken 호출됨")

                    if let accessToken = call.arguments as? String {
                        if let userDefaults = UserDefaults(suiteName: "group.com.moim.ShareExtension") {
                            userDefaults.set(accessToken, forKey: "accessToken")
                            
                            let syncResult = userDefaults.synchronize() // 🔥 명시적 저장
                            // // print("✅ accessToken App Group 저장 완료: \(accessToken) (sync: \(syncResult))")
                        } else {
                            // // print("❌ UserDefaults(suiteName:) 실패")
                        }
                    }
                    result(nil)
                }

                else {
                    result(FlutterMethodNotImplemented)
                }
            }
        } else {
            // // print("❌ RootViewController가 FlutterViewController 아님")
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // ✅ warm start 시 KakaoTalk 리디렉션 처리
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // print("📩 [Warm Start] URL opened: \(url.absoluteString)")
        if AuthApi.isKakaoTalkLoginUrl(url) {
            let result = AuthController.handleOpenUrl(url: url)
            // print("🟢 handleOpenUrl 처리 결과: \(result)")
            return result
        }
        return super.application(app, open: url, options: options)
    }
}