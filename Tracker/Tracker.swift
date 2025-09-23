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
    let schedule: [Int]
    
    
    init(name: String, color: String, emoji: String, schedule: [Int]) {
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

enum WeekDay: String, CaseIterable, Hashable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
}
