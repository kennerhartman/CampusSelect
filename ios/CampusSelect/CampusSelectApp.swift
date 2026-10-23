//
//  CampusSelectApp.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/17/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct CampusSelectApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            EventData.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    EventKitService.shared.requestAccessToCalendar()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
