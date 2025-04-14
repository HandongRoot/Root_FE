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

        // Flutter 채널 설정
        let controller = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "com.example.root_app/share",
                                                binaryMessenger: controller.binaryMessenger)

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

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // ✅ 카카오톡 로그인 리다이렉션 처리
    override func application(_ app: UIApplication, open url: URL,
                              options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        return super.application(app, open: url, options: options)
    }
}