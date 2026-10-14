import Foundation

public struct DailyHydrationSummary: Identifiable, Equatable {
    public var id: Date { date }
    public let date: Date
    public let totalMl: Double
    public let goalMl: Double
    public let drinkCount: Int

    public var isGoalMet: Bool {
        totalMl >= goalMl
    }

    public var progressRatio: Double {
        guard goalMl > 0 else { return 0 }
        return totalMl / goalMl
    }

    public init(date: Date, totalMl: Double, goalMl: Double, drinkCount: Int) {
        self.date = date
        self.totalMl = totalMl
        self.goalMl = goalMl
        self.drinkCount = drinkCount
    }
}

public struct HydrationCalculator {
    public let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// Calculate total logged water volume in ml for a given date
    public func totalIntake(for targetDate: Date, logs: [WaterLog]) -> Double {
        let startOfDay = calendar.startOfDay(for: targetDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return 0 }

        return logs
            .filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
            .reduce(0.0) { $0 + $1.amountMl }
    }

    /// Calculate effective net hydration factoring in beverage hydration factors
    public func effectiveIntake(for targetDate: Date, logs: [WaterLog]) -> Double {
        let startOfDay = calendar.startOfDay(for: targetDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return 0 }

        return logs
            .filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
            .reduce(0.0) { $0 + $1.effectiveHydrationMl }
    }

    /// Calculate consecutive days streak where the daily goal was met
    public func calculateStreak(referenceDate: Date = Date(), logs: [WaterLog], dailyGoalMl: Double) -> Int {
        guard dailyGoalMl > 0 else { return 0 }

        var streak = 0
        var currentDay = calendar.startOfDay(for: referenceDate)

        // Check reference day (e.g. today)
        let todayTotal = totalIntake(for: currentDay, logs: logs)
        if todayTotal >= dailyGoalMl {
            streak += 1
        }

        // Check previous consecutive days
        while let prevDay = calendar.date(byAdding: .day, value: -1, to: currentDay) {
            let dayTotal = totalIntake(for: prevDay, logs: logs)
            if dayTotal >= dailyGoalMl {
                streak += 1
                currentDay = prevDay
            } else {
                break
            }
        }

        return streak
    }

    /// Generate daily breakdown for the last N days
    public func dailySummaries(daysCount: Int = 7, endingAt endDate: Date = Date(), logs: [WaterLog], dailyGoalMl: Double) -> [DailyHydrationSummary] {
        let normalizedEnd = calendar.startOfDay(for: endDate)
        var summaries: [DailyHydrationSummary] = []

        for offset in (0..<daysCount).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: normalizedEnd) else { continue }
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else { continue }

            let dayLogs = logs.filter { $0.timestamp >= day && $0.timestamp < nextDay }
            let sum = dayLogs.reduce(0.0) { $0 + $1.amountMl }

            summaries.append(DailyHydrationSummary(
                date: day,
                totalMl: sum,
                goalMl: dailyGoalMl,
                drinkCount: dayLogs.count
            ))
        }

        return summaries
    }

    /// Convert ml to fl oz (US fluid ounces)
    public static func mlToFlOz(_ ml: Double) -> Double {
        return ml * 0.033814
    }

    /// Convert fl oz to ml
    public static func flOzToMl(_ flOz: Double) -> Double {
        return flOz / 0.033814
    }
}
