//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Svetlana Varenova on 21.10.2025.
//

import Foundation

final class CategoriesViewModel {
    
    // MARK: - Properties
    private let categoryStore: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesUpdated?()
        }
    }
    
    var selectedCategory: String? {
        didSet {
            if let selected = selectedCategory {
                UserDefaults.standard.set(selected, forKey: "SelectedCategory")
                onCategorySelected?(selected)
            }
        }
    }
    
    // MARK: - Public Properties (для доступа из ViewController)
    var store: TrackerCategoryStore {
        return categoryStore
    }
    
    // MARK: - Bindings
    var onCategoriesUpdated: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?
    var onError: ((String) -> Void)?
    var shouldShowPlaceholder: Bool {
        return categories.isEmpty
    }
    
    // MARK: - Init
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.categoryStore = categoryStore
        self.categoryStore.delegate = self
        fetchCategories()
        selectedCategory = UserDefaults.standard.string(forKey: "SelectedCategory")
    }
    
    // MARK: - Data methods
    func fetchCategories() {
        categories = categoryStore.getAllCategories()
    }
    
    func numberOfRows() -> Int {
        return categories.count
    }
    
    func category(at index: Int) -> TrackerCategory {
        return categories[index]
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        return categories[index].title == selectedCategory
    }
    
    func addCategory(title: String) {
        categoryStore.createCategory(title: title)
    }
    
    func deleteCategory(at index: Int) {
        let category = categories[index]
        categoryStore.deleteCategory(category)
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index].title
    }
    
    func getCellConfiguration(for index: Int) -> CategoryCellConfiguration {
        let category = categories[index]
        let isSelected = isCategorySelected(at: index)
        let isFirst = index == 0
        let isLast = index == categories.count - 1
        let showSeparator = index < categories.count - 1
        
        return CategoryCellConfiguration(
            title: category.title,
            isSelected: isSelected,
            isFirst: isFirst,
            isLast: isLast,
            showSeparator: showSeparator
        )
    }
    
    // MARK: - Context Menu Methods
    func getCategoryForContextMenu(at index: Int) -> TrackerCategory {
        return categories[index]
    }
    
    func findCategoryIndex(_ category: TrackerCategory) -> Int? {
        return categories.firstIndex { $0.title == category.title }
    }
}

// MARK: - Data Models
struct CategoryCellConfiguration {
    let title: String
    let isSelected: Bool
    let isFirst: Bool
    let isLast: Bool
    let showSeparator: Bool
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        fetchCategories()
    }
}
