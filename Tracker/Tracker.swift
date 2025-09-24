//
//  Untitled.swift
//  Tracker
//
//  Created by Svetlana Varenova on 02.09.2025.
//

import UIKit

struct Tracker: Codable {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: [WeekDay]
    
    init(name: String, color: String, emoji: String, schedule: [WeekDay]) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}

struct TrackerCategory: Codable {
    let title: String
    let trackers: [Tracker]
    
    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
}

struct TrackerRecord: Codable {
    let trackerId: UUID
    let date: Date
    
    init(trackerId: UUID, date: Date) {
        self.trackerId = trackerId
        self.date = date
    }
}

enum WeekDay: Int, CaseIterable, Codable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var title: String {
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
    
    static func from(date: Date) -> WeekDay {
        let systemWeekday = Calendar.current.component(.weekday, from: date)
        let normalized = (systemWeekday == 1) ? 7 : systemWeekday - 1
        return WeekDay(rawValue: normalized)!
    }
}
