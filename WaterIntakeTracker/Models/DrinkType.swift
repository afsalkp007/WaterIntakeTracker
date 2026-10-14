import SwiftUI

public enum DrinkType: String, CaseIterable, Identifiable, Codable {
    case water = "Water"
    case sparkling = "Sparkling Water"
    case tea = "Tea"
    case coffee = "Coffee"
    case electrolyte = "Electrolytes"
    case juice = "Juice"
    case infused = "Infused Water"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .water:
            return "drop.fill"
        case .sparkling:
            return "bubbles.and.sparkles.fill"
        case .tea:
            return "cup.and.saucer.fill"
        case .coffee:
            return "mug.fill"
        case .electrolyte:
            return "bolt.heart.fill"
        case .juice:
            return "waterbottle.fill"
        case .infused:
            return "leaf.fill"
        }
    }

    public var themeColor: Color {
        switch self {
        case .water:
            return Color.cyan
        case .sparkling:
            return Color.teal
        case .tea:
            return Color.green
        case .coffee:
            return Color.brown
        case .electrolyte:
            return Color.orange
        case .juice:
            return Color.pink
        case .infused:
            return Color.mint
        }
    }

    /// Hydration absorption factor relative to pure water
    public var hydrationFactor: Double {
        switch self {
        case .water, .sparkling, .infused:
            return 1.0
        case .electrolyte:
            return 1.05
        case .tea:
            return 0.95
        case .coffee:
            return 0.85
        case .juice:
            return 0.85
        }
    }
}
