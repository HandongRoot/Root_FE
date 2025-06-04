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

        print("🧪 KakaoNativeKey from Config: \(Config.kakaoNativeKey)")

        // ✅ cold start 시 리디렉션 URL 처리
        if let url = launchOptions?[.url] as? URL {
            print("📩 [Cold Start] launchOptions URL: \(url.absoluteString)")
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }

        // ✅ Flutter 채널 설정
        if let controller = window?.rootViewController as? FlutterViewController {
            let methodChannel = FlutterMethodChannel(
                name: "com.example.root_app/share",
                binaryMessenger: controller.binaryMessenger
            )

            methodChannel.setMethodCallHandler { (call, result) in
                if call.method == "sharedText" {
                    if let sharedText = call.arguments as? String {
                        print("공유된 텍스트: \(sharedText)")
                    }
                    result(nil)
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
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
        print("📩 [Warm Start] URL opened: \(url.absoluteString)")
        if AuthApi.isKakaoTalkLoginUrl(url) {
            let result = AuthController.handleOpenUrl(url: url)
            print("🟢 handleOpenUrl 처리 결과: \(result)")
            return result
        }
        return super.application(app, open: url, options: options)
    }
}