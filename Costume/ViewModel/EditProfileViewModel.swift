//
//  EditProfileViewModel.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import Foundation
import SwiftData
import Observation

@Observable
final class EditProfileViewModel {
    var profile: Profile
    var selectedSection: ProfileSection? = .personalInfo

    private let modelContext: ModelContext?

    init(profile: Profile, modelContext: ModelContext? = nil) {
        self.profile = profile
        self.modelContext = modelContext
    }

    var isSaveEnabled: Bool {
        !profile.name.isEmpty && !profile.phone.isEmpty && !profile.email.isEmpty
    }

    func Save() {
        try? modelContext?.save()
    }
}
