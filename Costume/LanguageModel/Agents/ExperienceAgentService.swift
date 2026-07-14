//
//  ExperienceAgentService.swift
//  Costume
//
//  Created by Saujana Shafi on 13/07/26.
//

import Foundation
import FoundationModels

// TODO: Refine the Prompts
let EXPERIENCE_INSTRUCTIONS_V1 = """
    Improve the current list of descriptions of CV Writing. Based on the Job Description Summary & Keywords.
    """

let EXPERIENCE_PROMPT_TEMPLATE_V1 = {
    (
        summary: String,
        keywords: [String],
        descriptions: [String]
    ) -> String in
    return """
        Job Description Summary: \(summary)
        Keywords: \(keywords)
        Descriptions: \(descriptions)
        """
}

// TODO: Partitions the descriptions into Prompt Template
@Generable(description: "")
struct ExperienceGenerable {
    @Guide(
        description:
            "A at least 1 and up to 5 (Only if it's really needed) brief description of your role. Use the XYZ CV Writing Framework. Use strong action verbs. Quantify if possible. Use the following format: - Action Verb, Quantification. Example: - Increased UI development efficiency by 30% by building reusable components using SwiftUI and MVVM architecture.",
        .minimumCount(1),
        .maximumCount(5),
        
    )
    let descriptions: [String]
}

struct ExperienceAgentService: AgentProtocol {
    var languageModel: LanguageModelProtocol

    init() {
        languageModel = AppleIntelligenceService(
            instructions: EXPERIENCE_INSTRUCTIONS_V1
        )
    }

    func invoke(for message: String) async throws -> ExperienceGenerable {
        return try await languageModel.generate(
            content: ExperienceGenerable.self,
            for: message
        )
    }
}
