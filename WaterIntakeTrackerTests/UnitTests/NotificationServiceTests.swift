import Foundation
import XCTest
@testable import WaterIntakeTracker

public final class NotificationServiceTests: XCTestCase {

    public func testMockNotificationServiceAuthorization() async {
        let mock = MockNotificationService(isAuthorized: true)
        let granted = await mock.requestAuthorization()

        XCTAssertTrue(granted)
        XCTAssertTrue(mock.requestedAuthorizationCalled)
    }

    public func testMockNotificationScheduling() async {
        let mock = MockNotificationService(isAuthorized: true)

        // Schedule between 8 AM (8) and 8 PM (20) every 60 mins -> 12 reminders
        await mock.scheduleReminders(intervalMinutes: 60, startHour: 8, endHour: 20)

        XCTAssertTrue(mock.scheduledRemindersCalled)
        XCTAssertEqual(mock.lastScheduledInterval, 60)
        XCTAssertEqual(mock.lastScheduledStartHour, 8)
        XCTAssertEqual(mock.lastScheduledEndHour, 20)
        XCTAssertEqual(mock.pendingCount, 12)
    }

    public func testMockNotificationCancellation() async {
        let mock = MockNotificationService(isAuthorized: true)
        await mock.scheduleReminders(intervalMinutes: 60, startHour: 9, endHour: 17)
        XCTAssertGreaterThan(mock.pendingCount, 0)

        await mock.cancelAllReminders()
        XCTAssertTrue(mock.cancelAllRemindersCalled)
        XCTAssertEqual(mock.pendingCount, 0)
    }

    public func testMockInstantNotification() async {
        let mock = MockNotificationService(isAuthorized: true)
        await mock.sendInstantTestNotification()
        XCTAssertTrue(mock.sendInstantTestNotificationCalled)
    }
}
