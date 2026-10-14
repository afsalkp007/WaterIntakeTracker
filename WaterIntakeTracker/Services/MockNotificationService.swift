import Foundation

public final class MockNotificationService: NotificationServiceProtocol {
    public var isAuthorized: Bool
    public var pendingCount: Int = 0

    public var requestedAuthorizationCalled = false
    public var scheduledRemindersCalled = false
    public var cancelAllRemindersCalled = false
    public var sendInstantTestNotificationCalled = false

    public var lastScheduledInterval: Int?
    public var lastScheduledStartHour: Int?
    public var lastScheduledEndHour: Int?

    public init(isAuthorized: Bool = true) {
        self.isAuthorized = isAuthorized
    }

    public func requestAuthorization() async -> Bool {
        requestedAuthorizationCalled = true
        return isAuthorized
    }

    public func checkAuthorization() async {
        // Mock state retained
    }

    public func scheduleReminders(intervalMinutes: Int, startHour: Int, endHour: Int) async {
        scheduledRemindersCalled = true
        lastScheduledInterval = intervalMinutes
        lastScheduledStartHour = startHour
        lastScheduledEndHour = endHour

        let totalMinutes = max(0, (endHour - startHour) * 60)
        pendingCount = totalMinutes / max(1, intervalMinutes)
    }

    public func cancelAllReminders() async {
        cancelAllRemindersCalled = true
        pendingCount = 0
    }

    public func sendInstantTestNotification() async {
        sendInstantTestNotificationCalled = true
    }
}
