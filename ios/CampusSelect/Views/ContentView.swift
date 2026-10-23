//
//  ContentView.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/17/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import SwiftData
import EventKit

struct ContentView: View {
    @AppStorage("isSetupComplete") private var isSetupComplete: Bool = false
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var events: [EventData]
    
    @State private var isDisplayingEditProfileSheet = false
    @State private var isFetching: Bool = false
    
    var body: some View {
        NavigationStack {
            if self.isSetupComplete {
                VStack {
                    Button {
                        Task {
                            self.isFetching = true
                            
                            defer {
                                self.isFetching = false
                            }
                            
                            let data: [EventData] = await BackendService.shared.fetchEvents()
                                                        
                            self.saveFetchedEvents(for: data)
                        }
                    } label: {
                        Text("Fetch Events")
                    }
                    
                    if self.isFetching {
                        ProgressView()
                    } else {
                        ScrollView {
                            VStack {
                                ForEach(self.events) { event in
                                    EventCard(event: event)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            self.isDisplayingEditProfileSheet = true
                        } label: {
                            Image(systemName: "person.crop.circle")
                        }
                    }
                }
                .sheet(isPresented: $isDisplayingEditProfileSheet) {
                    EditProfileSheetView()
                }
            } else {
                SplashView()
            }
        }
    }
    
    @MainActor
    private func saveFetchedEvents(for data: [EventData]) {
        let descriptor = FetchDescriptor<EventData>()
        
        guard let storedEvents = try? self.modelContext.fetch(descriptor) else { return }
        
        let existingKeys = Set(storedEvents.map { $0.compositeKey })
        
        for event in data {
            if !existingKeys.contains(event.compositeKey) {
                self.modelContext.insert(event)
            }
        }
        
        try? self.modelContext.save()
    }
}



#Preview {
    ContentView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
