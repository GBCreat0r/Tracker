

import CoreData
protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: TrackerStoreDelegate?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
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
    
    func addTracker(tracker: Tracker, categoryTitle: String) throws {
        let trackerCD = TrackerCoreData(context: context)
        trackerCD.color = Int64(tracker.colorIndex)
        trackerCD.id = tracker.trackerId
        trackerCD.title = tracker.title
        trackerCD.emoji = tracker.emoji
        trackerCD.counterRecords = Int64(tracker.counterDays)
        // Тут я сделал конкатенацию числовых значений недели в строку
        trackerCD.weekday = tracker.day.map { String($0.rawValue) }.joined()
        
        let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        
        if let existingCategory = try? context.fetch(categoryRequest).first {
            trackerCD.category = existingCategory
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.id = UUID()
            newCategory.title = categoryTitle
            trackerCD.category = newCategory
        }
        
        try context.save()
        print("TrackerStore: Трекер сохранён")
    }
    
    func fetchTrackers() throws -> [Tracker] {
        let request = TrackerCoreData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let trackersCD = try context.fetch(request)
        
        return trackersCD.compactMap { data in
            guard let id = data.id,
                  let title = data.title,
                  let emoji = data.emoji,
                  let days = data.weekday
            else { return nil }
            
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
                colorIndex: Int(data.color),
                day: weekdays,
                counterDays: Int(data.counterRecords)
            )
        }
    }
    
    func deleteTracker(_ id: UUID) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if let tracker = try context.fetch(request).first {
            context.delete(tracker)
            try context.save()
            print("TrackerStore: Трекер удалён")
        } else {
            print("TrackerStore: Трекер с id \(id) не найден")
        }
    }
    
    func updateTracker(_ tracker: Tracker, categoryTitle: String) throws {
            let request = TrackerCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", tracker.trackerId.uuidString)
            
            guard let trackerCD = try context.fetch(request).first else {
                throw NSError(domain: "TrackerStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Трекер не найден"])
            }
            
            trackerCD.title = tracker.title
            trackerCD.emoji = tracker.emoji
            trackerCD.color = Int64(tracker.colorIndex)
            trackerCD.weekday = tracker.day.map { String($0.rawValue) }.joined()
            
            let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            categoryRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
            
            if let existingCategory = try? context.fetch(categoryRequest).first {
                trackerCD.category = existingCategory
            } else {
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.id = UUID()
                newCategory.title = categoryTitle
                trackerCD.category = newCategory
            }
            
            try context.save()
            print("TrackerStore: Трекер обновлён")
        }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}
