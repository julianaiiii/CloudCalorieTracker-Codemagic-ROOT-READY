import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodEntry.createdAt, order: .reverse)
    private var entries: [FoodEntry]

    @Query private var settings: [UserSettings]

    @State private var showingAddFood = false

    private var dailyGoal: Int {
        settings.first?.dailyGoal ?? 2_000
    }

    private var todayEntries: [FoodEntry] {
        entries.filter {
            Calendar.current.isDateInToday($0.createdAt)
        }
    }

    private var consumed: Int {
        todayEntries.reduce(0) { $0 + $1.calories }
    }

    private var remaining: Int {
        dailyGoal - consumed
    }

    private var progress: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(consumed) / Double(dailyGoal), 1)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summaryCard

                if todayEntries.isEmpty {
                    ContentUnavailableView(
                        "No food logged yet",
                        systemImage: "fork.knife.circle",
                        description: Text("Add your first meal to start tracking today.")
                    )
                    .padding(.top, 20)
                } else {
                    mealList
                }
            }
            .padding()
        }
        .navigationTitle("Today")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddFood = true
                } label: {
                    Label("Add food", systemImage: "plus")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                showingAddFood = true
            } label: {
                Label("Log Food", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showingAddFood) {
            NavigationStack {
                AddFoodView()
            }
        }
        .task {
            ensureSettingsExist()
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Remaining")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("\(remaining)")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .monospacedDigit()

                    Text("calories")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 10)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(consumed)")
                            .font(.headline)
                            .monospacedDigit()

                        Text("eaten")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 110, height: 110)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Daily calorie progress")
                .accessibilityValue("\(consumed) of \(dailyGoal) calories consumed")
            }

            Divider()

            HStack {
                stat(title: "Goal", value: dailyGoal)
                Spacer()
                stat(title: "Consumed", value: consumed)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var mealList: some View {
        VStack(spacing: 16) {
            ForEach(Meal.allCases) { meal in
                let mealEntries = todayEntries.filter { $0.meal == meal }

                if !mealEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(meal.rawValue, systemImage: meal.symbol)
                            .font(.headline)

                        ForEach(mealEntries) { entry in
                            FoodEntryRow(entry: entry)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func stat(title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(value)")
                .font(.headline)
                .monospacedDigit()
        }
    }

    private func ensureSettingsExist() {
        guard settings.isEmpty else { return }
        modelContext.insert(UserSettings())
        try? modelContext.save()
    }
}
