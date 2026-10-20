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

    @State private var isDisplayingEditProfileSheet = false
    @State private var isFetching: Bool = false
    @State private var data: [EventData] = []
    
    var body: some View {
        NavigationStack {
            if self.isSetupComplete {
                VStack {
                    Button {
                        Task {
                            await self.fetchEvents()
                        }
                    } label: {
                        Text("Fetch Events")
                    }
                    
                    if self.isFetching {
                        ProgressView()
                    } else {
                        ScrollView {
                            VStack {
                                ForEach(self.data) { event in
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
    
    private func fetchEvents() async {
        // TODO: MOVE BACKEND INTERACTION TO A DEDICATED CLASS
        
        var request: URLRequest = URLRequest(url: URL(string: "http://10.106.10.72:8000/api/fetch-events")!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let calendarRawJson = EventStore.shared.asJsonString()
        
        if let json = calendarRawJson?.data(using: .utf8) {
            request.httpBody = json
        }
        
        self.isFetching = true
        
        defer {
            self.isFetching = false
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request) // TODO: SWITCH TO UTILIZE SSE WITH URLSession.shared.bytes
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error fetching events. API came back with status code '\((response as? HTTPURLResponse)?.statusCode ?? -1)'.")
                
                return
            }
            
            self.decodeJson(with: data)
        } catch {
            print(error)
        }
    }
    
    private func decodeJson(with data: Data) {
        self.data = []
        
        do {
            let json: [[String: Any]] = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            
            for event in json {
                let title = event["title"] as! String
                let description = event["description"] as? String
                let start_time = event["start_time"] as! String
                let end_time = event["end_time"] as! String
                
                self.data.append(EventData(title: title, description: description, start_time: start_time, end_time: end_time))
            }
        } catch {
            print("Failed to decode json object: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
