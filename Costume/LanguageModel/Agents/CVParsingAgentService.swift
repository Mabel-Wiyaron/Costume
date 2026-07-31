//
//  CVParsingAgentService.swift
//  Costume
//
//  Created by William Constantine Jioe on 24/07/26.
//
import Foundation
import FoundationModels

// Minimized instructions to reduce system token overhead
let CV_PARSING_INSTRUCTIONS_V1 = "Extract CV data strictly as JSON matching the schema. No markdown, no filler."

// MARK: - Generable Schemas (Optimized for Token Efficiency)

@Generable(description: "CV")
struct CVImportGenerable: Codable {
    let name: String
    let summary: String?
    let experiences: [CVExperienceGenerable]
    let educations: [CVEducationGenerable]
    let projects: [CVProjectGenerable]
    let certifications: [CVCertificationGenerable]
    let awards: [CVAwardGenerable]
    let skills: [String]
    let languages: [CVLanguageGenerable]
}

@Generable(description: "Experience")
struct CVExperienceGenerable: Codable {
    let role: String
    let company: String
    let location: String?
    let employmentType: String?
    let descriptionText: String?
    let startDate: String?
    let endDate: String?
}

@Generable(description: "Education")
struct CVEducationGenerable: Codable {
    let school: String
    let degree: String
    let fieldOfStudy: String?
    let startDate: String?
    let endDate: String?
}

@Generable(description: "Project")
struct CVProjectGenerable: Codable {
    let role: String?
    let name: String
    let descriptionText: [String]
    let startDate: String?
    let endDate: String?
}

@Generable(description: "Certification")
struct CVCertificationGenerable: Codable {
    let name: String
    let issuer: String
    let credentialID: String?
    let issueDate: String?
}

@Generable(description: "Award")
struct CVAwardGenerable: Codable {
    let title: String
    let issuer: String
    let issueDate: String?
}

@Generable(description: "Language")
struct CVLanguageGenerable: Codable {
    let name: String
    let proficiency: String?
}

// MARK: - Errors & Service

enum CVParsingAgentError: Error, LocalizedError {
    case cvTextTooLong
    
    var errorDescription: String? {
        switch self {
        case .cvTextTooLong:
            return "CV too long"
        }
    }
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
