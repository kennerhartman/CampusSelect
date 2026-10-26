//
//  AppManager.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/24/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation

@Observable
class AppManager {
    static let shared = AppManager()
    
    private init() {}
    
    var apnsToken: String? {
        get { UserDefaults.standard.string(forKey: "CachedAPNSToken") }
        set { UserDefaults.standard.set(newValue, forKey: "CachedAPNSToken")}
    }
}
