import SwiftUI

public struct WaveShape: Shape {
    public var progress: Double
    public var waveOffset: Angle

    public var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(progress, waveOffset.degrees) }
        set {
            progress = newValue.first
            waveOffset = Angle(degrees: newValue.second)
        }
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        let clampedProgress = max(0, min(1.0, progress))
        let waterHeight = height * (1.0 - clampedProgress)
        let waveHeight: CGFloat = 8.0

        path.move(to: CGPoint(x: 0, y: waterHeight))

        for x in stride(from: 0, through: width, by: 4) {
            let relativeX = x / width
            let sine = sin(relativeX * 2 * .pi + CGFloat(waveOffset.radians))
            let y = waterHeight + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }
}

public struct WaveProgressView: View {
    public let currentMl: Double
    public let goalMl: Double
    public var unitString: String = "ml"
    public var customDiameter: CGFloat? = nil

    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .largeTitle) private var percentageFontSize: CGFloat = 44
    @ScaledMetric(relativeTo: .body) private var defaultDiameter: CGFloat = 230

    private var progress: Double {
        guard goalMl > 0 else { return 0 }
        return min(currentMl / goalMl, 1.25) // Allow visual overshoot up to 125%
    }

    private var percentage: Int {
        guard goalMl > 0 else { return 0 }
        return Int(round((currentMl / goalMl) * 100))
    }

    private var effectiveDiameter: CGFloat {
        customDiameter ?? defaultDiameter
    }

    public init(currentMl: Double, goalMl: Double, unitString: String = "ml", customDiameter: CGFloat? = nil) {
        self.currentMl = currentMl
        self.goalMl = goalMl
        self.unitString = unitString
        self.customDiameter = customDiameter
    }

    public var body: some View {
        ZStack {
            // Background Container (Light / Dark mode adaptive)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            colorScheme == .dark ? Color.blue.opacity(0.18) : Color.blue.opacity(0.08),
                            colorScheme == .dark ? Color.cyan.opacity(0.22) : Color.cyan.opacity(0.12)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Animated Waves
            TimelineView(.animation) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let angle = (time * 120).truncatingRemainder(dividingBy: 360)

                ZStack {
                    // Back deeper wave
                    WaveShape(progress: progress, waveOffset: Angle(degrees: angle + 60))
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.cyan.opacity(colorScheme == .dark ? 0.45 : 0.4),
                                    Color.blue.opacity(colorScheme == .dark ? 0.6 : 0.5)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // Front vibrant wave
                    WaveShape(progress: progress, waveOffset: Angle(degrees: -angle))
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.cyan.opacity(0.85),
                                    Color.blue.opacity(0.95)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            }
            .clipShape(Circle())

            // Outer adaptive rim border (adapts to light and dark modes)
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.cyan.opacity(0.7),
                            Color.blue.opacity(0.4),
                            colorScheme == .dark ? Color.white.opacity(0.25) : Color.white.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )

            // Center Content / Dynamic Type text metrics
            VStack(spacing: 4) {
                if percentage >= 100 {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("Goal Met!")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
                }

                Text("\(percentage)%")
                    .font(.system(size: percentageFontSize, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .foregroundStyle(
                        percentage > 40 ? Color.white : Color.primary
                    )
                    .shadow(color: Color.black.opacity(percentage > 40 ? 0.35 : 0.08), radius: 4, x: 0, y: 2)

                VStack(spacing: 2) {
                    Text("\(Int(currentMl)) / \(Int(goalMl)) \(unitString)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .foregroundStyle(percentage > 40 ? Color.white.opacity(0.95) : Color.secondary)

                    let remaining = max(0, goalMl - currentMl)
                    if remaining > 0 {
                        Text("\(Int(remaining)) \(unitString) left")
                            .font(.caption2)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .foregroundStyle(percentage > 40 ? Color.white.opacity(0.85) : Color.secondary)
                    } else {
                        Text("Well hydrated! 🌟")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.white.opacity(0.95))
                    }
                }
            }
            .padding(16)
        }
        .frame(width: effectiveDiameter, height: effectiveDiameter)
        .shadow(
            color: Color.blue.opacity(colorScheme == .dark ? 0.35 : 0.15),
            radius: 16,
            x: 0,
            y: 8
        )
    }
}
