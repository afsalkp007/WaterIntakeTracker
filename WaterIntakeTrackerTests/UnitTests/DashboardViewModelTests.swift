import Foundation
import XCTest
import SwiftData
@testable import WaterIntakeTracker

@MainActor
public final class DashboardViewModelTests: XCTestCase {

    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!
    private var calendar: Calendar!
    private var viewModel: DashboardViewModel!

    public override func setUp() async throws {
        try await super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: WaterLog.self, configurations: config)
        modelContext = ModelContext(modelContainer)

        let calculator = HydrationCalculator(calendar: calendar)
        viewModel = DashboardViewModel(calculator: calculator)
    }

    public override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        viewModel = nil
        try await super.tearDown()
    }

    public func testGreetingReturnsNonEmpty() {
        let greeting = viewModel.greeting()
        XCTAssertFalse(greeting.isEmpty)
        XCTAssertTrue(greeting.contains("Good"))
    }

    public func testTodayLogsFiltersOlderLogs() {
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: todayStart)!

        let log1 = WaterLog(timestamp: todayStart.addingTimeInterval(100), amountMl: 250)
        let log2 = WaterLog(timestamp: todayStart.addingTimeInterval(500), amountMl: 500)
        let oldLog = WaterLog(timestamp: yesterday.addingTimeInterval(100), amountMl: 300)

        let allLogs = [log1, log2, oldLog]
        let filtered = viewModel.todayLogs(from: allLogs)

        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.contains(where: { $0.id == log1.id }))
        XCTAssertTrue(filtered.contains(where: { $0.id == log2.id }))
        XCTAssertFalse(filtered.contains(where: { $0.id == oldLog.id }))
    }

    public func testLogDrinkInsertsRecordIntoContext() throws {
        let allLogs: [WaterLog] = []
        let goal: Double = 2000.0

        viewModel.logDrink(
            amountMl: 350,
            type: .sparkling,
            timestamp: Date(),
            note: "Refreshing sparkling glass",
            dailyGoal: goal,
            context: modelContext,
            allLogs: allLogs
        )

        let descriptor = FetchDescriptor<WaterLog>()
        let savedLogs = try modelContext.fetch(descriptor)

        XCTAssertEqual(savedLogs.count, 1)
        XCTAssertEqual(savedLogs.first?.amountMl, 350.0)
        XCTAssertEqual(savedLogs.first?.drinkType, .sparkling)
        XCTAssertEqual(savedLogs.first?.note, "Refreshing sparkling glass")
    }

    public func testStreakCalculationDelegation() {
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: todayStart)!

        let logs = [
            WaterLog(timestamp: todayStart.addingTimeInterval(3600), amountMl: 2500),
            WaterLog(timestamp: yesterday.addingTimeInterval(3600), amountMl: 2200)
        ]

        let streak = viewModel.streakDays(from: logs, goal: 2000)
        XCTAssertEqual(streak, 2)
    }
}
