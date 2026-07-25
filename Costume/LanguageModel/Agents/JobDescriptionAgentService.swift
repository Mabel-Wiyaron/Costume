//
//  JobDescriptionAgentService.swift
//  Costume
//
//  Created by Saujana Shafi on 13/07/26.
//

import Foundation
import FoundationModels

// Prompt designed using the CO-STAR framework:
// - Context: a job seeker tailoring a CV to one pasted job description
// - Objective: extract structured facts + prioritized ATS keywords, inventing nothing
// - Style/Tone: terse, factual, extraction-only — no advice, no address to the reader
// - Audience: consumed as data by the app, not read as prose by a person
// - Response format: enforced by the @Generable schema below — deliberately NOT restated
//   here, since re-describing a format the schema already guarantees would just spend
//   tokens twice on the same constraint inside a 4096-token context window

// TODO: Refine the Prompts
let JOB_DESCRIPTION_INSTRUCTIONS_V1 = """
    You are a data extraction engine. Given a job description, produce a structured breakdown for CV tailoring. Extract only what is stated — never invent skills, tools, or requirements.

    PRINCIPLES
    - You produce structured data, not prose. Be terse and neutral.
    - Every extracted fact must be traceable to the input.
    - Favor precision over completeness: a short, high-signal output beats a long, noisy one.
    - Treat the 4096-token context window as a shared resource — keep each field as compact as possible without losing signal.

    FIELD RULES
    - role: The exact job title only. Strip location suffixes, "at Company", and parentheticals. Example: "Senior Software Engineer" not "Senior Software Engineer at Acme (Remote)".
    - company: The hiring organization as stated.
    - abstract: 2-4 dense sentences capturing the role's purpose, core responsibilities, and impact area. This is reused as the anchor description for every CV section — prioritize signal density over word count.
    - responsibilities: The action-oriented responsibilities as written in the JD. Preserve original action verbs and phrasing. Do not rephrase, reorder, or embellish.
    - requirements: Stated qualifications and preferred criteria. Extract near-verbatim. Do not add quantification that isn't present in the source.
    - keywords: Prioritized ATS keywords, most critical first. Rules:
        • Include: hard skills, tools, technologies, certifications, degree fields, explicitly-named soft skills.
        • Exclude: job logistics (type, schedule, location, pay, duration, remote/onsite), company boilerplate (benefits, EEO/DEI), the role title, and the company name.
        • De-duplicate synonyms — pick the most CV-ready form (e.g. "Internship" not also "Intern").
        • Format as 1-4 word noun phrases with CV-ready casing (e.g. "Response Quality Evaluation" not "evaluated for relevance, accuracy, clarity").
        • Do not pad — return only what genuinely qualifies as distinct, meaningful keywords.
        • When the JD is too short or vague to extract meaningful keywords, return fewer rather than forcing generic terms.

    EDGE CASES
    - Very short JD (1-2 sentences): extract what's available, leave non-applicable fields minimal.
    - Vague or generic JD: extract only what's stated. Do not infer requirements.
    - Truncated input: extract from what's available. Do not complete truncated sentences.
    """

let JOB_DESCRIPTION_ROLE_V1 = "Job title only — no company, location, or parenthetical suffixes"
let JOB_DESCRIPTION_COMPANY_V1 = "Hiring organization name"
let JOB_DESCRIPTION_ABSTRACT_V1 = "2-4 sentence summary of the role's purpose and focus area. Used as anchor for every CV section."
let JOB_DESCRIPTION_RESPONSIBILITIES_V1 = "Responsibilities as written in the JD, preserving original action verbs"
let JOB_DESCRIPTION_REQUIREMENTS_V1 = "Qualifications and preferred criteria as stated in the JD"
let JOB_DESCRIPTION_KEYWORDS_V1 = "Prioritized ATS keywords: hard skills, tools, technologies, certifications, degree fields, explicitly-named soft skills. No logistics or boilerplate. 1-4 word noun phrases, CV-ready casing, de-duplicated."

let JOB_DESCRIPTION_SCHEMA_DESCRIPTIONS_V1: [String: String] = [
    "role": JOB_DESCRIPTION_ROLE_V1,
    "company": JOB_DESCRIPTION_COMPANY_V1,
    "abstract": JOB_DESCRIPTION_ABSTRACT_V1,
    "responsibilities": JOB_DESCRIPTION_RESPONSIBILITIES_V1,
    "requirements": JOB_DESCRIPTION_REQUIREMENTS_V1,
    "keywords": JOB_DESCRIPTION_KEYWORDS_V1,
]

@Generable(
    description:
        "Structured breakdown of a job description for resume tailoring and ATS matching."
)
struct JobDescriptionGenerable: Codable {
    @Guide(description: JOB_DESCRIPTION_ROLE_V1)
    let role: String

    @Guide(description: JOB_DESCRIPTION_COMPANY_V1)
    let company: String

    @Guide(description: JOB_DESCRIPTION_ABSTRACT_V1)
    let abstract: String

    @Guide(description: JOB_DESCRIPTION_RESPONSIBILITIES_V1)
    let responsibilities: [String]

    @Guide(description: JOB_DESCRIPTION_REQUIREMENTS_V1)
    let requirements: [String]

    @Guide(
        description: JOB_DESCRIPTION_KEYWORDS_V1,
        .minimumCount(6),
        .maximumCount(15)
    )
    let keywords: [String]
}

enum JobDescriptionAgentError: Error {
    case jobDescriptionTooLong
}

struct JobDescriptionAgentService: AgentProtocol {
    var languageModel: LanguageModelProtocol

    init(languageModel: LanguageModelProtocol = AppleIntelligenceService()) {
        self.languageModel = languageModel
        
        self.languageModel.instructions = JOB_DESCRIPTION_INSTRUCTIONS_V1
    }
    
    func invoke(for message: String) async throws -> JobDescriptionGenerable {
        do {
            return try await languageModel.generate(
                content: JobDescriptionGenerable.self,
                for: message
            )
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            throw JobDescriptionAgentError.jobDescriptionTooLong
        }
    }
}
