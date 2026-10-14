import Foundation
import XCTest
@testable import WaterIntakeTracker

public final class HydrationCalculatorTests: XCTestCase {

    private var calendar: Calendar!
    private var calculator: HydrationCalculator!

    public override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calculator = HydrationCalculator(calendar: calendar)
    }

    public func testTotalIntakeForDate() {
        let referenceDate = Date(timeIntervalSince1970: 1700000000) // Fixed point in time
        let startOfDay = calendar.startOfDay(for: referenceDate)

        let logs = [
            WaterLog(timestamp: startOfDay.addingTimeInterval(3600), amountMl: 250, drinkType: .water),
            WaterLog(timestamp: startOfDay.addingTimeInterval(7200), amountMl: 500, drinkType: .water),
            // Next day entry (should not be included)
            WaterLog(timestamp: startOfDay.addingTimeInterval(90000), amountMl: 300, drinkType: .water)
        ]

        let total = calculator.totalIntake(for: referenceDate, logs: logs)
        XCTAssertEqual(total, 750.0)
    }

    public func testEffectiveIntakeForDate() {
        let referenceDate = Date(timeIntervalSince1970: 1700000000)
        let startOfDay = calendar.startOfDay(for: referenceDate)

        let logs = [
            WaterLog(timestamp: startOfDay.addingTimeInterval(3600), amountMl: 200, drinkType: .coffee), // 200 * 0.85 = 170
            WaterLog(timestamp: startOfDay.addingTimeInterval(7200), amountMl: 500, drinkType: .water),  // 500 * 1.0 = 500
            WaterLog(timestamp: startOfDay.addingTimeInterval(10800), amountMl: 200, drinkType: .electrolyte) // 200 * 1.05 = 210
        ]

        let effective = calculator.effectiveIntake(for: referenceDate, logs: logs)
        XCTAssertEqual(effective, 170.0 + 500.0 + 210.0, accuracy: 0.001)
    }

    public func testStreakCalculation() {
        let referenceDate = Date(timeIntervalSince1970: 1700000000)
        let today = calendar.startOfDay(for: referenceDate)
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
              let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today),
              let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today) else {
            XCTFail("Calendar calculation failed")
            return
        }

        let goal: Double = 2000.0

        // Case 1: Today meets goal, yesterday meets goal, 2 days ago meets goal, 3 days ago didn't
        let logsConsecutive = [
            WaterLog(timestamp: today.addingTimeInterval(3600), amountMl: 2000),
            WaterLog(timestamp: yesterday.addingTimeInterval(3600), amountMl: 2500),
            WaterLog(timestamp: twoDaysAgo.addingTimeInterval(3600), amountMl: 2100),
            WaterLog(timestamp: threeDaysAgo.addingTimeInterval(3600), amountMl: 500)
        ]

        let streak3 = calculator.calculateStreak(referenceDate: referenceDate, logs: logsConsecutive, dailyGoalMl: goal)
        XCTAssertEqual(streak3, 3)

        // Case 2: Today not met yet, but yesterday met
        let logsTodayNotMet = [
            WaterLog(timestamp: today.addingTimeInterval(3600), amountMl: 500),
            WaterLog(timestamp: yesterday.addingTimeInterval(3600), amountMl: 2500)
        ]
        let streakFromYesterday = calculator.calculateStreak(referenceDate: referenceDate, logs: logsTodayNotMet, dailyGoalMl: goal)
        XCTAssertEqual(streakFromYesterday, 1)

        // Case 3: Empty logs
        let streakEmpty = calculator.calculateStreak(referenceDate: referenceDate, logs: [], dailyGoalMl: goal)
        XCTAssertEqual(streakEmpty, 0)
    }

    public func testDailySummariesCountAndAccuracy() {
        let referenceDate = Date(timeIntervalSince1970: 1700000000)
        let today = calendar.startOfDay(for: referenceDate)

        let logs = [
            WaterLog(timestamp: today.addingTimeInterval(1000), amountMl: 2500)
        ]

        let summaries = calculator.dailySummaries(daysCount: 7, endingAt: referenceDate, logs: logs, dailyGoalMl: 2000)
        XCTAssertEqual(summaries.count, 7)

        let todaySummary = summaries.last!
        XCTAssertEqual(todaySummary.totalMl, 2500.0)
        XCTAssertTrue(todaySummary.isGoalMet)
        XCTAssertEqual(todaySummary.drinkCount, 1)
        XCTAssertEqual(todaySummary.progressRatio, 1.25, accuracy: 0.001)
    }

    public func testUnitConversions() {
        let ml: Double = 1000.0
        let oz = HydrationCalculator.mlToFlOz(ml)
        XCTAssertEqual(oz, 33.814, accuracy: 0.01)

        let backToMl = HydrationCalculator.flOzToMl(oz)
        XCTAssertEqual(backToMl, 1000.0, accuracy: 0.1)
    }
}
