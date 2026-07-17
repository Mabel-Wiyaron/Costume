//
//  SectionsAgentService.swift
//  Costume
//
//  Created by Saujana Shafi on 14/07/26.
//

import Foundation
import FoundationModels

// TODO: Refine the Prompts
let SECTIONS_INSTRUCTIONS_V1 = """
    You are a professional CV Writer. Orchestrate the CV Section based on the given role, abstract, keywords, and available sections.
    """

let SECTIONS_PROMPT_TEMPLATE_V1 = {
    (
        role: String,
        abstract: String,
        responsibilities: [String],
        requirements: [String],
        keywords: [String],
        availableSections: [String]
    ) -> String in
    return """
        Role: \(role)
        Abstract: \(abstract)
        Responsibilities: \(responsibilities)
        Requirements: \(requirements)
        Keywords: \(keywords)
        Sections: \(availableSections)
        """
}

// TODO: Partitions the descriptions into Prompt Template
@Generable(description: "")
enum SectionTitleGenerable: String {
    case profile = "profile"
    case summary = "summary"
    case experience = "experience"
    case skill = "skill"
    case education = "education"
    case certification = "certification"
    case project = "project"
    case award = "award"
    case language = "language"
}

@Generable(description: "")
struct SectionGenerable {
    @Guide(description: "Section title")
    let title: SectionTitleGenerable
    // TODO: Might need to specify the length of expected output. Right now its just too short
    @Guide(
        description:
            "Summary of Job Description to be the anchor of this section"
    )
    let description: String
    // TODO: Might need .maximumCount here
    @Guide(description: "List of keywords that are relevant to this section")
    let keywords: [String]
}

@Generable(description: "")
struct SectionsGenerable {
    @Guide(description: "List of CV Sections")
    let sections: [SectionGenerable]
}

struct SectionsAgentService: AgentProtocol {
    var languageModel: LanguageModelProtocol

    init() {
        languageModel = AppleIntelligenceService(
            instructions: SECTIONS_INSTRUCTIONS_V1
        )
    }

    func invoke(for message: String) async throws -> SectionsGenerable {
        return try await languageModel.generate(
            content: SectionsGenerable.self,
            for: message
        )
    }
}
