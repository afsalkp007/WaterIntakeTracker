import SwiftUI
import XCTest
@testable import WaterIntakeTracker

@MainActor
public final class ComponentSnapshotTests: XCTestCase {

    public func testWaveProgressViewZeroIntakeRenders() {
        let view = WaveProgressView(currentMl: 0, goalMl: 2500)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0

        let image = renderer.uiImage
        XCTAssertNotNil(image, "WaveProgressView (0%) should render to a non-nil image")
        if let image = image {
            XCTAssertGreaterThan(image.size.width, 0)
            XCTAssertGreaterThan(image.size.height, 0)
        }
    }

    public func testWaveProgressViewFiftyPercentRenders() {
        let view = WaveProgressView(currentMl: 1250, goalMl: 2500)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0

        let image = renderer.uiImage
        XCTAssertNotNil(image, "WaveProgressView (50%) should render to a non-nil image")
        if let image = image {
            XCTAssertEqual(image.scale, 2.0)
            XCTAssertGreaterThan(image.size.width, 0)
        }
    }

    public func testWaveProgressViewGoalAchievedRenders() {
        let view = WaveProgressView(currentMl: 2600, goalMl: 2500)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0

        let image = renderer.uiImage
        XCTAssertNotNil(image, "WaveProgressView (100%+) should render to a non-nil image")
    }

    public func testQuickAddCardRenders() {
        let card = QuickAddCard(onAdd: { _, _ in }, onCustomTap: {})
            .frame(width: 350)

        let renderer = ImageRenderer(content: card)
        renderer.scale = 2.0

        let image = renderer.uiImage
        XCTAssertNotNil(image, "QuickAddCard should render cleanly")
    }

    public func testIntakeHistoryRowRenders() {
        let log = WaterLog(amountMl: 250, drinkType: .water, note: "Refreshing glass")
        let row = IntakeHistoryRow(log: log)
            .frame(width: 350)

        let renderer = ImageRenderer(content: row)
        renderer.scale = 2.0

        let image = renderer.uiImage
        XCTAssertNotNil(image, "IntakeHistoryRow should render successfully")
    }

    public func testCoffeeHistoryRowRendersWithDiscountNote() {
        let log = WaterLog(amountMl: 350, drinkType: .coffee, note: "Latte")
        let row = IntakeHistoryRow(log: log)
            .frame(width: 350)

        let renderer = ImageRenderer(content: row)
        renderer.scale = 2.0

        let image = renderer.uiImage
        XCTAssertNotNil(image, "Coffee IntakeHistoryRow with net note should render successfully")
    }
}
