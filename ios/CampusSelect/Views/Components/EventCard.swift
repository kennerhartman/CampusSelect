//
//  EventCard.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/17/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import SwiftData
import EventKitUI

struct EventCard: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var isPresentingAddEventView: Bool = false
    
    var event: EventData
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            self.calendarIcon(from: self.event.startTime)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(self.event.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                if let description = self.event.eventDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .padding(.bottom, 2)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    
                    Text(self.event.startTime, format: .dateTime.weekday(.abbreviated).day().hour(.defaultDigits(amPM: .omitted)).minute().month(.abbreviated))
                    
                    Text("-")
                    
                    Text(self.event.endTime, format: .dateTime.hour().minute())
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 0)
            
            VStack(spacing: 12) {
                Button(action: {
                    self.isPresentingAddEventView.toggle()
                }) {
                    Image(systemName: "plus")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(.blue, in: Circle())
                }
                .glassEffect(.regular.interactive())
                
                Button(action: {
                    self.modelContext.delete(self.event)
                }) {
                    Image(systemName: "xmark")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.red)
                        .frame(width: 32, height: 32)
                        .background(Color(.systemRed), in: Circle())
                }
                .glassEffect(.regular.interactive())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .sheet(isPresented: self.$isPresentingAddEventView) {
            if let ekEvent = EventKitService.shared.convertToEKEvent(using: self.event) {
                NavigationStack {
                    AddEventView(
                        eventStore: EventKitService.shared.getStore(),
                        event: ekEvent
                    ) { action in
                        if action == .saved {
                            self.modelContext.delete(self.event)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func calendarIcon(from date: Date) -> some View {
        let day = Calendar.current.component(.day, from: date)
        
        VStack(spacing: 2) {
            Text(date, format: .dateTime.month(.abbreviated)).textCase(.uppercase)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.red)
            
            Text("\(day)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .frame(width: 48, height: 50)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            EventCard(
                event: EventData(
                    title: "Home Evening Laser Tag",
                    eventDescription: "High-intensity outdoor laser tag games hosted behind the Manwaring Center.",
                    startTime: Date.parseDate(for: "2026-10-19T19:00:00Z") ?? .now,
                    endTime: Date.parseDate(for: "2026-10-19T22:00:00Z") ?? .now
                )
            )
            
            EventCard(
                event: EventData(
                    title: "Data Science Society",
                    eventDescription: "Use data analysis, Python, and machine learning to solve real problems across campus infrastructure matrices.",
                    startTime: Date.parseDate(for: "2026-10-21T18:00:00Z") ?? .now,
                    endTime: Date.parseDate(for: "2026-10-21T19:00:00Z") ?? .now
                )
            )
        }
        .padding()
    }
}
