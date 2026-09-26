import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let appGroupIdentifier = "group.app.nextcue.share-spike"
  private static let evidenceKey = "lastShareEvidence"
  private static let queueDirectoryName = "pending-handoffs"
  private static let repositoryDirectoryName = "spike-captures"
  private var importStatus = AppDelegate.unavailableStatus

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let launched = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    importStatus = runImport()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(importWhenEnteringForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
    return launched
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "app.nextcue/share-evidence",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(Self.unavailableStatus)
        return
      }
      switch call.method {
      case "getImportStatus":
        result(self.importStatus)
      case "retryImport":
        self.importStatus = self.runImport()
        result(self.importStatus)
      case "simulateOptionalFailure":
        self.importStatus = self.runImport(simulateOptionalFailure: true)
        result(self.importStatus)
      case "getLastShareEvidence":
        let evidence = UserDefaults(
          suiteName: AppDelegate.appGroupIdentifier
        )?.dictionary(forKey: AppDelegate.evidenceKey)
        result(evidence)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  @objc private func importWhenEnteringForeground() {
    importStatus = runImport()
  }

  private func runImport(simulateOptionalFailure: Bool = false) -> [String: Any] {
    guard
      let container = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier
      )
    else { return Self.unavailableStatus }

    let summary = HandoffImporter(
      queue: HandoffQueue(
        directoryURL: container.appendingPathComponent(Self.queueDirectoryName)
      ),
      repository: SpikeCaptureRepository(
        directoryURL: container.appendingPathComponent(Self.repositoryDirectoryName)
      )
    ).importPending { _ in
      if simulateOptionalFailure { throw SimulatedOptionalFailure() }
    }
    return summary.propertyList
  }

  private static let unavailableStatus: [String: Any] = [
    "schemaVersion": 1,
    "status": "storage_unavailable",
    "pendingCount": 0,
    "captureCount": 0,
    "importedCount": 0,
    "duplicateCount": 0,
    "rejectedCount": 0,
    "queueFailureCount": 1,
    "repositoryFailureCount": 0,
    "acknowledgementFailureCount": 0,
    "optionalFailureCount": 0,
  ]
}

private struct SimulatedOptionalFailure: Error {}
