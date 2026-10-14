import Foundation
import XCTest
@testable import WaterIntakeTracker

public final class DrinkTypeTests: XCTestCase {

    public func testAllCasesContainExpectedBeverages() {
        let cases = DrinkType.allCases
        XCTAssertEqual(cases.count, 7)
        XCTAssertTrue(cases.contains(.water))
        XCTAssertTrue(cases.contains(.sparkling))
        XCTAssertTrue(cases.contains(.tea))
        XCTAssertTrue(cases.contains(.coffee))
        XCTAssertTrue(cases.contains(.electrolyte))
        XCTAssertTrue(cases.contains(.juice))
        XCTAssertTrue(cases.contains(.infused))
    }

    public func testHydrationFactors() {
        XCTAssertEqual(DrinkType.water.hydrationFactor, 1.0, accuracy: 0.001)
        XCTAssertEqual(DrinkType.sparkling.hydrationFactor, 1.0, accuracy: 0.001)
        XCTAssertEqual(DrinkType.infused.hydrationFactor, 1.0, accuracy: 0.001)
        XCTAssertEqual(DrinkType.electrolyte.hydrationFactor, 1.05, accuracy: 0.001)
        XCTAssertEqual(DrinkType.tea.hydrationFactor, 0.95, accuracy: 0.001)
        XCTAssertEqual(DrinkType.coffee.hydrationFactor, 0.85, accuracy: 0.001)
        XCTAssertEqual(DrinkType.juice.hydrationFactor, 0.85, accuracy: 0.001)
    }

    public func testIconNamesAreNotEmpty() {
        for type in DrinkType.allCases {
            XCTAssertFalse(type.iconName.isEmpty, "Icon for \(type.rawValue) must not be empty")
        }
    }
}
