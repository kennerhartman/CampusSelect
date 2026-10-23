//
//  BackendService.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/20/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation
import SwiftData

final class BackendService {
    static let shared: BackendService = BackendService()
    
    private init() {}
    
    func fetchEvents(with profile: UserProfile) async -> [EventData] {
        guard let json = self.buildPayload(with: profile) else { return [] }
        
        var request: URLRequest = URLRequest(url: URL(string: "http://10.106.10.72:8000/api/fetch-events")!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = json
        
        do {
            let (bytes, response) = try await URLSession.shared.bytes(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error fetching events. API came back with status code '\((response as? HTTPURLResponse)?.statusCode ?? -1)'.")
                
                return []
            }
            
            for try await line in bytes.lines {
                print(line)
                
                if line.hasPrefix("data:") {
                    let jsonString = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                    
                    guard let json: Data = jsonString.data(using: .utf8) else { continue }
                    
                    if let events = self.decodeStreamResponse(with: json) {
                        return events
                    }
                }
            }
        } catch {
            print(error)
        }
        
        return []
    }
    
    private func buildPayload(with profile: UserProfile) -> Data? {
        guard let calendarRawJson = EventKitService.shared.convertEKEventsToEventData().asJsonString()?.data(using: .utf8),
              let profileRawJson = profile.asJsonString()?.data(using: .utf8) else { return nil }
        
        guard let calendarJson = try? JSONSerialization.jsonObject(with: calendarRawJson, options: []) as? [String: Any],
              let profileJson = try? JSONSerialization.jsonObject(with: profileRawJson, options: []) as? [String: Any] else { return nil }
        
        let root: [String: Any] = [
            "calendar": calendarJson,
            "profile": profileJson
        ]
        
        return try? JSONSerialization.data(withJSONObject: root)
    }
    
    private func decodeStreamResponse(with data: Data) -> [EventData]? {
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
