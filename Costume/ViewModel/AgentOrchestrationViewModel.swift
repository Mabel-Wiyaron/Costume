//
//  AgentOrchestrationViewModel.swift
//  Costume
//
//  Created by Saujana Shafi on 17/07/26.
//

import Foundation

@Observable
final class AgentOrchestrationViewModel {
    // MARK: - Agents
    let sectionsAgent: SectionsAgentService = .init()

    let availableSections: [SectionTitleGenerable] = [
        .profile,
        .summary,
        .experience,
        .skill,
        .education,
        .project,
        .award,
        .language,
    ]

    func tailor(
        for jobDescription: JobDescriptionGenerable,
        from profile: Profile
    ) async throws -> Profile {
        let sections: SectionsGenerable = try await sectionsAgent.invoke(
            for: SECTIONS_PROMPT_TEMPLATE_V1(
                jobDescription.role,
                jobDescription.abstract,
                jobDescription.responsibilities,
                jobDescription.requirements,
                jobDescription.keywords,
                availableSections.map { String(describing: $0) }
            )
        )

        for section in sections.sections {
            switch section.title {
            case .profile:
                let profileGenerable = ProfileGenerable(
                    name: profile.name,
                    role: nil,
                    email: profile.email,
                    location: profile.location,
                    phone: profile.phone,
                    link1: profile.linkedin?.absoluteString,
                    link2: profile.website?.absoluteString,
                    link3: nil
                )
                let data = try JSONEncoder().encode(profileGenerable)
                let message = String(data: data, encoding: .utf8)!
                let generated = try await runProfileAgent(for: message)
                profile.name = generated.name
                if let email = generated.email { profile.email = email }
                if let location = generated.location {
                    profile.location = location
                }
                if let phone = generated.phone { profile.phone = phone }
                if let link1 = generated.link1, !link1.isEmpty {
                    profile.linkedin = URL(string: link1)
                }
                if let link2 = generated.link2, !link2.isEmpty {
                    profile.website = URL(string: link2)
                }

            case .summary:
                let summary = SummaryGenerable(content: profile.summary ?? "")
                let data = try JSONEncoder().encode(summary)
                let message = String(data: data, encoding: .utf8)!
                let generated = try await runSummaryAgent(for: message)
                profile.summary = generated.content

            case .experience:
                var generatedExperiences: [ExperienceGenerable] = []
                for experience in profile.experiences {
                    let generated = try await runExperienceAgent(
                        for: EXPERIENCE_PROMPT_TEMPLATE_V1(
                            section.description,
                            section.keywords,
                            experience.descriptionText
                        )
                    )
                    generatedExperiences.append(generated)
                }
                for (index, experience) in profile.experiences.enumerated() {
                    if index < generatedExperiences.count {
                        experience.descriptionText =
                            generatedExperiences[index].descriptions
                    }
                }

            case .skill:
                let skillContent = profile.skills.map(\.name)
                let skill = SkillGenerable(content: skillContent)
                let data = try JSONEncoder().encode(skill)
                let message = String(data: data, encoding: .utf8)!
                let generated = try await runSkillAgent(for: message)
                profile.skills = generated.content.map { Skill(name: $0) }

            case .education:
                for education in profile.educations {
                    let descriptions = [
                        "\(education.degree) in \(education.fieldOfStudy) at \(education.school)"
                    ]
                    _ = try await runEducationAgent(
                        for: EDUCATION_PROMPT_TEMPLATE_V1(
                            section.description,
                            section.keywords,
                            descriptions
                        )
                    )
                }

            case .project:
                for project in profile.projects {
                    let generated = try await runProjectAgent(
                        for: PROJECT_PROMPT_TEMPLATE_V1(
                            section.description,
                            section.keywords,
                            project.descriptionText
                        )
                    )
                    project.descriptionText = generated.descriptions
                }

            case .award:
                for award in profile.awards {
                    let awardGenerable = AwardGenerable(
                        title: award.title,
                        issuer: award.issuer,
                        issueDate: ISO8601DateFormatter().string(
                            from: award.issueDate
                        )
                    )
                    let data = try JSONEncoder().encode(awardGenerable)
                    let message = String(data: data, encoding: .utf8)!
                    let generated = try await runAwardAgent(for: message)
                    award.title = generated.title
                    award.issuer = generated.issuer
                }

            case .language:
                for language in profile.languages {
                    let languageGenerable = LanguageGenerable(
                        name: language.name,
                        proficiency: language.proficiency
                    )
                    let data = try JSONEncoder().encode(languageGenerable)
                    let message = String(data: data, encoding: .utf8)!
                    let generated = try await runLanguageAgent(for: message)
                    language.name = generated.name
                    language.proficiency = generated.proficiency
                }
            default:
                continue
            }
        }

        return profile
    }

    func runProfileAgent(for message: String) async throws -> ProfileGenerable {
        let profileAgent: ProfileAgentService = .init()

        return try await profileAgent.invoke(for: message)
    }

    func runSummaryAgent(for message: String) async throws -> SummaryGenerable {
        let summaryAgent: SummaryAgentService = .init()

        return try await summaryAgent.invoke(for: message)
    }

    func runExperienceAgent(for message: String) async throws
        -> ExperienceGenerable
    {
        let experienceAgent: ExperienceAgentService = .init()

        return try await experienceAgent.invoke(for: message)
    }

    func runSkillAgent(for message: String) async throws -> SkillGenerable {
        let skillAgent: SkillAgentService = .init()

        return try await skillAgent.invoke(for: message)
    }

    func runEducationAgent(for message: String) async throws
        -> EducationGenerable
    {
        let educationAgent: EducationAgentService = .init()

        return try await educationAgent.invoke(for: message)
    }

    func runProjectAgent(for message: String) async throws -> ProjectGenerable {
        let projectAgent: ProjectAgentService = .init()

        return try await projectAgent.invoke(for: message)
    }

    func runAwardAgent(for message: String) async throws -> AwardGenerable {
        let awardAgent: AwardAgentService = .init()

        return try await awardAgent.invoke(for: message)
    }

    func runLanguageAgent(for message: String) async throws -> LanguageGenerable
    {
        let languageAgent: LanguageAgentService = .init()

        return try await languageAgent.invoke(for: message)
    }
}
