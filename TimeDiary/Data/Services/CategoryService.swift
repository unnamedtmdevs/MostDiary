//  CategoryService.swift
//  TimeDiary


import Foundation

extension Notification.Name {
    static let categoriesDidChange = Notification.Name("categoriesDidChange")
}

final class CategoryService {
    static let shared = CategoryService()
    private let storage = StorageService.shared

    private init() {
        initializeDefaultCategories()
    }
    
    private func notifyCategoriesChanged() {
        NotificationCenter.default.post(name: .categoriesDidChange, object: nil)
    }

    func getAllCategories() -> [Category] {
        storage.load(forKey: UserDefaultsKeys.categories, as: [Category].self) ?? []
    }

    func getCategory(byId id: UUID) -> Category? {
        getAllCategories().first { $0.id == id }
    }

    func createCategory(_ category: Category) {
        var categories = getAllCategories()
        categories.append(category)
        storage.save(categories, forKey: UserDefaultsKeys.categories)
        notifyCategoriesChanged()
    }

    func updateCategory(_ category: Category) {
        var categories = getAllCategories()
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            storage.save(categories, forKey: UserDefaultsKeys.categories)
            notifyCategoriesChanged()
        }
    }

    func deleteCategory(id: UUID) {
        var categories = getAllCategories()
        categories.removeAll { $0.id == id }
        storage.save(categories, forKey: UserDefaultsKeys.categories)
        notifyCategoriesChanged()
    }

    func updateLastUsed(categoryId: UUID) {
        var categories = getAllCategories()
        if let index = categories.firstIndex(where: { $0.id == categoryId }) {
            categories[index].lastUsedAt = Date()
            storage.save(categories, forKey: UserDefaultsKeys.categories)
        }
    }

    func getCategoryStatistics(categoryId: UUID, entries: [TimeEntry]) -> CategoryStatistic? {
        let categoryEntries = entries.filter { $0.categoryId == categoryId }
        guard !categoryEntries.isEmpty, let category = getCategory(byId: categoryId) else {
            return nil
        }

        let totalTime = categoryEntries.reduce(0) { $0 + $1.duration }
        let averageDuration = totalTime / Double(categoryEntries.count)
        let allEntriesTime = entries.reduce(0) { $0 + $1.duration }
        let percentage = allEntriesTime > 0 ? totalTime / allEntriesTime : 0

        return CategoryStatistic(
            id: UUID(),
            categoryId: categoryId,
            categoryName: category.name,
            categoryColorHex: category.colorHex,
            totalTime: totalTime,
            numberOfEntries: categoryEntries.count,
            percentage: percentage,
            averageDuration: averageDuration
        )
    }

    private func initializeDefaultCategories() {
        let existingCategories = getAllCategories()
        if existingCategories.isEmpty {
            storage.save(Category.defaultCategories, forKey: UserDefaultsKeys.categories)
        }
    }
}
