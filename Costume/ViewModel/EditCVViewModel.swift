//
//  CVAnalysisTab.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

import Foundation
import SwiftData
import Observation

enum CVAnalysisTab: String, CaseIterable, Identifiable {
    case resumePreview
    case jobDescriptionAnalysis

    var id: String { rawValue }

    var title: String {
        switch self {
        case .resumePreview: return "Resumé Preview"
        case .jobDescriptionAnalysis: return "Job Description Analysis"
        }
    }
}

@Observable
final class EditCVViewModel {
    var document: CVDocument
    var jobDescription: JobDescription?
    var selectedRightTab: CVAnalysisTab = .resumePreview

    private let modelContext: ModelContext?
    private var lastSavedSnapshot: EditCVSnapshot?

    init(document: CVDocument, jobDescription: JobDescription? = nil, modelContext: ModelContext? = nil) {
        self.document = document
        self.jobDescription = jobDescription
        self.modelContext = modelContext
        sortEntries()
        self.lastSavedSnapshot = EditCVSnapshot(from: document.profile)
        startLiveMatching()
    }

    func save() {
        try? modelContext?.save()
        sortEntries()
        lastSavedSnapshot = EditCVSnapshot(from: document.profile)
    }

    // MARK: - Ordering

    private func sortEntries() {
        document.experiences.sort { $0.startDate > $1.startDate }
        document.educations.sort { $0.startDate > $1.startDate }
        document.projects.sort { $0.startDate > $1.startDate }
        document.certifications.sort { $0.issueDate > $1.issueDate }
        document.awards.sort { $0.issueDate > $1.issueDate }
        document.skills.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    // MARK: - Save Validation

    var isNameValid: Bool {
        !document.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isEmailValid: Bool {
        let email = document.email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty else { return false }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    var isPhoneValid: Bool {
        let phone = document.phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phone.isEmpty else { return false }
        let phoneRegex = "^[+]*[0-9]{9,15}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phone)
    }

    var isExperienceListValid: Bool {
        document.experiences.allSatisfy {
            !$0.role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !$0.company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !$0.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var isEducationListValid: Bool {
        document.educations.allSatisfy {
            !$0.school.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !$0.degree.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !$0.fieldOfStudy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var isProjectListValid: Bool {
        document.projects.allSatisfy {
            !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !$0.role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var isCertificationListValid: Bool {
        document.certifications.allSatisfy {
            !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !$0.issuer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !$0.credentialID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var isAwardListValid: Bool {
        document.awards.allSatisfy {
            !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !$0.issuer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var hasUnsavedChanges: Bool {
        EditCVSnapshot(from: document.profile) != lastSavedSnapshot
    }

    var isSaveEnabled: Bool {
        hasUnsavedChanges &&
        isNameValid && isEmailValid && isPhoneValid &&
        isExperienceListValid && isEducationListValid && isProjectListValid &&
        isCertificationListValid && isAwardListValid
    }

    // MARK: - Experience
    func addExperience() {
        document.experiences.insert(
            Experience(role: "", employmentType: .fullTime, company: "", location: "", startDate: Date()), at: 0
        )
    }
    func deleteExperience(_ experience: Experience) {
        document.experiences.removeAll { $0 === experience }
    }

    // MARK: - Education
    func addEducation() {
        document.educations.insert(
            Education(school: "", degree: "", fieldOfStudy: "", startDate: Date()), at: 0
        )
    }
    func deleteEducation(_ education: Education) {
        document.educations.removeAll { $0 === education }
    }

    // MARK: - Project
    func addProject() {
        document.projects.insert(
            Project(role: "", name: "", startDate: Date()), at: 0
        )
    }
    func deleteProject(_ project: Project) {
        document.projects.removeAll { $0 === project }
    }

    // MARK: - Certification
    func addCertification() {
        document.certifications.insert(
            Certification(name: "", issuer: "", issueDate: Date(), credentialID: ""), at: 0
        )
    }
    func deleteCertification(_ certification: Certification) {
        document.certifications.removeAll { $0 === certification }
    }

    // MARK: - Award
    func addAward() {
        document.awards.insert(
            Award(title: "", issuer: "", issueDate: Date()), at: 0
        )
    }
    func deleteAward(_ award: Award) {
        document.awards.removeAll { $0 === award }
    }

    // MARK: - Keyword Matching

    func updateKeywordStatus() {
        guard let keywords = jobDescription?.keywords, !keywords.isEmpty else { return }
        KeywordMatcher.updateStatus(for: keywords, using: document.profile)
    }

    func startLiveMatching() {
        observeProfile(document.profile)
    }

    private func observeProfile(_ profile: Profile) {
        withObservationTracking {
            _ = profile.name
            _ = profile.email
            _ = profile.phone
            _ = profile.location
            _ = profile.linkedin
            _ = profile.website
            _ = profile.summary
            for link in profile.links {
                _ = link.platform
                _ = link.url
            }
            for exp in profile.experiences {
                _ = exp.role
                _ = exp.company
                _ = exp.location
                _ = exp.employmentType
                _ = exp.descriptionText
            }
            for edu in profile.educations {
                _ = edu.school
                _ = edu.degree
                _ = edu.fieldOfStudy
            }
            for cert in profile.certifications {
                _ = cert.name
                _ = cert.issuer
                _ = cert.credentialID
            }
            for project in profile.projects {
                _ = project.role
                _ = project.name
                _ = project.descriptionText
            }
            for award in profile.awards {
                _ = award.title
                _ = award.issuer
            }
            for skill in profile.skills {
                _ = skill.name
            }
            for lang in profile.languages {
                _ = lang.name
                _ = lang.proficiency
            }
        } onChange: { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                self.updateKeywordStatus()
                self.observeProfile(profile)
            }
        }
    }
}

// --- PEMBANTU SNAPSHOT DATA UNTUK STATUS SIMPAN ---
fileprivate struct EditCVSnapshot: Equatable {
    struct ExperienceSnapshot: Equatable {
        let role: String
        let employmentType: EmploymentType
        let company: String
        let location: String
        let startDate: Date
        let endDate: Date?
        let descriptionText: [String]
    }
    struct EducationSnapshot: Equatable {
        let school: String
        let degree: String
        let fieldOfStudy: String
        let startDate: Date
        let endDate: Date?
        let grade: String?
    }
    struct ProjectSnapshot: Equatable {
        let role: String
        let name: String
        let startDate: Date
        let endDate: Date?
        let website: URL?
        let descriptionText: [String]
    }
    struct CertificationSnapshot: Equatable {
        let name: String
        let issuer: String
        let issueDate: Date
        let expirationDate: Date?
        let credentialID: String
        let credentialURL: URL?
    }
    struct AwardSnapshot: Equatable {
        let title: String
        let issuer: String
        let issueDate: Date
    }
    struct LinkSnapshot: Equatable {
        let platform: LinkPlatform
        let url: URL
    }

    let name: String
    let email: String
    let phone: String
    let location: String
    let linkedin: URL?
    let website: URL?
    let summary: String?
    let links: [LinkSnapshot]
    let skillNames: [String]
    let experiences: [ExperienceSnapshot]
    let educations: [EducationSnapshot]
    let projects: [ProjectSnapshot]
    let certifications: [CertificationSnapshot]
    let awards: [AwardSnapshot]

    init(from profile: Profile) {
        name = profile.name
        email = profile.email
        phone = profile.phone
        location = profile.location
        linkedin = profile.linkedin
        website = profile.website
        summary = profile.summary
        links = profile.links.map { LinkSnapshot(platform: $0.platform, url: $0.url) }
        skillNames = profile.skills.map { $0.name }
        experiences = profile.experiences.map {
            ExperienceSnapshot(role: $0.role, employmentType: $0.employmentType, company: $0.company, location: $0.location, startDate: $0.startDate, endDate: $0.endDate, descriptionText: $0.descriptionText)
        }
        educations = profile.educations.map {
            EducationSnapshot(school: $0.school, degree: $0.degree, fieldOfStudy: $0.fieldOfStudy, startDate: $0.startDate, endDate: $0.endDate, grade: $0.grade)
        }
        projects = profile.projects.map {
            ProjectSnapshot(role: $0.role, name: $0.name, startDate: $0.startDate, endDate: $0.endDate, website: $0.website, descriptionText: $0.descriptionText)
        }
        certifications = profile.certifications.map {
            CertificationSnapshot(name: $0.name, issuer: $0.issuer, issueDate: $0.issueDate, expirationDate: $0.expirationDate, credentialID: $0.credentialID, credentialURL: $0.credentialURL)
        }
        awards = profile.awards.map {
            AwardSnapshot(title: $0.title, issuer: $0.issuer, issueDate: $0.issueDate)
        }
    }
}
