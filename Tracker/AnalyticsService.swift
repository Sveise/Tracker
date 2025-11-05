//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Svetlana Varenova on 04.11.2025.
//

import Foundation
import AppMetricaCore

enum AnalyticsEventType: String {
    case open
    case close
    case click
}

struct AnalyticsService {
    
    // MARK: - Activation
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "dafd97ca-a28f-479a-8974-0a72d4130744") else { return }
        AppMetrica.activate(with: configuration)
        print("AppMetrica activated")
    }
    
    // MARK: - Reporting
    static func report(event: AnalyticsEventType, screen: String, item: String? = nil) {
        var parameters: [String: Any] = [
            "event": event.rawValue,
            "screen": screen
        ]
        if let item = item {
            parameters["item"] = item
        }
        
        AppMetrica.reportEvent(name: "ui_event", parameters: parameters) { error in
            print("AppMetrica report error: \(error.localizedDescription)")
        }
        
        print("Analytics event: \(parameters)")
    }
}
