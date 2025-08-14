//
//  CategorySelectionModel.swift
//  Tracker
//
//  Created by semrumyantsev on 13.08.2025.
//

import CoreData

protocol CategorySelectionModelProtocol {
    func fetchCategories() throws -> [TrackerCategory]
    func addCategory(_ title: String) throws -> TrackerCategoryCoreData
    func deleteCategory(_ id: UUID) throws
}

final class CategorySelectionModel: CategorySelectionModelProtocol {
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let categories = try coreDataManager.context.fetch(request)
        return categories.compactMap { category in
            guard let title = category.title else { return nil }
            
            let trackers: [Tracker] = (category.trackers?.allObjects as? [TrackerCoreData] ?? []).compactMap {
                guard let id = $0.id,
                      let title = $0.title,
                      let emoji = $0.emoji,
                      let days = $0.weekday else { return nil }
                
                let weekdays = days.compactMap { char in
                    Weekday(rawValue: Int(String(char)) ?? 0)
                }
                
                return Tracker(
                    trackerId: id,
                    title: title,
                    emoji: emoji,
                    colorIndex: Int($0.color),
                    day: weekdays,
                    counterDays: Int($0.counterRecords)
                )
            }
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    func addCategory(_ title: String) throws -> TrackerCategoryCoreData {
        let category = TrackerCategoryCoreData(context: coreDataManager.context)
        category.id = UUID()
        category.title = title
        try coreDataManager.saveContext()
        return category
    }
    
    //TODO: надо решить как это реализовать, удалять ли с категорией все трекеры категории или давать возможность удалять только если у категории нет трекеров
    func deleteCategory(_ id: UUID) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        
        if let category = try coreDataManager.context.fetch(request).first {
            coreDataManager.context.delete(category)
            coreDataManager.saveContext()
        }
    }
}
