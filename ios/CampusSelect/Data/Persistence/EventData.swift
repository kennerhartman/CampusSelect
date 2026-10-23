//
//  EventData.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/19/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation
import SwiftData

@Model
class EventData: Identifiable, Codable {
    var title: String
    var id: UUID = UUID()
    var eventDescription: String?
    var startTime: Date
    var endTime: Date
    
    var compositeKey: String {
        "\(self.title)_\(self.startTime)_\(self.endTime)"
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case start_time
        case end_time
    }
    
    init(title: String, eventDescription: String? = nil, startTime: Date, endTime: Date) {
        self.title = title
        self.eventDescription = eventDescription
        self.startTime = startTime
        self.endTime = endTime
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.title, forKey: .title)
        try container.encodeIfPresent(self.eventDescription, forKey: .description)
        try container.encode(self.startTime, forKey: .start_time)
        try container.encode(self.endTime, forKey: .end_time)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try container.decode(String.self, forKey: .title)
        self.eventDescription = try container.decodeIfPresent(String.self, forKey: .description)
        self.startTime = Date.parseDate(for: try container.decode(String.self, forKey: .start_time)) ?? .now
        self.endTime = Date.parseDate(for: try container.decode(String.self, forKey: .end_time)) ?? .now
    }
}
