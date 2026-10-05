import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]

    @State private var goalText = "2000"

    var body: some View {
        Form {
            Section("Daily Goal") {
                TextField("Calories", text: $goalText)
                    .keyboardType(.numberPad)

                Button("Save Goal") {
                    saveGoal()
                }
                .frame(minHeight: 44)
            }

            Section("Cloud Sync") {
                Label(
                    "Uses SwiftData with CloudKit when iCloud capability is enabled.",
                    systemImage: "icloud"
                )

                Text("Data is stored in the signed-in user's private iCloud database.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                Text("This starter tracks calories only and does not provide medical or nutritional advice.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .task {
            loadGoal()
        }
    }

    private func loadGoal() {
        if let existing = settings.first {
            goalText = String(existing.dailyGoal)
        } else {
            let newSettings = UserSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            goalText = String(newSettings.dailyGoal)
        }
    }

    private func saveGoal() {
        guard let value = Int(goalText), value > 0 else { return }

        if let existing = settings.first {
            existing.dailyGoal = value
        } else {
            modelContext.insert(UserSettings(dailyGoal: value))
        }

        try? modelContext.save()
    }
}
