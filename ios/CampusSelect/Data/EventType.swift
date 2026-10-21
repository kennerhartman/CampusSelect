//
//  EventType.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/20/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//


import SwiftUI
import SwiftData
import EventKit

enum EventType: Decodable {
    case progress
    case complete
    case unknown
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)
        
        switch status {
        case "progress": self = .progress
        case "complete": self = .complete
        default: self = .unknown
        }
    }
}