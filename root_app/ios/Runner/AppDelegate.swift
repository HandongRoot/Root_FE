import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
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
}
