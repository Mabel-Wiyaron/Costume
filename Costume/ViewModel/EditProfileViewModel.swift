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

    var isEducationModalPresented: Bool = false
    var educationBeingEdited: Education? = nil

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

    // MARK: - Education

    func startAddingEducation() {
        educationBeingEdited = nil
        isEducationModalPresented = true
    }

    func startEditingEducation(_ education: Education) {
        educationBeingEdited = education
        isEducationModalPresented = true
    }

    func cancelEducationEdit() {
        isEducationModalPresented = false
        educationBeingEdited = nil
    }

    func saveEducation(
        school: String,
        degree: String,
        fieldOfStudy: String,
        grade: String?,
        startDate: Date,
        endDate: Date?
    ) {
        if let education = educationBeingEdited {
            education.school = school
            education.degree = degree
            education.fieldOfStudy = fieldOfStudy
            education.grade = grade
            education.startDate = startDate
            education.endDate = endDate
        } else {
            let newEducation = Education(
                school: school,
                degree: degree,
                fieldOfStudy: fieldOfStudy,
                startDate: startDate,
                endDate: endDate,
                grade: grade
            )
            profile.educations.append(newEducation)
        }
        Save()
        isEducationModalPresented = false
        educationBeingEdited = nil
    }

    func deleteEducation(_ education: Education) {
        profile.educations.removeAll { $0 === education }
        Save()
    }
}
