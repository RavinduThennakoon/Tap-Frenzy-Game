import Foundation
import UserNotifications
import CoreLocation

class NotificationService {
    static let shared = NotificationService()

    func requestPermission(completion: ((Bool, Error?) -> Void)? = nil) {
        print("Requesting notification permission...")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            print("Notification permission granted: \(granted)")
            completion?(granted, error)
        }
    }

    func scheduleDailyReminder(at time: Date) {
        let center = UNUserNotificationCenter.current()
        let identifier = "dailyChallenge"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge"
        content.body = "Come back and beat your high score in Tap-Frenzy!"
        content.sound = .default

        var components = Calendar.current.dateComponents([.hour, .minute], from: time)
        components.second = 0

        if let nextFireDate = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime, direction: .forward) {
            print("Scheduling daily reminder for time: \(time) -> next fire date: \(nextFireDate)")
        } else {
            print("Scheduling daily reminder for time: \(time) but failed to compute next fire date")
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Scheduled daily reminder with identifier: \(identifier) and components: \(components)")
            }

            center.getPendingNotificationRequests { requests in
                print("Pending notification requests count: \(requests.count)")
                for request in requests {
                    if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger {
                        let comps = calendarTrigger.dateComponents
                        // Compute a best-effort next fire date using Calendar
                        if let next = Calendar.current.nextDate(after: Date(), matching: comps, matchingPolicy: .nextTime, direction: .forward) {
                            print("Pending request id=\(request.identifier), calendar components=\(comps), next fire date=\(next)")
                        } else {
                            print("Pending request id=\(request.identifier), calendar components=\(comps), could not compute next fire date")
                        }
                    } else if let timeIntervalTrigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                        print("Pending request id=\(request.identifier), time interval=\(timeIntervalTrigger.timeInterval), repeats=\(timeIntervalTrigger.repeats)")
                    } else if let locationTrigger = request.trigger as? UNLocationNotificationTrigger {
                        print("Pending request id=\(request.identifier), location trigger region=\(locationTrigger.region.identifier), repeats=\(locationTrigger.repeats)")
                    } else {
                        print("Pending request id=\(request.identifier), trigger=\(String(describing: request.trigger))")
                    }
                }
            }
        }
    }

    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyChallenge"])
    }
}
