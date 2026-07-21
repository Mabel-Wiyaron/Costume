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
    case jobDescriptionAnalysis
    case resumePreview

    var id: String { rawValue }

    var title: String {
        switch self {
        case .jobDescriptionAnalysis: return "Job Description Analysis"
        case .resumePreview: return "Resumé Preview"
        }
    }
}

@Observable
final class EditCVViewModel {
    var document: CVDocument
    var jobDescription: JobDescription?
    var selectedRightTab: CVAnalysisTab = .jobDescriptionAnalysis

    private let modelContext: ModelContext?

    init(document: CVDocument, jobDescription: JobDescription? = nil, modelContext: ModelContext? = nil) {
        self.document = document
        self.jobDescription = jobDescription
        self.modelContext = modelContext
    }

    func save() {
        try? modelContext?.save()
    }

    // MARK: - Experience
    func addExperience() {
        document.experiences.append(
            Experience(role: "", employmentType: .fullTime, company: "", location: "", startDate: Date())
        )
    }
    func deleteExperience(_ experience: Experience) {
        document.experiences.removeAll { $0 === experience }
    }

    // MARK: - Education
    func addEducation() {
        document.educations.append(
            Education(school: "", degree: "", fieldOfStudy: "", startDate: Date())
        )
    }
    func deleteEducation(_ education: Education) {
        document.educations.removeAll { $0 === education }
    }

    // MARK: - Project
    func addProject() {
        document.projects.append(Project(role: "", name: "", startDate: Date()))
    }
    func deleteProject(_ project: Project) {
        document.projects.removeAll { $0 === project }
    }

    // MARK: - Certification
    func addCertification() {
        document.certifications.append(
            Certification(name: "", issuer: "", issueDate: Date(), credentialID: "")
        )
    }
    func deleteCertification(_ certification: Certification) {
        document.certifications.removeAll { $0 === certification }
    }

    // MARK: - Award
    func addAward() {
        document.awards.append(Award(title: "", issuer: "", issueDate: Date()))
    }
    func deleteAward(_ award: Award) {
        document.awards.removeAll { $0 === award }
    }

    // MARK: - Keyword Matching

    func updateKeywordStatus() {
        guard let keywords = jobDescription?.keywords, !keywords.isEmpty else { return }
        KeywordMatcher.updateStatus(for: keywords, using: document.profile)
    }
}
