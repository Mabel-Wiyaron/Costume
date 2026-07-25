//
//  SectionsAgentService.swift
//  Costume
//
//  Created by Saujana Shafi on 14/07/26.
//

import Foundation
import FoundationModels

let SECTIONS_INSTRUCTIONS_V1 = """
    You orchestrate which CV sections to include for a specific job description and produce a targeted rewrite directive for each. The sections you select will each be rewritten by a downstream agent — your description is that agent's primary context.

    FIELD RULES
    - title: Which CV section this is. Select from the available sections list.
    - description: A section-specific directive for the downstream rewriting agent. This is NOT a JD summary — it tells the agent what to emphasize, which responsibilities/requirements/themes from the JD are most relevant to this section, what angle to take, and what to downplay. Be concrete and specific to this section's content type.
    - keywords: A curated subset of the JD keywords most relevant to this specific section. Only include keywords that directly connect to the content this section covers.

    SELECTION RULES
    - Only include a section if the JD provides meaningful signal to tailor it. Omit sections where the JD offers no relevant direction.
    - Order sections by their importance to this specific JD — the most impactful sections first.
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
        Available Sections: \(availableSections)
        """
}

let SECTION_TITLE_V1 = "Section title from the available sections list"
let SECTION_DESCRIPTION_V1 = "Section-specific rewrite directive: which JD responsibilities/requirements/themes to emphasize, what angle to take, and what to downplay. Passed verbatim as the primary context to the downstream rewriting agent for this section."
let SECTION_KEYWORDS_V1 = "Curated subset of JD keywords most relevant to this section. Only keywords that directly connect to this section's content."

let SECTION_SCHEMA_DESCRIPTIONS_V1: [String: String] = [
    "title": SECTION_TITLE_V1,
    "description": SECTION_DESCRIPTION_V1,
    "keywords": SECTION_KEYWORDS_V1,
]

let SECTIONS_LIST_V1 = "List of CV Sections"

let SECTIONS_SCHEMA_DESCRIPTIONS_V1: [String: String] = [
    "sections": SECTIONS_LIST_V1,
]

@Generable(description: "")
enum SectionTitleGenerable: String, Decodable {
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
struct SectionGenerable: Decodable {
    @Guide(description: SECTION_TITLE_V1)
    let title: SectionTitleGenerable
    @Guide(
        description: SECTION_DESCRIPTION_V1
    )
    let description: String
    @Guide(
        description: SECTION_KEYWORDS_V1,
        .minimumCount(1),
        .maximumCount(8)
    )
    let keywords: [String]
}

@Generable(description: "")
struct SectionsGenerable: Decodable {
    @Guide(description: SECTIONS_LIST_V1, .count(4))
    let sections: [SectionGenerable]
}

struct SectionsAgentService: AgentProtocol {
    var languageModel: LanguageModelProtocol

    init(languageModel: LanguageModelProtocol = AppleIntelligenceService()) {
        self.languageModel = languageModel

        self.languageModel.instructions = SECTIONS_INSTRUCTIONS_V1
    }

    func invoke(for message: String) async throws -> SectionsGenerable {
        return try await languageModel.generate(
            content: SectionsGenerable.self,
            for: message
        )
    }
}
