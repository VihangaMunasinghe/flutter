import Flutter
import UIKit
import FirebaseCore
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var apnsChannel: FlutterMethodChannel?
  private var notificationEventSink: FlutterEventSink?
  private var cachedApnsToken: String?
  private var pendingLaunchNotification: [String: Any]?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
    GeneratedPluginRegistrant.register(with: self)
      
    let registrar = self.registrar(forPlugin: "com.wso2.authenticator")!
    let messenger = registrar.messenger()

    apnsChannel = FlutterMethodChannel(
      name: "com.wso2.authenticator/apns",
      binaryMessenger: messenger
    )

    let notificationEventChannel = FlutterEventChannel(
      name: "com.wso2.authenticator/apns_notifications",
      binaryMessenger: messenger
    )
    notificationEventChannel.setStreamHandler(ApnsStreamHandler(appDelegate: self))

    apnsChannel?.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "getApnsToken":
        result(self?.cachedApnsToken)
      case "requestPermission":
        UNUserNotificationCenter.current().requestAuthorization(
          options: [.alert, .badge, .sound]
        ) { granted, error in
          if granted {
            DispatchQueue.main.async {
              application.registerForRemoteNotifications()
            }
          }
          DispatchQueue.main.async {
            result(granted)
          }
        }
      case "getInitialNotification":
        let notification = self?.pendingLaunchNotification
        self?.pendingLaunchNotification = nil
        result(notification)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    UNUserNotificationCenter.current().delegate = self

      if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
             let plist = NSDictionary(contentsOfFile: path),
             let bundleId = plist["BUNDLE_ID"] as? String,
             bundleId == Bundle.main.bundleIdentifier {
            //Check if Firebase is already configured before configuring it
            if FirebaseApp.app() == nil {
              FirebaseApp.configure()
            }
          }

    if let notification = launchOptions?[.remoteNotification] as? [String: Any] {
      pendingLaunchNotification = notification
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - APNS Token

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let token = deviceToken.map { String(format: "%02x", $0) }.joined()
    cachedApnsToken = token
    apnsChannel?.invokeMethod("onTokenReceived", arguments: token)
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register for remote notifications: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  // MARK: - Remote Notification Reception

  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    let payload = convertToStringKeyedDict(userInfo)

    if application.applicationState == .active {
      notificationEventSink?(payload)
    } else {
      storePendingNotification(payload)
      notificationEventSink?(payload)
    }

    super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
  }

  // MARK: - UNUserNotificationCenterDelegate

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let payload = convertToStringKeyedDict(notification.request.content.userInfo)
    notificationEventSink?(payload)
    super.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let payload = convertToStringKeyedDict(response.notification.request.content.userInfo)
    notificationEventSink?(payload)
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }

  // MARK: - Helpers

  func setEventSink(_ sink: FlutterEventSink?) {
    notificationEventSink = sink
  }

  private func convertToStringKeyedDict(_ dict: [AnyHashable: Any]) -> [String: Any] {
    var result = [String: Any]()
    for (key, value) in dict {
      if let stringKey = key as? String {
        result[stringKey] = value
      }
    }
    return result
  }

  private func storePendingNotification(_ payload: [String: Any]) {
    guard payload["pushId"] != nil else { return }
    if let data = try? JSONSerialization.data(withJSONObject: payload),
       let jsonString = String(data: data, encoding: .utf8) {
      UserDefaults.standard.set(jsonString, forKey: "flutter.pending_push_notification")
    }
  }
}

// MARK: - EventChannel Stream Handler

class ApnsStreamHandler: NSObject, FlutterStreamHandler {
  weak var appDelegate: AppDelegate?

  init(appDelegate: AppDelegate) {
    self.appDelegate = appDelegate
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    appDelegate?.setEventSink(events)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    appDelegate?.setEventSink(nil)
    return nil
  }
}
