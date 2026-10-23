//
//  AddEventView.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/22/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import EventKit
import EventKitUI

struct AddEventView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    let eventStore: EKEventStore
    let event: EKEvent
    
    var onComplete: (EKEventEditViewAction) -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = EKEventEditViewController()
        
        controller.eventStore = self.eventStore
        controller.event = self.event
        controller.editViewDelegate = context.coordinator
        
        return controller
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, EKEventEditViewDelegate {
        var parent: AddEventView

        init(_ parent: AddEventView) {
            self.parent = parent
        }

        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            self.parent.onComplete(action)
            
            self.parent.dismiss()
        }
    }
}
