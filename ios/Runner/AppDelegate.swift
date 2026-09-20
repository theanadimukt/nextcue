import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let appGroupIdentifier = "group.app.nextcue.share-spike"
  private static let evidenceKey = "lastShareEvidence"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "app.nextcue/share-evidence",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "getLastShareEvidence" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let evidence = UserDefaults(
        suiteName: AppDelegate.appGroupIdentifier
      )?.dictionary(forKey: AppDelegate.evidenceKey)
      result(evidence)
    }
  }
}
