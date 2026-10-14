import Foundation
import SwiftData

@Model
public final class WaterLog {
    public var id: UUID = UUID()
    public var timestamp: Date = Date()
    public var amountMl: Double = 250.0
    public var drinkTypeRaw: String = DrinkType.water.rawValue
    public var note: String = ""

    public var drinkType: DrinkType {
        get {
            DrinkType(rawValue: drinkTypeRaw) ?? .water
        }
        set {
            drinkTypeRaw = newValue.rawValue
        }
    }

    /// Hydration value factoring in beverage type
    public var effectiveHydrationMl: Double {
        return amountMl * drinkType.hydrationFactor
    }

    public init(id: UUID = UUID(), timestamp: Date = Date(), amountMl: Double = 250.0, drinkType: DrinkType = .water, note: String = "") {
        self.id = id
        self.timestamp = timestamp
        self.amountMl = amountMl
        self.drinkTypeRaw = drinkType.rawValue
        self.note = note
    }
}
