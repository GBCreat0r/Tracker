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
    let day: [Weekday]
    let counterDays: Int
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
        case .monday:
            return NSLocalizedString("weekday.monday", comment: "")
        case .tuesday:
            return NSLocalizedString("weekday.tuesday", comment: "")
        case .wednesday:
            return NSLocalizedString("weekday.wednesday", comment: "")
        case .thursday:
            return NSLocalizedString("weekday.thursday", comment: "")
        case .friday:
            return NSLocalizedString("weekday.friday", comment: "")
        case .saturday:
            return NSLocalizedString("weekday.saturday", comment: "")
        case .sunday:
            return NSLocalizedString("weekday.sunday", comment: "")
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
