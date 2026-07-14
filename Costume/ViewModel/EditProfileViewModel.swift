// MARK: - EditProfileViewModel.swift

import Foundation
import Combine

final class EditProfileViewModel: ObservableObject {
    @Published var personalInfo: PersonalInfo
    @Published var selectedSection: ProfileSection? = .personalInfo

    init(personalInfo: PersonalInfo = PersonalInfo()) {
        self.personalInfo = personalInfo
    }

    var isSaveEnabled: Bool {
        !personalInfo.name.isEmpty && !personalInfo.contact.isEmpty && !personalInfo.email.isEmpty
    }

    func Save() {
        // TODO: persist personalInfo through the model/data layer once provided
    }
}