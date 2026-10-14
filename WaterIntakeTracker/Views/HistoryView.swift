import SwiftUI
import SwiftData
import Charts

public struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Query(sort: \WaterLog.timestamp, order: .reverse) private var allLogs: [WaterLog]
    @AppStorage("dailyGoalMl") private var dailyGoalMl: Double = 2500.0

    @StateObject private var viewModel = HistoryViewModel()

    public init() {}

    private var weeklySummaries: [DailyHydrationSummary] {
        viewModel.weeklySummaries(from: allLogs, goal: dailyGoalMl)
    }

    private var weeklyAverageMl: Double {
        viewModel.weeklyAverage(from: allLogs, goal: dailyGoalMl)
    }

    private var daysGoalMetCount: Int {
        viewModel.daysGoalMetCount(from: allLogs, goal: dailyGoalMl)
    }

    private var chartHeight: CGFloat {
        verticalSizeClass == .compact ? 150 : 190
    }

    public var body: some View {
        NavigationStack {
            List {
                // Section 1: Weekly Overview Chart
                Section {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Weekly Average")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(Int(weeklyAverageMl)) ml / day")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(1)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Goal Met")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(daysGoalMetCount) of 7 days")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(daysGoalMetCount >= 5 ? .green : .cyan)
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(1)
                            }
                        }

                        // Bar Chart
                        Chart {
                            ForEach(weeklySummaries) { item in
                                BarMark(
                                    x: .value("Day", item.date, unit: .day),
                                    y: .value("Intake", item.totalMl)
                                )
                                .foregroundStyle(
                                    item.isGoalMet
                                        ? LinearGradient(colors: [.teal, .green], startPoint: .top, endPoint: .bottom)
                                        : LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom)
                                )
                                .cornerRadius(6)

                                RuleMark(y: .value("Goal", dailyGoalMl))
                                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                    .foregroundStyle(Color.orange.opacity(0.8))
                                    .annotation(position: .top, alignment: .trailing) {
                                        Text("Goal")
                                            .font(.caption2)
                                            .foregroundColor(.orange)
                                    }
                            }
                        }
                        .frame(height: chartHeight)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { _ in
                                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Last 7 Days")
                }

                // Section 2: All Past Log Entries
                Section {
                    if allLogs.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "drop")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("No drink records yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 20)
                            Spacer()
                        }
                    } else {
                        ForEach(allLogs) { log in
                            IntakeHistoryRow(log: log)
                        }
                        .onDelete(perform: deleteLogs)
                    }
                } header: {
                    HStack {
                        Text("All Logged Drinks (\(allLogs.count))")
                        Spacer()
                        if !allLogs.isEmpty {
                            Text("Swipe to delete")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("History & Stats")
        }
    }

    private func deleteLogs(at offsets: IndexSet) {
        for index in offsets {
            let log = allLogs[index]
            viewModel.deleteLog(log, from: modelContext)
        }
    }
}
