import SwiftUI

public struct IntakeHistoryRow: View {
    public let log: WaterLog

    public init(log: WaterLog) {
        self.log = log
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: log.timestamp)
    }

    public var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(log.drinkType.themeColor.opacity(0.16))
                    .frame(width: 42, height: 42)

                Image(systemName: log.drinkType.iconName)
                    .foregroundColor(log.drinkType.themeColor)
                    .font(.system(size: 17))
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(log.drinkType.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    if !log.note.isEmpty {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(log.note)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Text(formattedTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(log.amountMl)) ml")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.85)
                    .lineLimit(1)

                if log.drinkType.hydrationFactor != 1.0 {
                    Text("~ \(Int(log.effectiveHydrationMl)) ml net")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
