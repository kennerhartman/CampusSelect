//
//  Date+Extension.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/22/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation

extension Date {
    static func parseDate(for date: String) -> Date? {
        guard let parsedDate = try? Date(date, strategy: .iso8601) else { return nil }
        
        return parsedDate
    }
}
