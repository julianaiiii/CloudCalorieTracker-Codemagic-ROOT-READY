import SwiftUI
import SwiftData

struct FoodEntryRow: View {
    @Environment(\.modelContext) private var modelContext
    let entry: FoodEntry

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.meal.symbol)
                .frame(width: 34, height: 34)
                .background(.quaternary, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.name)
                    .font(.body.weight(.medium))

                Text(entry.createdAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(entry.calories) cal")
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .contextMenu {
            Button(role: .destructive) {
                modelContext.delete(entry)
                try? modelContext.save()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .accessibilityElement(children: .combine)
    }
}
