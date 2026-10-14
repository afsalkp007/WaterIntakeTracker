import Foundation
import XCTest
import SwiftData
@testable import WaterIntakeTracker

@MainActor
public final class SwiftDataPersistenceTests: XCTestCase {

    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!

    public override func setUp() async throws {
        try await super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: WaterLog.self, configurations: config)
        modelContext = ModelContext(modelContainer)
    }

    public override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        try await super.tearDown()
    }

    public func testInsertAndFetchLogs() throws {
        let log1 = WaterLog(amountMl: 250, drinkType: .water, note: "Morning sip")
        let log2 = WaterLog(amountMl: 500, drinkType: .tea, note: "Green tea")

        modelContext.insert(log1)
        modelContext.insert(log2)
        try modelContext.save()

        let descriptor = FetchDescriptor<WaterLog>(sortBy: [SortDescriptor(\.amountMl, order: .forward)])
        let fetched = try modelContext.fetch(descriptor)

        XCTAssertEqual(fetched.count, 2)
        XCTAssertEqual(fetched[0].amountMl, 250.0)
        XCTAssertEqual(fetched[0].drinkType, .water)
        XCTAssertEqual(fetched[1].amountMl, 500.0)
        XCTAssertEqual(fetched[1].drinkType, .tea)
    }

    public func testFilterUsingPredicate() throws {
        let log1 = WaterLog(amountMl: 200, drinkType: .coffee)
        let log2 = WaterLog(amountMl: 300, drinkType: .water)
        let log3 = WaterLog(amountMl: 400, drinkType: .water)

        modelContext.insert(log1)
        modelContext.insert(log2)
        modelContext.insert(log3)
        try modelContext.save()

        let waterRaw = DrinkType.water.rawValue
        let predicate = #Predicate<WaterLog> { $0.drinkTypeRaw == waterRaw }
        let descriptor = FetchDescriptor<WaterLog>(predicate: predicate)

        let waterOnly = try modelContext.fetch(descriptor)
        XCTAssertEqual(waterOnly.count, 2)
        XCTAssertTrue(waterOnly.allSatisfy { $0.drinkType == .water })
    }

    public func testUpdateLogAttributes() throws {
        let log = WaterLog(amountMl: 250, drinkType: .water, note: "Initial")
        modelContext.insert(log)
        try modelContext.save()

        log.amountMl = 350
        log.drinkType = .electrolyte
        log.note = "Updated post workout"
        try modelContext.save()

        let fetched = try modelContext.fetch(FetchDescriptor<WaterLog>())
        XCTAssertEqual(fetched.count, 1)
        let first = try XCTUnwrap(fetched.first)
        XCTAssertEqual(first.amountMl, 350.0)
        XCTAssertEqual(first.drinkType, .electrolyte)
        XCTAssertEqual(first.note, "Updated post workout")
        XCTAssertEqual(first.effectiveHydrationMl, 350.0 * 1.05, accuracy: 0.001)
    }

    public func testDeleteCascade() throws {
        let log = WaterLog(amountMl: 500, drinkType: .water)
        modelContext.insert(log)
        try modelContext.save()

        modelContext.delete(log)
        try modelContext.save()

        let fetched = try modelContext.fetch(FetchDescriptor<WaterLog>())
        XCTAssertEqual(fetched.count, 0)
    }
}
