//
//  EventData.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/19/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//


struct EventData: Identifiable {
    var title: String
    var id: UUID = UUID()
    var description: String?
    var start_time: String
    var end_time: String
}