//
//  EditProfileSheetView.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/20/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import SwiftData

struct EditProfileSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var model = UserDetailsViewModel()
    
    var body: some View {
        NavigationStack {
            UserProfileFormView(model: self.model)
                .navigationTitle("Edit Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            self.model.saveUserProfile(using: self.modelContext)
                            
                            dismiss()
                        }
                        .bold()
                        .disabled(!self.model.canSubmit)
                    }
                }
                .onAppear {
                    self.model.loadUserProfile(using: self.modelContext)
                }
        }
    }
}

#Preview {
    EditProfileSheetView()
}
