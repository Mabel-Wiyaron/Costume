//
//  ExperienceAgentService.swift
//  Costume
//
//  Created by Saujana Shafi on 13/07/26.
//

import Foundation
import FoundationModels

let EXPERIENCE_INSTRUCTIONS_V1 = """
    You rephrase experience bullet points to make them clearer and more impactful. The original descriptions are the sole source of truth — every fact, skill, metric, and tool in your output must be directly traceable to them.

    GROUND TRUTH RULES
    - Never add a skill, tool, responsibility, metric, or outcome not present in the original descriptions.
    - Never upgrade scope (e.g. "Contributed to" → "Led", "Helped with" → "Designed").
    - Never add a quantification that wasn't in the original — changing "improved performance" to "improved performance by 30%" is hallucination.
    - If the Directive asks you to emphasize a technology or theme that doesn't appear in the original descriptions, ignore it — polish the language only.
    - If a Keyword has no match in the original descriptions, do not add it.
    - Each output bullet must map to exactly one input description. Do not merge or split descriptions.
    - Preserve the original count of descriptions. Only reduce if explicitly justified.

    REWRITING RULES (apply only within the bounds above)
    - Start each bullet with a strong action verb (Led, Designed, Optimized, Architected, Implemented, etc.).
    - Improve sentence flow and clarity without changing facts.
    - Use this structure: [Action Verb] [What You Did], [Context or Outcome].
      Example: "Increased UI development efficiency by 30% by building reusable SwiftUI components with MVVM architecture."
    - If the Directive calls out an aspect that genuinely exists in the original, rephrase to bring it forward.
    - If the original is already clear and well-written, leave it as-is.

    VERIFICATION
    - Before returning, check each output bullet against its source. Any fact, number, or tool not in the source is a hallucination — remove it.
    """

let EXPERIENCE_PROMPT_TEMPLATE_V1 = {
    (
        directive: String,
        keywords: [String],
        descriptions: [String]
    ) -> String in
    return """
        Section Directive: \(directive)
        Keywords: \(keywords)
        Original Descriptions: \(descriptions)
        """
}

let EXPERIENCE_DESCRIPTIONS_V1 =
    "Rewritten bullet points. Start with a strong action verb, quantify impact where possible. 1-5 items."

@Generable(description: "")
struct ExperienceGenerable: Decodable {
    @Guide(
        description: EXPERIENCE_DESCRIPTIONS_V1,
        .minimumCount(1),
        .maximumCount(5),
    )
    let descriptions: [String]
}

extension ExperienceGenerable: SchemaDescribing {
    static let propertyDescriptions: [String: String] = [
        "descriptions": EXPERIENCE_DESCRIPTIONS_V1
    ]
}

struct ExperienceAgentService: AgentProtocol {
    var languageModel: LanguageModelProtocol

    init(languageModel: LanguageModelProtocol = AppleIntelligenceService()) {
        self.languageModel = languageModel

        self.languageModel.instructions = EXPERIENCE_INSTRUCTIONS_V1
    }

    func invoke(for message: String) async throws -> ExperienceGenerable {
        return try await languageModel.generate(
            content: ExperienceGenerable.self,
            for: message
        )
    }
}
