//
//  CategorySelectionViewModel.swift
//  Tracker
//
//  Created by semrumyantsev on 13.08.2025.
//

protocol CategorySelectionViewModelProtocol {
    var categories: [String] { get }
    var updateView: (() -> Void)? { get set }
    var showPlaceholder: ((Bool) -> Void)? { get set }
    var showError: ((String) -> Void)? { get set }
    var onCategorySelected: ((String) -> Void)? { get set }
    
    func fetchCategories()
    func addCategory(_ title: String)
    func selectCategory(at index: Int)
    func deleteCategory(at index: Int)
}

final class CategorySelectionViewModel: CategorySelectionViewModelProtocol {
    private let model: CategorySelectionModelProtocol
    
    var categories: [String] = []
    var updateView: (() -> Void)?
    var showPlaceholder: ((Bool) -> Void)?
    var showError: ((String) -> Void)?
    var onCategorySelected: ((String) -> Void)?
    
    init(model: CategorySelectionModelProtocol) {
        self.model = model
    }
    
    func fetchCategories() {
        do {
            let trackerCategories = try model.fetchCategories()
            categories = trackerCategories.map { $0.title }
            updateView?()
            showPlaceholder?(categories.isEmpty)
        } catch {
            showError?("Не удалось загрузить категории")
            print("Failed to fetch categories: \(error)")
        }
    }
    
    func addCategory(_ title: String) {
        guard !title.isEmpty else {
            showError?("Название категории не может быть пустым")
            return
        }
        
        do {
            _ = try model.addCategory(title)
            fetchCategories()
        } catch {
            showError?("Не удалось добавить категорию")
            print("Failed to add category: \(error)")
        }
    }
    
    func selectCategory(at index: Int) {
        guard index >= 0 && index < categories.count else {
            showError?("Неверный индекс категории")
            return
        }
        
        let selectedCategory = categories[index]
        onCategorySelected?(selectedCategory)
    }
    
//  TODO: Смотри MOdel
    func deleteCategory(at index: Int) {}
}
