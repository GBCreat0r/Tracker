//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by semrumyantsev on 17.07.2025.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchRecords() throws -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        let recordsCD = try context.fetch(request)
        
        return recordsCD.compactMap { recordCD in
            guard
                let trackerId = recordCD.trackerid,
                let date = recordCD.date
            else { return nil }
            
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }
    
    func addRecord(trackerID: UUID, date: Date) throws {
        let trackerRequest = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", trackerID.uuidString)
        
        guard let tracker = try context.fetch(trackerRequest).first else {
            throw NSError(domain: "TrackerRecordStore", code: 404, userInfo: [NSLocalizedDescriptionKey : "Трекер не найден"])
        }
        
        let existingRecordRequest = TrackerRecordCoreData.fetchRequest()
        existingRecordRequest.predicate = NSPredicate(format: "trackerid == %@ AND date == %@", trackerID.uuidString, date as CVarArg)
        
        if let existingRecord = try context.fetch(existingRecordRequest).first {
            print("Трекер Рекорд: Запись уже есть")
            return
        }
        
        let newRecord = TrackerRecordCoreData(context: context)
        newRecord.trackerid = trackerID
        newRecord.date = date
        newRecord.tracker = tracker
        
        try context.save()
        print ("Добавлена запись для трекера \(trackerID) на дату \(date)")
    }
    
    func deleteRecord(trackerID: UUID, date: Date) throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerid == %@ AND date >= %@ AND date < %@",
                                        trackerID.uuidString,
                                        startOfDay as CVarArg,
                                        endOfDay as CVarArg)
        
        let records = try context.fetch(request)
        for record in records {
            context.delete(record)
        }
        
        if !records.isEmpty {
            try context.save()
            print(" Удалена запись для трекера \(trackerID) на дату \(date)")
        } else {
            print(" Записи \(trackerID) \(date) не найдены")
        }
    }
    
    func countRecords(for trackerID: UUID) throws -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerid == %@", trackerID.uuidString)
        return try context.count(for: request)
    }
}
