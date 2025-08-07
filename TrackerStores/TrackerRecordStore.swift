//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by semrumyantsev on 17.07.2025.
//

import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = SceneDelegate.shared.context) {
        self.context = context
    }
    
    func addRecord(trackerId: UUID, date: Date) throws {
        let record = NSEntityDescription.insertNewObject(
            forEntityName: "TrackerRecord",
            into: context
        )
        record.setValue(date, forKey: "date")
        
        let trackerRequest = NSFetchRequest<NSManagedObject>(entityName: "Tracker")
        trackerRequest.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        
        if let tracker = try context.fetch(trackerRequest).first {
            record.setValue(tracker, forKey: "tracker")
        }
        
        try context.save()
    }
    
    func fetchRecords() throws -> [TrackerRecord] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackerRecord")
        let records = try context.fetch(request)
        
        return records.compactMap { record in
            guard let tracker = record.value(forKey: "tracker") as? NSManagedObject,
                  let trackerId = tracker.value(forKey: "trackerId") as? UUID,
                  let date = record.value(forKey: "date") as? Date else {
                return nil
            }
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }
    
    func deleteRecord(trackerId: UUID, date: Date) throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackerRecord")
        request.predicate = NSPredicate(
            format: "tracker.trackerId == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            date.startOfDay as CVarArg,
            date.endOfDay as CVarArg
        )
        
        let records = try context.fetch(request)
        records.forEach { context.delete($0) }
        try context.save()
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
}
