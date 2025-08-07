

import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = SceneDelegate.shared.context) {
        self.context = context
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {
        let trackerEntity = NSEntityDescription.insertNewObject(
            forEntityName: "Tracker",
            into: context
        )
        
        trackerEntity.setValue(tracker.trackerId, forKey: "trackerId")
        trackerEntity.setValue(tracker.title, forKey: "title")
        trackerEntity.setValue(tracker.emoji, forKey: "emoji")
        trackerEntity.setValue(Int64(tracker.colorIndex), forKey: "color")
        trackerEntity.setValue(Int64(tracker.counterDays), forKey: "counter")
        trackerEntity.setValue(tracker.day.map { String($0.rawValue) }.joined(), forKey: "weekday")
        
        let category = try TrackerCategoryStore(context: context).fetchOrCreateCategory(title: categoryTitle)
        trackerEntity.setValue(category, forKey: "category")
        
        try context.save()
    }
    
    func fetchTrackers() throws -> [Tracker] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Tracker")
        let trackers = try context.fetch(request)
        
        return trackers.compactMap { entity in
            guard let trackerId = entity.value(forKey: "trackerId") as? UUID,
                  let title = entity.value(forKey: "title") as? String,
                  let emoji = entity.value(forKey: "emoji") as? String,
                  let daysString = entity.value(forKey: "weekday") as? String else {
                return nil
            }
            
            return Tracker(
                trackerId: trackerId,
                title: title,
                emoji: emoji,
                colorIndex: Int(entity.value(forKey: "color") as? Int64 ?? 0),
                day: daysString.compactMap { Weekday(rawValue: Int(String($0)) ?? 0) },
                counterDays: Int(entity.value(forKey: "counter") as? Int64 ?? 0)
            )
        }
    }
    
    func deleteTracker(_ trackerId: UUID) throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Tracker")
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        
        if let tracker = try context.fetch(request).first {
            context.delete(tracker)
            try context.save()
        }
    }
}

