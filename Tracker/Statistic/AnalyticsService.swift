//
//  AnalyticsService.swift
//  Tracker
//
//  Created by semrumyantsev on 21.08.2025.
//

import UIKit
import AppMetricaCore

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    func report(event: String, screen: String, item: String? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": screen
        ]
        
        if let item = item {
            params["item"] = item
        }
        
        AppMetrica.reportEvent(name: "event", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    func reportMainScreenOpen() {
        report(event: "open", screen: "Main")
    }
    
    func reportMainScreenClose() {
        report(event: "close", screen: "Main")
    }
    
    func reportAddTrackTap() {
        report(event: "click", screen: "Main", item: "add_track")
    }
    
    func reportTrackTap() {
        report(event: "click", screen: "Main", item: "track")
    }
    
    func reportFilterTap() {
        report(event: "click", screen: "Main", item: "filter")
    }
    
    func reportEditTap() {
        report(event: "click", screen: "Main", item: "edit")
    }
    
    func reportDeleteTap() {
        report(event: "click", screen: "Main", item: "delete")
    }
}
