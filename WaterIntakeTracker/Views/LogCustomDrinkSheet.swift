import SwiftUI

public struct LogCustomDrinkSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var amountMl: Double = 250
    @State private var selectedDrinkType: DrinkType = .water
    @State private var timestamp: Date = Date()
    @State private var note: String = ""

    public let onSave: (Double, DrinkType, Date, String) -> Void

    public init(initialAmount: Double = 250, onSave: @escaping (Double, DrinkType, Date, String) -> Void) {
        _amountMl = State(initialValue: initialAmount)
        self.onSave = onSave
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("\(Int(amountMl)) ml")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(selectedDrinkType.themeColor)

                            Spacer()

                            // Quick preset pills
                            HStack(spacing: 8) {
                                ForEach([150.0, 250.0, 350.0, 500.0, 750.0], id: \.self) { preset in
                                    Button("\(Int(preset))") {
                                        amountMl = preset
                                    }
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(amountMl == preset ? selectedDrinkType.themeColor : Color(.systemGray5))
                                    .foregroundColor(amountMl == preset ? .white : .primary)
                                    .clipShape(Capsule())
                                }
                            }
                        }

                        Slider(value: $amountMl, in: 50...1500, step: 25)
                            .tint(selectedDrinkType.themeColor)
                    }
                    .padding(.vertical, 6)
                }

                Section("Beverage Type") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                        ForEach(DrinkType.allCases) { type in
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(selectedDrinkType == type ? type.themeColor : type.themeColor.opacity(0.15))
                                        .frame(width: 48, height: 48)

                                    Image(systemName: type.iconName)
                                        .foregroundColor(selectedDrinkType == type ? .white : type.themeColor)
                                        .font(.system(size: 20))
                                }

                                Text(type.rawValue)
                                    .font(.caption2)
                                    .fontWeight(selectedDrinkType == type ? .bold : .regular)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedDrinkType == type ? Color(.systemGray6) : Color.clear)
                            )
                            .onTapGesture {
                                selectedDrinkType = type
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Details") {
                    DatePicker("Time", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])

                    TextField("Note (optional)", text: $note)
                }
            }
            .navigationTitle("Log Drink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        onSave(amountMl, selectedDrinkType, timestamp, note)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
