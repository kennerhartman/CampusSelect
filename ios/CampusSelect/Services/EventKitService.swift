//
//  EventStore.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/19/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation
import EventKit

final class EventKitService {
    static let shared: EventKitService = EventKitService()
    
    private var store: EKEventStore = EKEventStore()
    
    private init() {}
    
    func requestAccessToCalendar() {
        self.store.requestFullAccessToEvents { granted, error in
            // nothing, for now
        }
    }
    
    func getStore() -> EKEventStore {
        return self.store
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
    
    func convertToEKEvent(using eventData: EventData) -> EKEvent? {
        let eKEvent = EKEvent(eventStore: self.store)
                
        eKEvent.title = eventData.title
        
        if let description = eventData.eventDescription {
            eKEvent.notes = description
        }
        
        eKEvent.startDate = eventData.startTime
        eKEvent.endDate = eventData.endTime
        
        return eKEvent
    }
    
    func convertEKEventsToEventData() -> [EventData] {
        let events: [EKEvent] = self.fetchThisWeeksCalendar()
        
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .current
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        var data: [EventData] = []
        
        for event in events {
            data.append(
                EventData(
                    title: event.title,
                    startTime: event.startDate,
                    endTime: event.endDate
                )
            )
        }
        
        return data
    }
}


