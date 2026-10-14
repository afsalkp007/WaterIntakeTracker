import Foundation
import XCTest
import SwiftData
@testable import WaterIntakeTracker

@MainActor
public final class HydrationTrackingFlowIntegrationTests: XCTestCase {

    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!
    private var calendar: Calendar!
    private var calculator: HydrationCalculator!
    private var dashboardVM: DashboardViewModel!
    private var historyVM: HistoryViewModel!

    public override func setUp() async throws {
        try await super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: WaterLog.self, configurations: config)
        modelContext = ModelContext(modelContainer)

        calculator = HydrationCalculator(calendar: calendar)
        dashboardVM = DashboardViewModel(calculator: calculator)
        historyVM = HistoryViewModel(calculator: calculator)
    }

    public override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        calculator = nil
        dashboardVM = nil
        historyVM = nil
        try await super.tearDown()
    }

    public func testFullDayHydrationWorkflow() throws {
        let dailyGoal: Double = 2000.0
        let today = calendar.startOfDay(for: Date())

        // 1. Initial State: Empty logs
        var allLogs = try modelContext.fetch(FetchDescriptor<WaterLog>())
        XCTAssertEqual(dashboardVM.todayIntake(from: allLogs), 0)
        XCTAssertEqual(dashboardVM.streakDays(from: allLogs, goal: dailyGoal), 0)

        // 2. Morning glass (250 ml water)
        dashboardVM.logDrink(
            amountMl: 250,
            type: .water,
            timestamp: today.addingTimeInterval(8 * 3600),
            note: "Morning wake-up glass",
            dailyGoal: dailyGoal,
            context: modelContext,
            allLogs: allLogs
        )
        try modelContext.save()

        allLogs = try modelContext.fetch(FetchDescriptor<WaterLog>())
        XCTAssertEqual(dashboardVM.todayIntake(from: allLogs), 250.0)
        XCTAssertEqual(dashboardVM.todayEffectiveIntake(from: allLogs), 250.0)
        XCTAssertEqual(dashboardVM.streakDays(from: allLogs, goal: dailyGoal), 0)

        // 3. Mid-day coffee (300 ml coffee -> 300 * 0.85 = 255 ml net)
        dashboardVM.logDrink(
            amountMl: 300,
            type: .coffee,
            timestamp: today.addingTimeInterval(11 * 3600),
            note: "Espresso americano",
            dailyGoal: dailyGoal,
            context: modelContext,
            allLogs: allLogs
        )
        try modelContext.save()

        allLogs = try modelContext.fetch(FetchDescriptor<WaterLog>())
        XCTAssertEqual(dashboardVM.todayIntake(from: allLogs), 550.0)
        XCTAssertEqual(dashboardVM.todayEffectiveIntake(from: allLogs), 250.0 + 255.0, accuracy: 0.001)

        // 4. Afternoon workout bottle (500 ml electrolyte -> 500 * 1.05 = 525 ml net)
        dashboardVM.logDrink(
            amountMl: 500,
            type: .electrolyte,
            timestamp: today.addingTimeInterval(15 * 3600),
            note: "Electrolyte mix",
            dailyGoal: dailyGoal,
            context: modelContext,
            allLogs: allLogs
        )
        try modelContext.save()

        allLogs = try modelContext.fetch(FetchDescriptor<WaterLog>())
        XCTAssertEqual(dashboardVM.todayIntake(from: allLogs), 1050.0)
        XCTAssertEqual(dashboardVM.todayEffectiveIntake(from: allLogs), 250.0 + 255.0 + 525.0, accuracy: 0.001)

        // 5. Evening bottle (1000 ml water) -> Crosses 2000 ml threshold!
        dashboardVM.logDrink(
            amountMl: 1000,
            type: .water,
            timestamp: today.addingTimeInterval(19 * 3600),
            note: "Big dinner water bottle",
            dailyGoal: dailyGoal,
            context: modelContext,
            allLogs: allLogs
        )
        try modelContext.save()

        allLogs = try modelContext.fetch(FetchDescriptor<WaterLog>())
        XCTAssertEqual(dashboardVM.todayIntake(from: allLogs), 2050.0)
        // Goal met! Streak should now be 1
        XCTAssertEqual(dashboardVM.streakDays(from: allLogs, goal: dailyGoal), 1)

        // 6. Verify weekly summaries
        let summaries = historyVM.weeklySummaries(from: allLogs, goal: dailyGoal)
        XCTAssertEqual(summaries.count, 7)
        let todaySummary = summaries.last!
        XCTAssertEqual(todaySummary.totalMl, 2050.0)
        XCTAssertTrue(todaySummary.isGoalMet)
        XCTAssertEqual(todaySummary.drinkCount, 4)

        // 7. Test log deletion (e.g. coffee was logged by mistake)
        if let coffeeLog = allLogs.first(where: { $0.drinkType == .coffee }) {
            historyVM.deleteLog(coffeeLog, from: modelContext)
            try modelContext.save()
        }

        allLogs = try modelContext.fetch(FetchDescriptor<WaterLog>())
        XCTAssertEqual(allLogs.count, 3)
        XCTAssertEqual(dashboardVM.todayIntake(from: allLogs), 1750.0)
        // Since intake dropped below 2000 ml, today is no longer met
        XCTAssertEqual(dashboardVM.streakDays(from: allLogs, goal: dailyGoal), 0)
    }
}
