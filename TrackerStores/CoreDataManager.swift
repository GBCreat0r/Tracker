//
//  CoreDataManager.swift
//  Tracker
//
//  Created by semrumyantsev on 07.08.2025.
//

import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerCD")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error {
                print("Ошибка запуска контейнера КорДата:\(error)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            let NSError = error as NSError
            assertionFailure("Ошибка: \(NSError), \(NSError.userInfo)")
            context.rollback()
        }
    }
}
