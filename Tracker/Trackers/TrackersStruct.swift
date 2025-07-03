//
//  TrackersStruct.swift
//  Tracker
//
//  Created by semrumyantsev on 30.06.2025.
//

import Foundation

struct Tracker{
    let trackerId: UUID
    let title: String
    let emoji: String
    let color: String
    let trackerType: TrackerType
    let day: [Weekday]
    
    enum TrackerType {
    case regular
    case irregular
    }
}

enum Weekday: Int, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

struct TrackerCategory{
    let title: String
    let trackers: Tracker
}

struct TrackerRecoed{
    let trackerId: UUID
    let date: Date
}
