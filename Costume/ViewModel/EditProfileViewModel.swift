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
    
    var isExperienceModalPresented: Bool = false
    var experienceBeingEdited: Experience? = nil
    
    var isProjectModalPresented: Bool = false
    var projectBeingEdited: Project? = nil
    
    var isCertificationModalPresented: Bool = false
    var certificationBeingEdited: Certification? = nil
    
    var isAwardModalPresented: Bool = false
    var awardBeingEdited: Award? = nil

    // Made internal to the module since SwiftData actions require a solid model context instance
    private let modelContext: ModelContext

    // Pass the View's modelContext here using (.modelContext environment wrapper)
    init(profile: Profile, modelContext: ModelContext) {
        self.profile = profile
        self.modelContext = modelContext
    }

    var isSaveEnabled: Bool {
        !profile.name.isEmpty && !profile.phone.isEmpty && !profile.email.isEmpty
    }

    func save() {
        try? modelContext.save()
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
            // SwiftData automatically establishes context tracking when inserted or appended to an existing model
            profile.educations.append(newEducation)
        }
        save()
        isEducationModalPresented = false
        educationBeingEdited = nil
    }

    func deleteEducation(_ education: Education) {
        // 1. Remove relationship reference link from array
        profile.educations.removeAll { $0.id == education.id }
        // 2. Explicitly wipe object row from SQLite store
        modelContext.delete(education)
        save()
    }
    
    // MARK: - Experience

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
        employmentType: EmploymentType, // Updated type mapping matching your enum location
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
        save()
        isExperienceModalPresented = false
        experienceBeingEdited = nil
    }

    func deleteExperience(_ experience: Experience) {
        profile.experiences.removeAll { $0.id == experience.id }
        modelContext.delete(experience)
        save()
    }

    // MARK: - Project

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
        save()
        isProjectModalPresented = false
        projectBeingEdited = nil
    }

    func deleteProject(_ project: Project) {
        profile.projects.removeAll { $0.id == project.id }
        modelContext.delete(project)
        save()
    }

    // MARK: - Certification

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
        save()
        isCertificationModalPresented = false
        certificationBeingEdited = nil
    }

    func deleteCertification(_ certification: Certification) {
        profile.certifications.removeAll { $0.id == certification.id }
        modelContext.delete(certification)
        save()
    }

    // MARK: - Award

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
            modelContext.insert(newAward)
            profile.awards.append(newAward)
        }
        save()
        isAwardModalPresented = false
        awardBeingEdited = nil
    }

    func deleteAward(_ award: Award) {
        profile.awards.removeAll { $0.id == award.id }
        modelContext.delete(award)
        save()
    }
}
