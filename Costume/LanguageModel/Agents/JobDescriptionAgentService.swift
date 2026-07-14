//
//  JobDescriptionAgentService.swift
//  Costume
//
//  Created by Saujana Shafi on 13/07/26.
//

import Foundation
import FoundationModels

// TODO: Refine the Prompts
let JOB_DESCRIPTION_INSTRUCTIONS_V1 = """
    Extract the keywords from the given job description.
    """

// TODO: Partitions the descriptions into Prompt Template
@Generable(description: "")
struct JobDescriptionGenerable {
    @Guide(description: "Role name of the job")
    let role: String
    @Guide(description: "Company name of the job")
    let company: String
    @Guide(
        description:
            "Summary of the Job Description. Keep it short and impactful. 500-600 words"
    )
    let abstract: String
    @Guide(description: "List of responsibilities. Use action verbs")
    let responsibilities: [String]
    @Guide(description: "List of requirements. Quantify where possible")
    let requirements: [String]
    @Guide(
        description:
            "Technical skills and experience that make a great candidate for this job"
    )
    let keywords: [String]
}

struct JobDescriptionAgentService: AgentProtocol {
    var languageModel: LanguageModelProtocol

    init() {
        languageModel = AppleIntelligenceService(
            instructions: JOB_DESCRIPTION_INSTRUCTIONS_V1
        )
    }

    func invoke(for message: String) async throws -> JobDescriptionGenerable {
        return try await languageModel.generate(
            content: JobDescriptionGenerable.self,
            for: message
        )
    }
}
