import SwiftUI
import SwiftData

@main
struct MyApp: App {
    @AppStorage("remindersEnabled") private var remindersEnabled: Bool = true
    @AppStorage("reminderIntervalMinutes") private var reminderIntervalMinutes: Int = 90
    @AppStorage("reminderStartHour") private var reminderStartHour: Int = 8
    @AppStorage("reminderEndHour") private var reminderEndHour: Int = 21

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Check and schedule reminders on app launch if enabled
                    let notificationManager = NotificationManager.shared
                    await notificationManager.checkAuthorization()
                    if remindersEnabled && notificationManager.isAuthorized {
                        await notificationManager.scheduleReminders(
                            intervalMinutes: reminderIntervalMinutes,
                            startHour: reminderStartHour,
                            endHour: reminderEndHour
                        )
                    }
                }
        }
        .modelContainer(for: WaterLog.self)
    }
}
