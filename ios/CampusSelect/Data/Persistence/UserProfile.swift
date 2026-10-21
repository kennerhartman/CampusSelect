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
class UserProfile {
    var name: String
    var about: String
    var gender: Gender
    
    init(name: String, about: String, gender: Gender) {
        self.name = name
        self.about = about
        self.gender = gender
    }
}
