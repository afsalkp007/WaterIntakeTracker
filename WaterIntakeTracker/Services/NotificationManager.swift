import Foundation
import UserNotifications
import Combine

@MainActor
public final class NotificationManager: ObservableObject, NotificationServiceProtocol {
    public static let shared = NotificationManager()

    @Published public var isAuthorized: Bool = false
    @Published public var pendingCount: Int = 0

    private let reminderCategoryIdentifier = "HYDRATION_REMINDER"

    private let motivationalMessages: [(title: String, body: String)] = [
        ("Time for water! 💧", "Take a refreshing sip to stay energized and focused."),
        ("Hydration Check ✨", "A glass of water now keeps fatigue away!"),
        ("Drink Up! 🌊", "Keep your hydration streak alive. Your goal is waiting!"),
        ("Sip, Smile, Repeat ☀️", "Your body and brain will thank you for this glass."),
        ("Water Break 🚰", "Step away, stretch, and drink a fresh glass of water.")
    ]

    private init() {
        Task {
            await checkAuthorization()
        }
    }

    public func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            self.isAuthorized = granted
            await updatePendingCount()
            return granted
        } catch {
            print("Notification authorization error: \(error.localizedDescription)")
            self.isAuthorized = false
            return false
        }
    }

    public func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        self.isAuthorized = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
        await updatePendingCount()
    }

    public func updatePendingCount() async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        self.pendingCount = requests.filter { $0.identifier.starts(with: "water_reminder_") }.count
    }

    public func scheduleReminders(intervalMinutes: Int, startHour: Int, endHour: Int) async {
        let center = UNUserNotificationCenter.current()

        // Remove old hydration reminders
        let pending = await center.pendingNotificationRequests()
        let oldIds = pending.map(\.identifier).filter { $0.starts(with: "water_reminder_") }
        center.removePendingNotificationRequests(withIdentifiers: oldIds)

        guard isAuthorized else { return }

        var messageIndex = 0
        let clampedStart = max(0, min(23, startHour))
        let clampedEnd = max(clampedStart + 1, min(24, endHour))
        let step = max(30, intervalMinutes)

        var currentMinuteOfDay = clampedStart * 60

        while currentMinuteOfDay < (clampedEnd * 60) {
            let hour = currentMinuteOfDay / 60
            let minute = currentMinuteOfDay % 60

            let content = UNMutableNotificationContent()
            let msg = motivationalMessages[messageIndex % motivationalMessages.count]
            content.title = msg.title
            content.body = msg.body
            content.sound = .default
            content.categoryIdentifier = reminderCategoryIdentifier

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "water_reminder_\(hour)_\(minute)",
                content: content,
                trigger: trigger
            )

            try? await center.add(request)
            messageIndex += 1
            currentMinuteOfDay += step
        }

        await updatePendingCount()
    }

    public func cancelAllReminders() async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let oldIds = pending.map(\.identifier).filter { $0.starts(with: "water_reminder_") }
        center.removePendingNotificationRequests(withIdentifiers: oldIds)
        await updatePendingCount()
    }

    public func sendInstantTestNotification() async {
        if !isAuthorized {
            let granted = await requestAuthorization()
            guard granted else { return }
        }

        let content = UNMutableNotificationContent()
        content.title = "Hydration Test Reminder 💧"
        content.body = "Great job setting up your water intake tracker! Keep sipping."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "water_reminder_test_\(UUID().uuidString)", content: content, trigger: trigger)

        try? await UNUserNotificationCenter.current().add(request)
        await updatePendingCount()
    }
}
