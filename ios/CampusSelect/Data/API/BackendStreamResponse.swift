//
//  BackendStreamResponse.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/20/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//


import SwiftUI
import SwiftData
import EventKit

struct BackendStreamResponse: Decodable {
    let event_type: EventType
    let message: String
    let events: [EventData]?
}