import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \FoodEntry.createdAt, order: .reverse)
    private var entries: [FoodEntry]

    private var grouped: [(Date, [FoodEntry])] {
        let groups = Dictionary(grouping: entries) {
            Calendar.current.startOfDay(for: $0.createdAt)
        }

        return groups
            .map {
                ($0.key, $0.value.sorted { $0.createdAt > $1.createdAt })
            }
            .sorted { $0.0 > $1.0 }
    }

    var body: some View {
        Group {
            if grouped.isEmpty {
                ContentUnavailableView(
                    "No history yet",
                    systemImage: "calendar.badge.clock",
                    description: Text("Your synced food history will appear here.")
                )
            } else {
                List {
                    ForEach(grouped, id: \.0) { date, entries in
                        Section {
                            ForEach(entries) { entry in
                                FoodEntryRow(entry: entry)
                            }
                        } header: {
                            Text(
                                date,
                                format: .dateTime
                                    .weekday(.wide)
                                    .month()
                                    .day()
                            )
                        } footer: {
                            Text("\(entries.reduce(0) { $0 + $1.calories }) calories")
                                .monospacedDigit()
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
    }
}
