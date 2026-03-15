import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let shareChannel = "app.share/native"
  private var nativeShareMethodChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = registrar(forPlugin: "NativeShareChannel") {
      nativeShareMethodChannel = FlutterMethodChannel(
        name: shareChannel,
        binaryMessenger: registrar.messenger()
      )
      nativeShareMethodChannel?.setMethodCallHandler { [weak self] call, result in
        self?.handleNativeShare(call: call, result: result)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handleNativeShare(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "shareText" else {
      result(FlutterMethodNotImplemented)
      return
    }

    guard
      let args = call.arguments as? [String: Any],
      let text = args["text"] as? String,
      !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
      result(
        FlutterError(
          code: "INVALID_ARGS",
          message: "Missing share text",
          details: nil
        )
      )
      return
    }

    let subject = args["subject"] as? String

    guard let presenter = window?.rootViewController else {
      result(
        FlutterError(
          code: "NO_VIEW_CONTROLLER",
          message: "Unable to find a root view controller",
          details: nil
        )
      )
      return
    }

    let activityVC = UIActivityViewController(
      activityItems: [text],
      applicationActivities: nil
    )
    if let subject {
      activityVC.setValue(subject, forKey: "subject")
    }

    if let popover = activityVC.popoverPresentationController {
      popover.sourceView = presenter.view
      popover.sourceRect = CGRect(
        x: presenter.view.bounds.midX,
        y: presenter.view.bounds.midY,
        width: 1,
        height: 1
      )
      popover.permittedArrowDirections = []
    }

    presenter.present(activityVC, animated: true) {
      result(true)
    }
  }
}
