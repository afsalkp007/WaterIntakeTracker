import SwiftUI

public struct QuickPreset: Identifiable {
    public let id = UUID()
    public let title: String
    public let amountMl: Double
    public let iconName: String
}

public struct QuickAddCard: View {
    public let onAdd: (Double, DrinkType) -> Void
    public let onCustomTap: () -> Void

    public let presets: [QuickPreset] = [
        QuickPreset(title: "Small Cup", amountMl: 150, iconName: "cup.and.saucer.fill"),
        QuickPreset(title: "Glass", amountMl: 250, iconName: "waterbottle"),
        QuickPreset(title: "Mug", amountMl: 350, iconName: "mug.fill"),
        QuickPreset(title: "Bottle", amountMl: 500, iconName: "waterbottle.fill")
    ]

    public init(onAdd: @escaping (Double, DrinkType) -> Void, onCustomTap: @escaping () -> Void) {
        self.onAdd = onAdd
        self.onCustomTap = onCustomTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Quick Log", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: onCustomTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Custom")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.cyan)
                }
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(presets) { preset in
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onAdd(preset.amountMl, .water)
                    }) {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.cyan.opacity(0.16))
                                    .frame(width: 42, height: 42)

                                Image(systemName: preset.iconName)
                                    .foregroundColor(.cyan)
                                    .font(.system(size: 18))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(preset.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(1)

                                Text("+\(Int(preset.amountMl)) ml")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(1)
                            }

                            Spacer(minLength: 0)
                        }
                        .padding(10)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .cornerRadius(14)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

public struct ScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
