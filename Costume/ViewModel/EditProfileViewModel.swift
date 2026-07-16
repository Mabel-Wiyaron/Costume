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
    
    // MARK: - Experience

    var isExperienceModalPresented: Bool = false
    var experienceBeingEdited: Experience? = nil

    func startAddingExperience() {
        experienceBeingEdited = nil
        isExperienceModalPresented = true
    }

    func startEditingExperience(_ experience: Experience) {
        experienceBeingEdited = experience
        isExperienceModalPresented = true
    }

    func cancelExperienceEdit() {
        isExperienceModalPresented = false
        experienceBeingEdited = nil
    }

    func saveExperience(
        role: String,
        employmentType: EmploymentType,
        company: String,
        location: String,
        startDate: Date,
        endDate: Date?,
        descriptionText: [String]
    ) {
        if let experience = experienceBeingEdited {
            experience.role = role
            experience.employmentType = employmentType
            experience.company = company
            experience.location = location
            experience.startDate = startDate
            experience.endDate = endDate
            experience.descriptionText = descriptionText
        } else {
            let newExperience = Experience(
                role: role,
                employmentType: employmentType,
                company: company,
                location: location,
                startDate: startDate,
                endDate: endDate,
                descriptionText: descriptionText
            )
            profile.experiences.append(newExperience)
        }
        Save()
        isExperienceModalPresented = false
        experienceBeingEdited = nil
    }

    func deleteExperience(_ experience: Experience) {
        profile.experiences.removeAll { $0 === experience }
        Save()
    }

    // MARK: - Project

    var isProjectModalPresented: Bool = false
    var projectBeingEdited: Project? = nil

    func startAddingProject() {
        projectBeingEdited = nil
        isProjectModalPresented = true
    }

    func startEditingProject(_ project: Project) {
        projectBeingEdited = project
        isProjectModalPresented = true
    }

    func cancelProjectEdit() {
        isProjectModalPresented = false
        projectBeingEdited = nil
    }

    func saveProject(
        name: String,
        role: String,
        startDate: Date,
        endDate: Date?,
        website: String,
        descriptionText: [String]
    ) {
        let websiteURL = website.isEmpty ? nil : URL(string: website)
        if let project = projectBeingEdited {
            project.name = name
            project.role = role
            project.startDate = startDate
            project.endDate = endDate
            project.website = websiteURL
            project.descriptionText = descriptionText
        } else {
            let newProject = Project(
                role: role,
                name: name,
                startDate: startDate,
                endDate: endDate,
                website: websiteURL,
                descriptionText: descriptionText
            )
            profile.projects.append(newProject)
        }
        Save()
        isProjectModalPresented = false
        projectBeingEdited = nil
    }

    func deleteProject(_ project: Project) {
        profile.projects.removeAll { $0 === project }
        Save()
    }

    // MARK: - Certification

    var isCertificationModalPresented: Bool = false
    var certificationBeingEdited: Certification? = nil

    func startAddingCertification() {
        certificationBeingEdited = nil
        isCertificationModalPresented = true
    }

    func startEditingCertification(_ certification: Certification) {
        certificationBeingEdited = certification
        isCertificationModalPresented = true
    }

    func cancelCertificationEdit() {
        isCertificationModalPresented = false
        certificationBeingEdited = nil
    }

    func saveCertification(
        name: String,
        issuer: String,
        issueDate: Date,
        expirationDate: Date?,
        credentialID: String,
        credentialURL: String
    ) {
        let credentialURLValue = credentialURL.isEmpty ? nil : URL(string: credentialURL)
        if let certification = certificationBeingEdited {
            certification.name = name
            certification.issuer = issuer
            certification.issueDate = issueDate
            certification.expirationDate = expirationDate
            certification.credentialID = credentialID
            certification.credentialURL = credentialURLValue
        } else {
            let newCertification = Certification(
                name: name,
                issuer: issuer,
                issueDate: issueDate,
                expirationDate: expirationDate,
                credentialID: credentialID,
                credentialURL: credentialURLValue
            )
            profile.certifications.append(newCertification)
        }
        Save()
        isCertificationModalPresented = false
        certificationBeingEdited = nil
    }

    func deleteCertification(_ certification: Certification) {
        profile.certifications.removeAll { $0 === certification }
        Save()
    }

    // MARK: - Award

    var isAwardModalPresented: Bool = false
    var awardBeingEdited: Award? = nil

    func startAddingAward() {
        awardBeingEdited = nil
        isAwardModalPresented = true
    }

    func startEditingAward(_ award: Award) {
        awardBeingEdited = award
        isAwardModalPresented = true
    }

    func cancelAwardEdit() {
        isAwardModalPresented = false
        awardBeingEdited = nil
    }

    func saveAward(
        title: String,
        issuer: String,
        issueDate: Date
    ) {
        if let award = awardBeingEdited {
            award.title = title
            award.issuer = issuer
            award.issueDate = issueDate
        } else {
            let newAward = Award(
                title: title,
                issuer: issuer,
                issueDate: issueDate
            )
            profile.awards.append(newAward)
        }
        Save()
        isAwardModalPresented = false
        awardBeingEdited = nil
    }

    func deleteAward(_ award: Award) {
        profile.awards.removeAll { $0 === award }
        Save()
    }
}
