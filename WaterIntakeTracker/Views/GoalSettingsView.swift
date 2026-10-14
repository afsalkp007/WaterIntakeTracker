import SwiftUI

public struct GoalSettingsView: View {
    @AppStorage("dailyGoalMl") private var dailyGoalMl: Double = 2500.0
    @AppStorage("remindersEnabled") private var remindersEnabled: Bool = true
    @AppStorage("reminderIntervalMinutes") private var reminderIntervalMinutes: Int = 90
    @AppStorage("reminderStartHour") private var reminderStartHour: Int = 8
    @AppStorage("reminderEndHour") private var reminderEndHour: Int = 21

    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingPermissionAlert = false
    @State private var testNotificationScheduled = false

    private let goalPresets: [Double] = [1500, 2000, 2500, 3000, 3500]
    private let intervalOptions: [(label: String, minutes: Int)] = [
        ("Every 1 hour", 60),
        ("Every 1.5 hours", 90),
        ("Every 2 hours", 120),
        ("Every 3 hours", 180)
    ]

    public init() {}

    private func presetLabel(for preset: Double) -> String {
        let liters = preset / 1000.0
        if preset.truncatingRemainder(dividingBy: 1000) == 0 {
            return "\(Int(liters))L"
        } else {
            return String(format: "%.1fL", liters)
        }
    }

    public var body: some View {
        NavigationStack {
            Form {
                // Section 1: Daily Target
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Target")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(dailyGoalMl)) ml")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.cyan)
                        }

                        // Presets
                        HStack(spacing: 8) {
                            ForEach(goalPresets, id: \.self) { preset in
                                Button(action: {
                                    dailyGoalMl = preset
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                }) {
                                    Text(presetLabel(for: preset))
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(dailyGoalMl == preset ? Color.cyan : Color(.systemGray6))
                                        .foregroundColor(dailyGoalMl == preset ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // Fine adjustment slider
                        Slider(value: $dailyGoalMl, in: 800...5000, step: 50)
                            .tint(.cyan)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label("Daily Hydration Goal", systemImage: "target")
                } footer: {
                    Text("The recommended daily water intake is typically 2,000 to 3,000 ml depending on your activity level and climate.")
                }

                // Section 2: Smart Hydration Reminders
                Section {
                    Toggle("Enable Hydration Reminders", isOn: $remindersEnabled)
                        .tint(.cyan)
                        .onChange(of: remindersEnabled) { _, newValue in
                            Task {
                                if newValue {
                                    let granted = await notificationManager.requestAuthorization()
                                    if granted {
                                        await scheduleActiveReminders()
                                    } else {
                                        remindersEnabled = false
                                        showingPermissionAlert = true
                                    }
                                } else {
                                    await notificationManager.cancelAllReminders()
                                }
                            }
                        }

                    if remindersEnabled {
                        Picker("Reminder Interval", selection: $reminderIntervalMinutes) {
                            ForEach(intervalOptions, id: \.minutes) { option in
                                Text(option.label).tag(option.minutes)
                            }
                        }
                        .onChange(of: reminderIntervalMinutes) { _, _ in
                            Task { await scheduleActiveReminders() }
                        }

                        Picker("Wake / Start Hour", selection: $reminderStartHour) {
                            ForEach(6...12, id: \.self) { hour in
                                Text("\(formatHour(hour))").tag(hour)
                            }
                        }
                        .onChange(of: reminderStartHour) { _, _ in
                            Task { await scheduleActiveReminders() }
                        }

                        Picker("Sleep / End Hour", selection: $reminderEndHour) {
                            ForEach(18...23, id: \.self) { hour in
                                Text("\(formatHour(hour))").tag(hour)
                            }
                        }
                        .onChange(of: reminderEndHour) { _, _ in
                            Task { await scheduleActiveReminders() }
                        }

                        Button(action: {
                            Task {
                                await notificationManager.sendInstantTestNotification()
                                withAnimation {
                                    testNotificationScheduled = true
                                }
                                try? await Task.sleep(nanoseconds: 4_000_000_000)
                                withAnimation {
                                    testNotificationScheduled = false
                                }
                            }
                        }) {
                            HStack {
                                Label("Send Test Reminder", systemImage: "bell.badge")
                                Spacer()
                                if testNotificationScheduled {
                                    Text("Delivering in 3s...")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                } header: {
                    Label("Local Reminders", systemImage: "bell.fill")
                } footer: {
                    if remindersEnabled {
                        Text("Reminders are scheduled locally on your device between \(formatHour(reminderStartHour)) and \(formatHour(reminderEndHour)). Active queued: \(notificationManager.pendingCount)")
                    } else {
                        Text("Enable reminders to receive gentle nudges throughout your day to drink water.")
                    }
                }

                // Section 3: About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Persistence Engine")
                        Spacer()
                        Text("SwiftData (Local On-Device)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Goal & Settings")
            .task {
                await notificationManager.checkAuthorization()
            }
            .alert("Notifications Disabled", isPresented: $showingPermissionAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enable notifications in iOS Settings to receive hydration reminders.")
            }
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour % 12 == 0 ? 12 : hour % 12
        return "\(displayHour):00 \(period)"
    }

    private func scheduleActiveReminders() async {
        await notificationManager.scheduleReminders(
            intervalMinutes: reminderIntervalMinutes,
            startHour: reminderStartHour,
            endHour: reminderEndHour
        )
    }
}
