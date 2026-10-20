//
//  SplashView.swift
//  ArticleScanner
//
//  Created by Kenner Hartman on 10/20/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import SwiftData

struct SplashView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to Campus Select")
                    .font(.title)
                    .bold()
                
                Text("Sync your life, skip the conflicts, and never miss a campus event.")
                    .font(.headline)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                
                NavigationLink(destination: UserDetailsView()) {
                    HStack {
                        HStack {
                            Text("Get Started")
                            
                            Image(systemName: "chevron.right.circle")
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
    }
}

struct UserDetailsView: View {
    @AppStorage("isSetupComplete") private var isSetupComplete: Bool = false
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var model: UserDetailsViewModel = UserDetailsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            UserProfileFormView(model: self.model)
            
            VStack {
                Button(role: .confirm) {
                    self.model.saveUserProfile(using: self.modelContext)
                    self.isSetupComplete = true
                    
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!self.model.canSubmit)
                .glassEffect(.regular.tint(self.model.canSubmit ? .blue : .gray).interactive())
                .padding()
            }
            .background(.background)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SplashView()
}
