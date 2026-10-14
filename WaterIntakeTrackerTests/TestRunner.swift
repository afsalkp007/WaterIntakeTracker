import Foundation
import SwiftUI
import SwiftData
import XCTest
@testable import WaterIntakeTracker

@MainActor
public final class FullPipelineIntegrationTests: XCTestCase {

    public func testDrinkTypeModel() {
        XCTAssertEqual(DrinkType.allCases.count, 7)
        XCTAssertEqual(DrinkType.water.hydrationFactor, 1.0)
        XCTAssertEqual(DrinkType.electrolyte.hydrationFactor, 1.05)
        XCTAssertEqual(DrinkType.coffee.hydrationFactor, 0.85)
        XCTAssertEqual(DrinkType.tea.hydrationFactor, 0.95)
        XCTAssertFalse(DrinkType.water.iconName.isEmpty)
    }

    public func testWaterLogModel() {
        let log = WaterLog(amountMl: 500, drinkType: .coffee, note: "Latte")
        XCTAssertEqual(log.amountMl, 500.0)
        XCTAssertEqual(log.drinkType, .coffee)
        XCTAssertEqual(log.effectiveHydrationMl, 425.0)

        let electrolyteLog = WaterLog(amountMl: 400, drinkType: .electrolyte)
        XCTAssertEqual(electrolyteLog.effectiveHydrationMl, 420.0)
    }

    public func testHydrationCalculatorEngine() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let calculator = HydrationCalculator(calendar: calendar)

        let refDate = Date(timeIntervalSince1970: 1700000000)
        let dayStart = calendar.startOfDay(for: refDate)
        let sampleLogs = [
            WaterLog(timestamp: dayStart.addingTimeInterval(3600), amountMl: 250, drinkType: .water),
            WaterLog(timestamp: dayStart.addingTimeInterval(7200), amountMl: 500, drinkType: .water)
        ]

        let total = calculator.totalIntake(for: refDate, logs: sampleLogs)
        XCTAssertEqual(total, 750.0)

        let streak1 = calculator.calculateStreak(referenceDate: refDate, logs: sampleLogs, dailyGoalMl: 500)
        XCTAssertEqual(streak1, 1)

        let streak0 = calculator.calculateStreak(referenceDate: refDate, logs: sampleLogs, dailyGoalMl: 2000)
        XCTAssertEqual(streak0, 0)

        let summaries = calculator.dailySummaries(daysCount: 7, endingAt: refDate, logs: sampleLogs, dailyGoalMl: 500)
        XCTAssertEqual(summaries.count, 7)
        XCTAssertEqual(summaries.last?.totalMl, 750.0)
        XCTAssertEqual(summaries.last?.isGoalMet, true)

        let mlVal: Double = 1000.0
        let ozVal = HydrationCalculator.mlToFlOz(mlVal)
        let convertedBack = HydrationCalculator.flOzToMl(ozVal)
        XCTAssertEqual(Int(round(convertedBack)), 1000)
    }

    public func testViewModelsAndNotifications() async {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let calculator = HydrationCalculator(calendar: calendar)

        let dashboardVM = DashboardViewModel(calculator: calculator)
        let greeting = dashboardVM.greeting()
        XCTAssertFalse(greeting.isEmpty)

        let sampleLogs = [WaterLog(amountMl: 750, drinkType: .water)]
        let historyVM = HistoryViewModel(calculator: calculator)
        let avg = historyVM.weeklyAverage(from: sampleLogs, goal: 500)
        XCTAssertEqual(avg, 750.0 / 7.0, accuracy: 0.001)

        let mockNotification = MockNotificationService(isAuthorized: true)
        let auth = await mockNotification.requestAuthorization()
        XCTAssertTrue(auth)

        await mockNotification.scheduleReminders(intervalMinutes: 60, startHour: 8, endHour: 20)
        XCTAssertEqual(mockNotification.pendingCount, 12)

        await mockNotification.cancelAllReminders()
        XCTAssertEqual(mockNotification.pendingCount, 0)
    }

    public func testSwiftDataIntegrationFlow() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: WaterLog.self, configurations: config)
        let context = ModelContext(container)

        let calendar = Calendar(identifier: .gregorian)
        let calculator = HydrationCalculator(calendar: calendar)
        let refDate = Date()
        let dayStart = calendar.startOfDay(for: refDate)

        let morningLog = WaterLog(timestamp: dayStart.addingTimeInterval(28800), amountMl: 250, drinkType: .water)
        let afternoonLog = WaterLog(timestamp: dayStart.addingTimeInterval(50400), amountMl: 500, drinkType: .electrolyte)
        let eveningLog = WaterLog(timestamp: dayStart.addingTimeInterval(68400), amountMl: 1300, drinkType: .water)

        context.insert(morningLog)
        context.insert(afternoonLog)
        context.insert(eveningLog)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WaterLog>())
        XCTAssertEqual(fetched.count, 3)

        let dayTotal = calculator.totalIntake(for: refDate, logs: fetched)
        XCTAssertEqual(dayTotal, 2050.0)

        let dayStreak = calculator.calculateStreak(referenceDate: refDate, logs: fetched, dailyGoalMl: 2000.0)
        XCTAssertEqual(dayStreak, 1)

        context.delete(morningLog)
        try context.save()
        let remaining = try context.fetch(FetchDescriptor<WaterLog>())
        XCTAssertEqual(remaining.count, 2)
    }

    public func testComponentSnapshots() {
        let waveViewZero = WaveProgressView(currentMl: 0, goalMl: 2500)
        let waveRendererZero = ImageRenderer(content: waveViewZero)
        waveRendererZero.scale = 2.0
        XCTAssertNotNil(waveRendererZero.uiImage)

        let waveViewFull = WaveProgressView(currentMl: 2500, goalMl: 2500)
        let waveRendererFull = ImageRenderer(content: waveViewFull)
        waveRendererFull.scale = 2.0
        XCTAssertNotNil(waveRendererFull.uiImage)

        let quickCard = QuickAddCard(onAdd: { _, _ in }, onCustomTap: {}).frame(width: 350)
        let quickRenderer = ImageRenderer(content: quickCard)
        XCTAssertNotNil(quickRenderer.uiImage)

        let historyRow = IntakeHistoryRow(log: WaterLog(amountMl: 250, drinkType: .water)).frame(width: 350)
        let rowRenderer = ImageRenderer(content: historyRow)
        XCTAssertNotNil(rowRenderer.uiImage)
    }
}
