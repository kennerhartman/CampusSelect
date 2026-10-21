//
//  BackendService.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/20/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation

final class BackendService {
    static let shared: BackendService = BackendService()
    
    private init() {}
    
    func fetchEvents() async -> [EventData] {
        var request: URLRequest = URLRequest(url: URL(string: "http://10.106.10.72:8000/api/fetch-events")!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let calendarRawJson = EventKitService.shared.asJsonString()
        
        if let json = calendarRawJson?.data(using: .utf8) {
            request.httpBody = json
        }
        
        do {
            let (bytes, response) = try await URLSession.shared.bytes(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error fetching events. API came back with status code '\((response as? HTTPURLResponse)?.statusCode ?? -1)'.")
                
                return []
            }
            
            for try await line in bytes.lines {
                if line.hasPrefix("data:") {
                    let jsonString = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                    
                    guard let json: Data = jsonString.data(using: .utf8) else { continue }
                    
                    if let events = self.parsePayloadEvent(with: json) {
                        return events
                    }
                }
            }
        } catch {
            print(error)
        }
        
        return []
    }
    
    private func parsePayloadEvent(with data: Data) -> [EventData]? {
        if let payload = try? JSONDecoder().decode(BackendStreamResponse.self, from: data) {
            if payload.event_type == .complete {
                return payload.events ?? []
            }
        } else {
            print("Failed to decode response from server.")
        }
        
        return nil
    }
}
