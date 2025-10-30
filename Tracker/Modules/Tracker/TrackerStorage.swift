//
//  TrackerStorage.swift
//  Tracker
//
//  Created by Svetlana Varenova on 17.09.2025.
//

import Foundation

final class TrackerStorage {
    static let shared = TrackerStorage()
    
    private let categoriesKey = "trackerCategories"
    private let recordsKey = "trackerRecords"
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {}
    
    func saveCategories(_ categories: [TrackerCategory]) {
        if let data = try? encoder.encode(categories) {
            UserDefaults.standard.set(data, forKey: categoriesKey)
        }
    }
    
    func loadCategories() -> [TrackerCategory] {
        guard let data = UserDefaults.standard.data(forKey: categoriesKey),
              let categories = try? decoder.decode([TrackerCategory].self, from: data) else {
            return []
        }
        return categories
    }
    
    func saveRecords(_ records: [TrackerRecord]) {
        if let data = try? encoder.encode(records) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
    }
    
    func loadRecords() -> [TrackerRecord] {
        guard let data = UserDefaults.standard.data(forKey: recordsKey),
              let records = try? decoder.decode([TrackerRecord].self, from: data) else {
            return []
        }
        return records
    }
}
