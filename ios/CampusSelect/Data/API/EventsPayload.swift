//
//  EventsPayload.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/20/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation
import EventKit

struct EventsPayload: Codable {
    let events: [EventData]
}
