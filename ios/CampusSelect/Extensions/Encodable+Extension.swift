//
//  Encodable+Extension.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/23/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation

extension Encodable {
    func asJsonString() -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let json = try encoder.encode(self)
            
            if let jsonString = String(data: json, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Failed to convert \(type(of: self)) to json string: \(error)")
        }
        
        return nil
    }
}
