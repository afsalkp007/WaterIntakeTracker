import Foundation
import XCTest
@testable import WaterIntakeTracker

public final class WaterLogTests: XCTestCase {

    public func testDefaultInitialization() {
        let log = WaterLog()
        XCTAssertEqual(log.amountMl, 250.0)
        XCTAssertEqual(log.drinkType, .water)
        XCTAssertEqual(log.note, "")
        XCTAssertEqual(log.effectiveHydrationMl, 250.0)
    }

    public func testCustomInitialization() {
        let now = Date()
        let log = WaterLog(
            timestamp: now,
            amountMl: 500,
            drinkType: .coffee,
            note: "Morning brew"
        )

        XCTAssertEqual(log.timestamp, now)
        XCTAssertEqual(log.amountMl, 500.0)
        XCTAssertEqual(log.drinkType, .coffee)
        XCTAssertEqual(log.drinkTypeRaw, "Coffee")
        XCTAssertEqual(log.note, "Morning brew")
        XCTAssertEqual(log.effectiveHydrationMl, 500.0 * 0.85, accuracy: 0.001)
    }

    public func testDrinkTypeSetterUpdatesRawValue() {
        let log = WaterLog(amountMl: 300, drinkType: .water)
        log.drinkType = .tea
        XCTAssertEqual(log.drinkTypeRaw, "Tea")
        XCTAssertEqual(log.effectiveHydrationMl, 300.0 * 0.95, accuracy: 0.001)
    }

    public func testElectrolyteHydrationBonus() {
        let log = WaterLog(amountMl: 400, drinkType: .electrolyte)
        XCTAssertEqual(log.effectiveHydrationMl, 400.0 * 1.05, accuracy: 0.001)
    }
}
