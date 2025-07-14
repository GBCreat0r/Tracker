//
//  TrackersStruct.swift
//  Tracker
//
//  Created by semrumyantsev on 30.06.2025.
//

import Foundation

struct Tracker: Codable {
    let trackerId: UUID
    let title: String
    let emoji: String
    let colorIndex: Int
    let trackerType: TrackerType
    let day: [Weekday]
    let counterDays: Int
    
    enum TrackerType: String, Codable {
        case regular
        case irregular
    }
}

enum Weekday: Int, CaseIterable, Codable {
    case monday = 2,
         tuesday = 3,
         wednesday = 4,
         thursday = 5,
         friday = 6,
         saturday = 7,
         sunday = 1
    
    var stringValue: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
}

struct TrackerCategory: Codable {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord{
    let trackerId: UUID
    let date: Date
}
