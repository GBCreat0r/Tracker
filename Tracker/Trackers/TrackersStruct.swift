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
    let color: String
    let trackerType: TrackerType
    let day: [Weekday]
    let counterDays: Int
    
    enum TrackerType: String, Codable {
        case regular
        case irregular
    }
}

enum Weekday: Int, CaseIterable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var stringValue: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}

struct TrackerCategory: Codable {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecoed{
    let trackerId: UUID
    let date: Date
}
