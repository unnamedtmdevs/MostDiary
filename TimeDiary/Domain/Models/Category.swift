//  Category.swift
//  TimeDiary


import SwiftUI

struct Category: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var isDefault: Bool
    var createdAt: Date
    var lastUsedAt: Date?

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String,
        colorHex: String,
        isDefault: Bool = false,
        createdAt: Date = Date(),
        lastUsedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.isDefault = isDefault
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
    }

    var color: Color {
        Color(hex: colorHex)
    }

    static let defaultCategories: [Category] = [
        Category(
            name: "Work",
            iconName: "briefcase.fill",
            colorHex: "6A1B9A",
            isDefault: true
        ),
        Category(
            name: "Rest",
            iconName: "bed.double.fill",
            colorHex: "43A047",
            isDefault: true
        ),
        Category(
            name: "Sport",
            iconName: "figure.run",
            colorHex: "FF5722",
            isDefault: true
        ),
        Category(
            name: "Learning",
            iconName: "book.fill",
            colorHex: "6A1B9A",
            isDefault: true
        ),
        Category(
            name: "Social",
            iconName: "person.2.fill",
            colorHex: "E91E63",
            isDefault: true
        ),
        Category(
            name: "Sleep",
            iconName: "moon.fill",
            colorHex: "546E7A",
            isDefault: true
        ),
        Category(
            name: "Hobby",
            iconName: "paintbrush.fill",
            colorHex: "FF5722",
            isDefault: true
        ),
        Category(
            name: "Other",
            iconName: "square.grid.2x2.fill",
            colorHex: "546E7A",
            isDefault: true
        )
    ]
}
