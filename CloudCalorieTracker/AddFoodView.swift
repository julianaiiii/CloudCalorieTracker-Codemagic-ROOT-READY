import SwiftUI
import SwiftData

struct AddFoodView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var caloriesText = ""
    @State private var meal: Meal = .breakfast

    private var calories: Int? {
        Int(caloriesText)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (calories ?? 0) > 0
    }

    var body: some View {
        Form {
            Section("Food") {
                TextField("Food name", text: $name)
                    .textInputAutocapitalization(.words)

                TextField("Calories", text: $caloriesText)
                    .keyboardType(.numberPad)
            }

            Section("Meal") {
                Picker("Meal", selection: $meal) {
                    ForEach(Meal.allCases) { meal in
                        Label(meal.rawValue, systemImage: meal.symbol)
                            .tag(meal)
                    }
                }
            }
        }
        .navigationTitle("Add Food")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(!canSave)
            }
        }
    }

    private func save() {
        guard let calories else { return }

        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let entry = FoodEntry(
            name: cleanedName,
            calories: calories,
            meal: meal
        )

        modelContext.insert(entry)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Save failed: \(error)")
        }
    }
}
