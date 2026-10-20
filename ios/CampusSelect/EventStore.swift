//
//  EventStore.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/19/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation
import EventKit

final class EventStore {
    static var shared: EventStore = EventStore()
    
    private var store: EKEventStore = EKEventStore()
    
    func requestAccessToCalendar() {
        self.store.requestFullAccessToEvents { granted, error in
            // nothing, for now
        }
    }
    
    func fetchThisWeeksCalendar() -> [EKEvent] {
        let calendar = Calendar.current
        
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: .now) else { return [] }
        
        let now: Date = .now
        let endOfWeek: Date? = calendar.date(byAdding: .second, value: 1, to: interval.end)
        
        var predicate: NSPredicate? = nil
        
        if let endOfWeek = endOfWeek {
            predicate = self.store.predicateForEvents(withStart: now, end: endOfWeek, calendars: nil)
        }
        
        var events: [EKEvent]? = nil
        
        if let predicate = predicate {
            events = store.events(matching: predicate)
        }
        
        return events ?? []
    }
    
    private func convertEKEventToEventData() -> [EventData] {
        let events: [EKEvent] = self.fetchThisWeeksCalendar()
        
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .current
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        var data: [EventData] = []
        
        for event in events {
            data.append(
                EventData(
                    title: event.title,
                    start_time: event.startDate.ISO8601Format(),
                    end_time: event.endDate.ISO8601Format()
                )
            )
        }
        
        return data
    }
    
    func asJsonString() -> String? {
        let events: EventsPayload = EventsPayload(events: self.convertEKEventToEventData())
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let json = try encoder.encode(events)
            
            if let jsonString = String(data: json, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Failed to convert EventData list to jsonString: \(error)")
        }
        
        return nil
    }
}

struct EventsPayload: Encodable {
    let events: [EventData]
}
