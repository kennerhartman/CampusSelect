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
    
    @Query(sort: \EventData.startTime) private var events: [EventData]
    @Query private var profiles: [UserProfile]
    
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
                            
                            if let profile = self.profiles.first {
                                let data: [EventData] = await BackendService.shared.fetchEvents(with: profile)
                                                            
                                self.saveFetchedEvents(for: data)
                            }
                        }
                    } label: {
                        Text("Fetch Events")
                    }
                    
                    Button {
                        try? self.modelContext.delete(model: EventData.self)
                    } label: {
                        Text("Delete events")
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
    private func saveFetchedEvents(for events: [EventData]) {
        let descriptor = FetchDescriptor<EventData>()
        
        guard let storedEvents = try? self.modelContext.fetch(descriptor) else { return }
        
        let existingKeys = Set(storedEvents.map { $0.compositeKey })
        
        for event in events {
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
