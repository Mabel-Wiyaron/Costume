//
//  CVParsingAgentService.swift
//  Costume
//
//  Created by William Constantine Jioe on 24/07/26.
//
import Foundation
import FoundationModels

// Prompt designed using the CO-STAR framework:
// - Context: a job seeker importing their CV/resume text into the application
// - Objective: extract structured candidate details, experiences, educations, and skills
// - Style/Tone: factual, direct, extraction-only — no fabrication, no commentary
// - Audience: consumed as data by the app, not read as prose by a person
// - Response format: enforced by the @Generable schema below

let CV_PARSING_INSTRUCTIONS_V1 = """
    Extract structured candidate profile information from raw CV text.
    Never invent or assume details that are not present in the input text.
    Extract experience responsibilities as distinct action-oriented bullet points.
    Ensure URLs, dates, and contact details are accurately captured.
    Be terse and factual — you are producing structured data for the application.
    """

// MARK: - Generable Schemas

@Generable(description: "CV details")
struct CVImportGenerable: Codable {
    @Guide(description: "Full name")
    let name: String
    
    @Guide(description: "Email")
    let email: String
    
    @Guide(description: "Phone")
    let phone: String
    
    @Guide(description: "City, Country")
    let location: String
    
    @Guide(description: "LinkedIn URL")
    let linkedin: String?
    
    @Guide(description: "Portfolio URL")
    let website: String?
    
    @Guide(description: "Summary")
    let summary: String?
    
    @Guide(description: "Work history")
    let experiences: [CVExperienceGenerable]
    
    @Guide(description: "Education")
    let educations: [CVEducationGenerable]
    
    @Guide(description: "Projects")
    let projects: [CVProjectGenerable]
    
    @Guide(description: "Certifications")
    let certifications: [CVCertificationGenerable]
    
    @Guide(description: "Awards")
    let awards: [CVAwardGenerable]
    
    @Guide(description: "Skills")
    let skills: [String]
    
    @Guide(description: "Languages")
    let languages: [CVLanguageGenerable]
}

// Change descriptionText in sub-generables from [String] to String
@Generable(description: "Work experience")
struct CVExperienceGenerable: Codable {
    @Guide(description: "Job title")
    let role: String
    
    @Guide(description: "Company")
    let company: String
    
    @Guide(description: "Location")
    let location: String?
    
    @Guide(description: "Full-time, Part-time, Contract, Internship")
    let employmentType: String?
    
    // Changing from [String] to String cuts schema structure overhead
    @Guide(description: "Bullet points separated by newline")
    let descriptionText: String?
    
    @Guide(description: "YYYY-MM")
    let startDate: String?
    
    @Guide(description: "YYYY-MM or null")
    let endDate: String?
}

@Generable(description: "Education entry")
struct CVEducationGenerable: Codable {
    @Guide(description: "Institution or university name")
    let school: String
    
    @Guide(description: "Degree earned")
    let degree: String
    
    @Guide(description: "Field or major of study")
    let fieldOfStudy: String?
    
    @Guide(description: "Start year")
    let startDate: String?
    
    @Guide(description: "End date or null")
    let endDate: String?
}

@Generable(description: "Project entry")
struct CVProjectGenerable: Codable {
    @Guide(description: "role in the project")
    let role: String?
    
    @Guide(description: "Project title")
    let name: String
    
    @Guide(description: "Key details, metrics, and achievements as separate bullet points")
    let descriptionText: [String]
    
    @Guide(description: "Start date")
    let startDate: String?
    
    @Guide(description: "End date")
    let endDate: String?
}

@Generable(description: "Certification entry")
struct CVCertificationGenerable: Codable {
    @Guide(description: "Certification name")
    let name: String
    
    @Guide(description: "Issuing organization")
    let issuer: String
    
    @Guide(description: "Credential or license ID string")
    let credentialID: String?
    
    @Guide(description: "Issue date (e.g., 'YYYY-MM')")
    let issueDate: String?
}

@Generable(description: "Award entry")
struct CVAwardGenerable: Codable {
    @Guide(description: "Award title")
    let title: String
    
    @Guide(description: "Issuer or conferring organization")
    let issuer: String
    
    @Guide(description: "Issue date")
    let issueDate: String?
}

@Generable(description: "Language skill entry")
struct CVLanguageGenerable: Codable {
    @Guide(description: "Language name")
    let name: String
    
    @Guide(description: "Proficiency level (e.g., Native, Fluent, Intermediate, Basic)")
    let proficiency: String?
}

// MARK: - Errors & Service

enum CVParsingAgentError: Error {
    case cvTextTooLong
}

struct CVParsingAgentService: AgentProtocol {
    var languageModel: LanguageModelProtocol

    init(languageModel: LanguageModelProtocol = AppleIntelligenceService()) {
        self.languageModel = languageModel
        self.languageModel.instructions = CV_PARSING_INSTRUCTIONS_V1
    }
    
    func invoke(for message: String) async throws -> CVImportGenerable {
        do {
            return try await languageModel.generate(
                content: CVImportGenerable.self,
                for: message
            )
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            throw CVParsingAgentError.cvTextTooLong
        }
    }
}
