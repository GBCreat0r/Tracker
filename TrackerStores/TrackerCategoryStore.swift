//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by semrumyantsev on 17.07.2025.
//

import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = SceneDelegate.shared.context) {
        self.context = context
    }
    
    func addCategory(title: String) throws {
        let category = NSEntityDescription.insertNewObject(
            forEntityName: "TrackerCategory",
            into: context
        )
        category.setValue(title, forKey: "title")
        try context.save()
    }
    
    func fetchOrCreateCategory(title: String) throws -> NSManagedObject {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackerCategory")
        request.predicate = NSPredicate(format: "title == %@", title)
        
        if let existing = try context.fetch(request).first {
            return existing
        }
        
        let newCategory = NSEntityDescription.insertNewObject(
            forEntityName: "TrackerCategory",
            into: context
        )
        newCategory.setValue(title, forKey: "title")
        return newCategory
    }
    
    func fetchCategories() throws -> [String] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackerCategory")
        let categories = try context.fetch(request)
        return categories.compactMap { $0.value(forKey: "title") as? String }
    }
}
