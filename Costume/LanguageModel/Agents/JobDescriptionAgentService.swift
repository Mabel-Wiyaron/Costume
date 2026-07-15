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
    Extract only structured, factual information and prioritized ATS keywords from a job description, for a job seeker's CV. Never invent skills, tools, or requirements not stated. Be terse and neutral — you are producing data for the app, not prose for a reader.
     
        Never treat employment logistics (job type, schedule, location, pay, duration) or company boilerplate (benefits, EEO/DEI text) as keywords or requirements — these describe the posting, not the candidate.
     
        Favor precision over completeness: a short, high-signal list beats an exhaustive one.
    """

// TODO: Partitions the descriptions into Prompt Template
@Generable(description: "Structured breakdown of a job description, extracted for resume tailoring and ATS keyword matching.")
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
    
    @Guide(description: """
            ATS keywords, required/most-emphasized first, then nice-to-haves.
            
            INCLUDE:
            - Hard skills, tools, industry terms (e.g. "SQL", "RLHF")
            - Degree/field of study, certifications, exact proficiency levels (e.g. "English C1")
            - Soft skills only if explicitly named, each as its own entry (e.g. "Critical Thinking", "Problem Solving")
            
            EXCLUDE:
            - Job logistics (type, schedule, location, pay, duration), company boilerplate
            - The role title and company name — already captured in other fields
            - Synonyms of the same idea — pick one (e.g. only "Internship", not also "Intern")
            
            MERGING RULE:
            - Only combine adjectives describing ONE action into one phrase (e.g. "evaluated for relevance, accuracy, clarity" → "Response Quality Evaluation")
            - Do NOT merge separately-named skills — keep "Critical Thinking" and "Problem Solving" as two entries
            
            FORMAT:
            - Unique 1-4 word noun phrases, CV-ready casing (e.g. "AI" not "Al")
            - Prefer specific multi-word phrases over generic single words
            - Return only as many as genuinely qualify — do not pad to hit a count
            """, .minimumCount(6), .maximumCount(15))
        let keywords: [String]
    
}

enum JobDescriptionAgentError: Error {
    case jobDescriptionTooLong
}

struct JobDescriptionAgentService: AgentProtocol {
    var languageModel: LanguageModelProtocol
    
    init() {
        languageModel = AppleIntelligenceService(
            instructions: JOB_DESCRIPTION_INSTRUCTIONS_V1
        )
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
