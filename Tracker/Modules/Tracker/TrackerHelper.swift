//
//  TrackerHelper.swift
//  Tracker
//
//  Created by Svetlana Varenova on 24.10.2025.
//

import Foundation

extension Int {
    func dayText() -> String {
        let count = self
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 { return "дней" }
        switch lastDigit {
        case 1: return "день"
        case 2, 3, 4: return "дня"
        default: return "дней"
        }
    }
}
