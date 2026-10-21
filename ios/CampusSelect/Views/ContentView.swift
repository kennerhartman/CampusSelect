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
                            self.isFetching = true
                            
                            defer {
                                self.isFetching = false
                            }
                            
                            self.data = await BackendService.shared.fetchEvents()
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
}



#Preview {
    ContentView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
