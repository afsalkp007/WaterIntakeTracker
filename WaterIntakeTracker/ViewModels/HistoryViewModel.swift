import SwiftUI
import SwiftData
import Combine

@MainActor
public final class HistoryViewModel: ObservableObject {
    private let calculator: HydrationCalculator

    public init(calculator: HydrationCalculator = HydrationCalculator()) {
        self.calculator = calculator
    }

    public func weeklySummaries(from allLogs: [WaterLog], goal: Double) -> [DailyHydrationSummary] {
        return calculator.dailySummaries(daysCount: 7, endingAt: Date(), logs: allLogs, dailyGoalMl: goal)
    }

    public func weeklyAverage(from allLogs: [WaterLog], goal: Double) -> Double {
        let summaries = weeklySummaries(from: allLogs, goal: goal)
        guard !summaries.isEmpty else { return 0 }
        let total = summaries.reduce(0.0) { $0 + $1.totalMl }
        return total / Double(summaries.count)
    }

    public func daysGoalMetCount(from allLogs: [WaterLog], goal: Double) -> Int {
        let summaries = weeklySummaries(from: allLogs, goal: goal)
        return summaries.filter { $0.isGoalMet }.count
    }

    public func deleteLog(_ log: WaterLog, from context: ModelContext) {
        context.delete(log)
    }
}
