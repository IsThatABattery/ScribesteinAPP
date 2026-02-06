import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
        }

        Messaging.messaging().delegate = self
        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard fcmToken != nil else { return }
        //Messaging.messaging().subscribe(toTopic: "new_transcript")
        Messaging.messaging().subscribe(toTopic: "important_message")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { (notifications) in
            let eightHoursAgo = Date().addingTimeInterval(-8 * 60 * 60)
            var notificationsToRemove: [String] = []

            for notification in notifications {
                if notification.date < eightHoursAgo {
                    notificationsToRemove.append(notification.request.identifier)
                }
            }

            if !notificationsToRemove.isEmpty {
                center.removeDeliveredNotifications(withIdentifiers: notificationsToRemove)
            }
            completionHandler(.newData)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    // Optional: show alerts while app is foregrounded
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,

                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
}
