//
//  UserProfile.swift
//  ArticleScanner
//
//  Created by Kenner Hartman on 10/8/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation
import SwiftData

@Model
class UserProfile: Encodable {
    var name: String
    var about: String
    var gender: Gender
    
    init(name: String, about: String, gender: Gender) {
        self.name = name
        self.about = about
        self.gender = gender
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case about
        case gender
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.name, forKey: .name)
        try container.encode(self.about, forKey: .about)
        try container.encode(self.gender, forKey: .gender)
    }
}
