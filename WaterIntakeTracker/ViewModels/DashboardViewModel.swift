import SwiftUI
import SwiftData
import Combine

@MainActor
public final class DashboardViewModel: ObservableObject {
    private let calculator: HydrationCalculator

    public init(calculator: HydrationCalculator = HydrationCalculator()) {
        self.calculator = calculator
    }

    public func todayLogs(from allLogs: [WaterLog]) -> [WaterLog] {
        let calendar = calculator.calendar
        let todayStart = calendar.startOfDay(for: Date())
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: todayStart) else { return [] }
        return allLogs.filter { $0.timestamp >= todayStart && $0.timestamp < tomorrow }
    }

    public func todayIntake(from allLogs: [WaterLog]) -> Double {
        return calculator.totalIntake(for: Date(), logs: allLogs)
    }

    public func todayEffectiveIntake(from allLogs: [WaterLog]) -> Double {
        return calculator.effectiveIntake(for: Date(), logs: allLogs)
    }

    public func streakDays(from allLogs: [WaterLog], goal: Double) -> Int {
        return calculator.calculateStreak(referenceDate: Date(), logs: allLogs, dailyGoalMl: goal)
    }

    public func greeting() -> String {
        let hour = calculator.calendar.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning ☀️"
        case 12..<17:
            return "Good Afternoon 🌤️"
        default:
            return "Good Evening 🌙"
        }
    }

    public func logDrink(
        amountMl: Double,
        type: DrinkType,
        timestamp: Date = Date(),
        note: String = "",
        dailyGoal: Double,
        context: ModelContext,
        allLogs: [WaterLog]
    ) {
        let previousTotal = todayIntake(from: allLogs)
        let log = WaterLog(
            timestamp: timestamp,
            amountMl: amountMl,
            drinkType: type,
            note: note
        )
        context.insert(log)

        // Haptic feedback if goal was just reached
        if previousTotal < dailyGoal && (previousTotal + amountMl) >= dailyGoal {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}
