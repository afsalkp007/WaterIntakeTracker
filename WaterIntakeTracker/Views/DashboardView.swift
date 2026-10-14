import SwiftUI
import SwiftData

public struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Query(sort: \WaterLog.timestamp, order: .reverse) private var allLogs: [WaterLog]
    @AppStorage("dailyGoalMl") private var dailyGoalMl: Double = 2500.0

    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingCustomLogSheet = false

    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }

    private var todayLogs: [WaterLog] {
        viewModel.todayLogs(from: allLogs)
    }

    private var todayIntakeMl: Double {
        viewModel.todayIntake(from: allLogs)
    }

    private var todayEffectiveIntakeMl: Double {
        viewModel.todayEffectiveIntake(from: allLogs)
    }

    private var currentStreakDays: Int {
        viewModel.streakDays(from: allLogs, goal: dailyGoalMl)
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            Group {
                if isLandscape {
                    landscapeLayout
                } else {
                    portraitLayout
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCustomLogSheet) {
                LogCustomDrinkSheet { amount, type, time, note in
                    viewModel.logDrink(
                        amountMl: amount,
                        type: type,
                        timestamp: time,
                        note: note,
                        dailyGoal: dailyGoalMl,
                        context: modelContext,
                        allLogs: allLogs
                    )
                }
            }
        }
    }

    // MARK: - Portrait Layout
    private var portraitLayout: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                    .padding(.horizontal)

                WaveProgressView(currentMl: todayIntakeMl, goalMl: dailyGoalMl)
                    .padding(.vertical, 4)

                statsRow
                    .padding(.horizontal)

                QuickAddCard(
                    onAdd: { amount, type in
                        viewModel.logDrink(
                            amountMl: amount,
                            type: type,
                            dailyGoal: dailyGoalMl,
                            context: modelContext,
                            allLogs: allLogs
                        )
                    },
                    onCustomTap: {
                        showingCustomLogSheet = true
                    }
                )
                .padding(.horizontal)

                activitySection
                    .padding(.horizontal)
                    .padding(.bottom, 24)
            }
            .padding(.top, 12)
        }
    }

    // MARK: - Landscape Layout
    private var landscapeLayout: some View {
        HStack(alignment: .top, spacing: 20) {
            // Left Column: Progress & Stats
            ScrollView {
                VStack(spacing: 14) {
                    headerView

                    WaveProgressView(
                        currentMl: todayIntakeMl,
                        goalMl: dailyGoalMl,
                        customDiameter: 175
                    )

                    statsRow
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)

            // Right Column: Quick Add & Today's Timeline
            ScrollView {
                VStack(spacing: 16) {
                    QuickAddCard(
                        onAdd: { amount, type in
                            viewModel.logDrink(
                                amountMl: amount,
                                type: type,
                                dailyGoal: dailyGoalMl,
                                context: modelContext,
                                allLogs: allLogs
                            )
                        },
                        onCustomTap: {
                            showingCustomLogSheet = true
                        }
                    )

                    activitySection
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Subviews
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.greeting())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility3)

                Text("Stay Hydrated")
                    .font(.title2)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(currentStreakDays)d streak")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.12))
            .clipShape(Capsule())
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            statCard(
                title: "Logged",
                value: "\(todayLogs.count)",
                subtitle: "drinks",
                icon: "drop.fill",
                color: .cyan
            )

            statCard(
                title: "Goal",
                value: "\(Int(dailyGoalMl))",
                subtitle: "ml target",
                icon: "target",
                color: .blue
            )

            statCard(
                title: "Effective",
                value: "\(Int(todayEffectiveIntakeMl))",
                subtitle: "ml net",
                icon: "leaf.fill",
                color: .teal
            )
        }
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Today's Activity")
                    .font(.headline)
                Spacer()
                Text("\(todayLogs.count) entries")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if todayLogs.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "cup.and.saucer")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary.opacity(0.6))
                    Text("No drinks logged yet today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Tap any button above to log your first sip!")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(todayLogs.enumerated()), id: \.element.id) { index, log in
                        IntakeHistoryRow(log: log)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)

                        if index < todayLogs.count - 1 {
                            Divider()
                                .padding(.leading, 58)
                        }
                    }
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
            }
        }
    }

    private func statCard(title: String, value: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Spacer()
            }

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .foregroundColor(.primary)

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
    }
}
