//
//  UserProfileFormView.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/20/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//


//
//  UserProfileFormView.swift
//  CampusSelect
//
//  Created by Kenner Hartman on 10/20/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import SwiftData

struct UserProfileFormView: View {
    @Bindable var model: UserDetailsViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Personal Details")) {
                TextField("Name", text: self.$model.name)
                    .textContentType(.givenName)
                
                Picker("Gender", selection: self.$model.gender) {
                    Text("Not Specified")
                        .tag(nil as Gender?)
                    
                    ForEach(Gender.allCases) { gender in
                        Text(gender.rawValue)
                            .tag(gender as Gender?)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Section(
                header: Text("About & Interests"),
                footer: Text("This context helps your local AI agent personalize event recommendations for your specific preferences.")
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Your major, hobbies, preferred times, or event likes/dislikes...", text: self.$model.about, axis: .vertical)
                        .lineLimit(4...8)
                }
                .padding(.vertical, 4)
            }
            
            Section {
                HStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Data Processing")
                            .font(.caption)
                            .bold()
                        
                        Text("Data is processed locally by your model instance, solely for personalized event curation.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listRowBackground(Color.clear)
        }
    }
}

@Observable
class UserDetailsViewModel {
    var name: String = ""
    var gender: Gender? = nil
    var about: String = ""
    
    var canSubmit: Bool {
        return !self.name.isEmpty && !self.about.isEmpty && self.gender != nil
    }
    
    func loadUserProfile(using context: ModelContext) {
        let profile = self.fetchProfile(using: context)
        
        if let profile = profile {
            self.name = profile.name
            self.gender = profile.gender
            self.about = profile.about
        }
    }
    
    func saveUserProfile(using context: ModelContext) {
        let profile = self.fetchProfile(using: context)
        
        if let profile = profile {
            profile.name = self.name
            profile.gender = self.gender!
            profile.about = self.about
        } else {
            let newProfile = UserProfile(name: self.name, about: self.about, gender: self.gender!)
            
            context.insert(newProfile)
        }
        
        try? context.save()
    }
    
    private func fetchProfile(using context: ModelContext) -> UserProfile? {
        do {
            var descriptor = FetchDescriptor<UserProfile>()
            descriptor.fetchLimit = 1
            
            return try context.fetch(descriptor).first
        } catch {
            print("Error saving user profile: \(error.localizedDescription)")
            
            return nil
        }
    }
}

#Preview {
    UserProfileFormView(model: UserDetailsViewModel())
}
