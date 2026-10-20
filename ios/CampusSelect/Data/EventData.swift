//
//  EventData.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/19/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation

struct EventData: Identifiable, Encodable {
    var title: String
    var id: UUID = UUID()
    var description: String?
    var start_time: String
    var end_time: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case start_time
        case end_time
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.title, forKey: .title)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encode(self.start_time, forKey: .start_time)
        try container.encode(self.end_time, forKey: .end_time)
    }
}
