import Foundation
import SwiftData

@Model
final class FoodEntry {
    var id: UUID
    var name: String
    var calories: Int
    var mealRawValue: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        calories: Int,
        meal: Meal,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.mealRawValue = meal.rawValue
        self.createdAt = createdAt
    }

    var meal: Meal {
        get { Meal(rawValue: mealRawValue) ?? .snack }
        set { mealRawValue = newValue.rawValue }
    }
}

@Model
final class UserSettings {
    var id: UUID
    var dailyGoal: Int

    init(id: UUID = UUID(), dailyGoal: Int = 2_000) {
        self.id = id
        self.dailyGoal = dailyGoal
    }
}

enum Meal: String, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .breakfast: return "sun.max.fill"
        case .lunch: return "fork.knife"
        case .dinner: return "moon.stars.fill"
        case .snack: return "carrot.fill"
        }
    }
}
