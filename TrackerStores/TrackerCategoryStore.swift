//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by semrumyantsev on 17.07.2025.
//

import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

final class TrackerCategoryStore: NSObject {
    private var context: NSManagedObjectContext
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        
        return controller
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        try? fetchedResultsController.performFetch()
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        let request = TrackerCategoryCoreData.fetchRequest()
        let categories = try context.fetch(request)
        
        return categories.compactMap { category in
            guard let title = category.title else { return nil }
            
            // Получаем все трекеры для категории
            let trackers: [Tracker] = (category.trackers?.allObjects as? [TrackerCoreData] ?? []).compactMap { trackerCD in
                guard let id = trackerCD.id,
                      let title = trackerCD.title,
                      let emoji = trackerCD.emoji,
                      let days = trackerCD.weekday else { return nil }
                
                let weekdays: [Weekday] = days.compactMap { char in
                    guard let rawValue = Int(String(char)),
                          let weekday = Weekday(rawValue: rawValue) else {
                        return nil
                    }
                    return weekday
                }
                
                return Tracker(
                    trackerId: id,
                    title: title,
                    emoji: emoji,
                    colorIndex: Int(trackerCD.color),
                    day: weekdays,
                    counterDays: Int(trackerCD.counterRecords)
                )
            }
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    func addCategory(_ title: String) throws -> TrackerCategoryCoreData {
        let category = TrackerCategoryCoreData(context: context)
        category.id = UUID()
        category.title = title
        try context.save()
        print("TrackerCategoryStore: Категория сохранена")
        return category
    }
    
    func deleteCategory(_ id: UUID) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        
        if let category = try context.fetch(request).first {
            context.delete(category)
            try context.save()
            print("TrackerCategoryStore: Категория удаленна")
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}
