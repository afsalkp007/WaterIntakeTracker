import Foundation

public protocol NotificationServiceProtocol: AnyObject {
    var isAuthorized: Bool { get }
    var pendingCount: Int { get }

    func requestAuthorization() async -> Bool
    func checkAuthorization() async
    func scheduleReminders(intervalMinutes: Int, startHour: Int, endHour: Int) async
    func cancelAllReminders() async
    func sendInstantTestNotification() async
}
