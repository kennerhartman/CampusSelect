//
//  ContentView.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/17/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import SwiftData

struct EventData: Identifiable {
    var title: String
    var id: UUID = UUID()
    var description: String?
    var start_time: String
    var end_time: String
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var fetching: Bool = false
    @State private var data: [EventData] = []
    
    var body: some View {
        NavigationStack {
            Button {
                Task {
                    await self.greetLLM()
                }
            } label: {
                Text("Say Hello!")
            }
            
            if self.fetching {
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
    }
    
    private func greetLLM() async {
        let useMockData = true
        
        if useMockData {
            let rawJson = """
            [{"title":"Roller Skating - 2026","description":null,"start_time":"2026-10-19T18:30:00Z","end_time":"2026-10-19T20:00:00Z"},{"title":"Home Evening - 2026","description":null,"start_time":"2026-10-19T19:00:00Z","end_time":"2026-10-19T21:00:00Z"},{"title":"Home Evening Laser Tag","description":null,"start_time":"2026-10-19T19:00:00Z","end_time":"2026-10-19T22:00:00Z"},{"title":"Roller Skating - 2026","description":null,"start_time":"2026-10-19T20:30:00Z","end_time":"2026-10-19T22:00:00Z"},{"title":"Hackathon","description":"Build projects quickly and creatively in time-boxed coding challenges.","start_time":"2026-10-20T16:00:00Z","end_time":"2026-10-20T17:00:00Z"},{"title":"UAS/Drone Society","description":"Hands-on drone building, programming, and flight control systems.","start_time":"2026-10-20T16:30:00Z","end_time":"2026-10-20T17:30:00Z"},{"title":"IEEE Student Branch Society","description":"Connect with global engineering professionals and stay on the tech edge.","start_time":"2026-10-20T17:30:00Z","end_time":"2026-10-20T18:30:00Z"},{"title":"Formula Hybrid Electric Team","description":"Design and build electric hybrid racecars for national competitions.","start_time":"2026-10-20T18:00:00Z","end_time":"2026-10-20T19:00:00Z"},{"title":"Speed Dating","description":null,"start_time":"2026-10-20T19:00:00Z","end_time":"2026-10-20T21:00:00Z"},{"title":"Open Mic","description":null,"start_time":"2026-10-20T19:00:00Z","end_time":"2026-10-20T22:00:00Z"},{"title":"Latin Dance","description":null,"start_time":"2026-10-20T20:00:00Z","end_time":"2026-10-20T23:00:00Z"},{"title":"Computing Society","description":"All societies and teams meet together to socialize, enjoy tech presentations, and receive updates before breakout interest groups.","start_time":"2026-10-21T17:00:00Z","end_time":"2026-10-21T18:00:00Z"},{"title":"Amateur Radio Society","description":"Explore the world of radio communication, licensing, and RF systems.","start_time":"2026-10-21T17:30:00Z","end_time":"2026-10-21T18:30:00Z"},{"title":"Society of Women Engineers","description":"Support and empower women in engineering through networking and mentoring.","start_time":"2026-10-21T17:30:00Z","end_time":"2026-10-21T18:30:00Z"},{"title":"Society of Cybersecurity","description":"Learn ethical hacking, penetration testing, and digital defense skills.","start_time":"2026-10-21T17:30:00Z","end_time":"2026-10-21T18:30:00Z"},{"title":"Web Society","description":"Frontend, backend, and full-stack web development for all skill levels.","start_time":"2026-10-21T17:30:00Z","end_time":"2026-10-21T18:30:00Z"},{"title":"AI Society","description":"Explore machine learning, data models, and the future of AI tech.","start_time":"2026-10-21T17:30:00Z","end_time":"2026-10-21T18:30:00Z"},{"title":"Video Game Design","description":"Learn game engines, art, and coding while building your own games.","start_time":"2026-10-21T17:30:00Z","end_time":"2026-10-21T18:30:00Z"},{"title":"Data Science","description":"Use data analysis, Python, and machine learning to solve real problems.","start_time":"2026-10-21T18:00:00Z","end_time":"2026-10-21T19:00:00Z"},{"title":"Country Dancing","description":null,"start_time":"2026-10-21T19:00:00Z","end_time":"2026-10-21T23:00:00Z"},{"title":"Cloud Solutions","description":"Hands-on with AWS, Azure, and GCP to learn cloud architecture and scaling.","start_time":"2026-10-22T17:00:00Z","end_time":"2026-10-22T18:00:00Z"},{"title":"Linux and Open Source","description":"Dive into Linux, shell scripting, and contributing to open-source tools.","start_time":"2026-10-22T17:30:00Z","end_time":"2026-10-22T18:30:00Z"},{"title":"AI Society","description":"Explore machine learning, data models, and the future of AI tech.","start_time":"2026-10-22T17:30:00Z","end_time":"2026-10-22T18:30:00Z"},{"title":"Formula Hybrid Electric Team","description":"Design and build electric hybrid racecars for national competitions.","start_time":"2026-10-22T18:00:00Z","end_time":"2026-10-22T19:00:00Z"},{"title":"Game Night - Dungeons and Dragons","description":null,"start_time":"2026-10-22T18:00:00Z","end_time":"2026-10-22T22:00:00Z"},{"title":"Game Night","description":null,"start_time":"2026-10-22T19:00:00Z","end_time":"2026-10-22T22:00:00Z"},{"title":"Roller Skating - 2026","description":null,"start_time":"2026-10-22T20:30:00Z","end_time":"2026-10-22T22:00:00Z"},{"title":"Video Game Design","description":"Learn game engines, art, and coding while building your own games.","start_time":"2026-10-23T17:30:00Z","end_time":"2026-10-23T18:30:00Z"},{"title":"Mini Dates","description":null,"start_time":"2026-10-23T19:00:00Z","end_time":"2026-10-23T21:30:00Z"},{"title":"Laser Tag","description":null,"start_time":"2026-10-23T20:00:00Z","end_time":"2026-10-23T23:00:00Z"},{"title":"Roller Skating - 2026","description":null,"start_time":"2026-10-24T18:30:00Z","end_time":"2026-10-24T20:00:00Z"},{"title":"Roller Skating - 2026","description":null,"start_time":"2026-10-24T20:30:00Z","end_time":"2026-10-24T22:00:00Z"},{"title":"Stadium Singing - Spanish","description":null,"start_time":"2026-10-25T20:00:00Z","end_time":"2026-10-25T20:30:00Z"},{"title":"Stadium Singing - English","description":null,"start_time":"2026-10-25T20:45:00Z","end_time":"2026-10-25T21:15:00Z"},{"title":"Roller Skating - 2026","description":null,"start_time":"2026-10-26T18:30:00Z","end_time":"2026-10-26T20:00:00Z"},{"title":"Home Evening - 2026","description":null,"start_time":"2026-10-26T19:00:00Z","end_time":"2026-10-26T21:00:00Z"},{"title":"Home Evening Laser Tag","description":null,"start_time":"2026-10-26T19:00:00Z","end_time":"2026-10-26T22:00:00Z"},{"title":"Roller Skating - 2026","description":null,"start_time":"2026-10-26T20:30:00Z","end_time":"2026-10-26T22:00:00Z"}]
            """
            
            self.decodeJson(with: rawJson.data(using: .utf8)!)
            
            return
        }
        
        var request: URLRequest = URLRequest(url: URL(string: "http://10.106.10.72:8000/scrape")!)
        
        request.httpMethod = "GET"
        
        self.fetching = true
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error fetching scraped processed by Gemini: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            }
            
            self.decodeJson(with: data)
            
            self.fetching = false
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
}
