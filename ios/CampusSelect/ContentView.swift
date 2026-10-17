//
//  ContentView.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/17/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var response: String? = nil
    
    var body: some View {
        NavigationStack {
            Button {
                Task {
                    await self.greetLLM()
                }
            } label: {
                Text("Say Hello!")
            }
            
            if let response = self.response {
                Text("The LLM says, '\(response)'")
            }
        }
    }
    
    private func greetLLM() async {
        var request: URLRequest = URLRequest(url: URL(string: "http://localhost:8000/greet")!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let rawJson = """
        {
            "message": "The world says hello!"
        }
        """
        
        if let json = rawJson.data(using: .utf8) {
            request.httpBody = json
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            let json: [String: Any] = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            
            if let jsonData = json["data"] as? [String: Any] {
                let message = jsonData["message"] as? String
                
                if let message = message {
                    self.response = message
                }
            }
        } catch {
            print(error)
        }
    }
}

#Preview {
    ContentView()
}
