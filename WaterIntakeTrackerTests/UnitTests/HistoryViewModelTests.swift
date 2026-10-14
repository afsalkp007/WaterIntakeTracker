import Foundation
import XCTest
import SwiftData
@testable import WaterIntakeTracker

@MainActor
public final class HistoryViewModelTests: XCTestCase {

    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!
    private var calendar: Calendar!
    private var viewModel: HistoryViewModel!

    public override func setUp() async throws {
        try await super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: WaterLog.self, configurations: config)
        modelContext = ModelContext(modelContainer)

        let calculator = HydrationCalculator(calendar: calendar)
        viewModel = HistoryViewModel(calculator: calculator)
    }

    public override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        viewModel = nil
        try await super.tearDown()
    }

    public func testWeeklySummariesReturnsSevenDays() {
        let logs: [WaterLog] = []
        let summaries = viewModel.weeklySummaries(from: logs, goal: 2000)
        XCTAssertEqual(summaries.count, 7)
    }

    public func testWeeklyAverageCalculation() {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let logs = [
            WaterLog(timestamp: today.addingTimeInterval(100), amountMl: 2100),
            WaterLog(timestamp: yesterday.addingTimeInterval(100), amountMl: 1400)
        ]

        // 2100 + 1400 = 3500 across 7 days -> 500 / day
        let avg = viewModel.weeklyAverage(from: logs, goal: 2000)
        XCTAssertEqual(avg, 500.0, accuracy: 0.001)
    }

    public func testDaysGoalMetCount() {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let logs = [
            WaterLog(timestamp: today.addingTimeInterval(100), amountMl: 2500), // goal met (goal = 2000)
            WaterLog(timestamp: yesterday.addingTimeInterval(100), amountMl: 1500) // goal not met
        ]

        let metCount = viewModel.daysGoalMetCount(from: logs, goal: 2000)
        XCTAssertEqual(metCount, 1)
    }

    public func testDeleteLogRemovesFromContext() throws {
        let log = WaterLog(amountMl: 500, drinkType: .water)
        modelContext.insert(log)
        try modelContext.save()

        var fetched = try modelContext.fetch(FetchDescriptor<WaterLog>())
        XCTAssertEqual(fetched.count, 1)

        viewModel.deleteLog(log, from: modelContext)
        try modelContext.save()

        fetched = try modelContext.fetch(FetchDescriptor<WaterLog>())
        XCTAssertEqual(fetched.count, 0)
    }
}
