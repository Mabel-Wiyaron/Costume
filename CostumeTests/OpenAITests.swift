//
//  OpenAITests.swift
//  CostumeTests
//
//  Created by Saujana Shafi on 25/07/26.
//

import Foundation
import Testing

@testable import Costume

@Suite("OpenAI")
@MainActor
struct OpenAITests {

    // MARK: - Default Variable

    //    let ENDPOINT = URL(string: "https://integrate.api.nvidia.com/v1")!
    let ENDPOINT = URL(string: "http://127.0.0.1:11434/v1")!
    let API_KEY =
        //        "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"
        ""
    let MODEL = "gemma4:e4b"

    let TEMPERATURE = 0.5

    // MARK: - Job Description

    let JOB_DESCRIPTION: String = """
        Software Engineer Intern (Python)
        Thales

        About the job
        Location: SINGAPORE, Singapore

        Thales is a global technology leader trusted by governments, institutions, and enterprises to tackle their most demanding challenges. From quantum applications and artificial intelligence to cybersecurity and 6G innovation, our solutions empower critical decisions rooted in human intelligence. Operating at the forefront of aerospace and space, cybersecurity and digital identity, we’re driven by a mission to build a future we can all trust.

        In Singapore, Thales has been a trusted partner since 1973, originally focused on aerospace activities in the Asia-Pacific region. With 2,000 employees across three local sites, we deliver cutting-edge solutions across aerospace (including air traffic management), defence and security, and digital identity and cybersecurity sectors. Together, we’re shaping the future by enabling customers to make pivotal decisions that safeguard communities and power progress.

        Thales Singapore Engineering Competence Centre (ECC) is a well-established R&D and engineering centre serving major customers worldwide in Digital Identity and Security domains ranging from mobile connectivity, IoT, banking & payment to government solutions.

        As a Software Engineer in the Product Engineering team, you will participate in Personalization Delivery on production machine, and the design & implementation of standalone/web application for internal usage.

        Responsibilities:

        [Main] Collaborate with other NPI engineers to develop recurrent banking product configurations.
        Conduct validation campaign on banking configurations.
        [Secondary] Create (standalone or web) tools for internal usage.


        Requirements

        Bachelor of Science in Electrical and Electronic Engineering/Computer Science.
        Programming skills in Python. 
        Experience with microcontroller/ microprocessor (assembly language) is an advantage.
        Critical thinker and problem-solving skills.
        Able to commit 5-6 months, preferably on a full-time basis.


        Learning Outcomes

        Understand the full software development life cycle from planning, development, testing to integration.
        Be mentored by experienced product & software engineers.


        At Thales, we’re committed to fostering a workplace where respect, trust, collaboration, and passion drive everything we do. Here, you’ll feel empowered to bring your best self, thrive in a supportive culture, and love the work you do. Join us, and be part of a team reimagining technology to create solutions that truly make a difference – for a safer, greener, and more inclusive world.
        """

    @Test("Job Description")
    func jobDescription() async throws {
        let result = try await runJobDescriptionAgent(for: JOB_DESCRIPTION)

        print(result)

        #expect(result.role.contains("Software Engineer"))
        #expect(result.company.contains("Thales"))
        #expect(result.keywords.contains(where: { $0.contains("Python") }))
    }

    // Test "Job Description" passed after 3.985 seconds.
    let RESULT_JOB_DESCRIPTION = JobDescriptionGenerable(
        role: "Software Engineer Intern",
        company: "Thales",
        abstract:
            "Participate in Personalization Delivery on production machines and design & implementation of standalone/web applications for internal usage.",
        responsibilities: [
            "Collaborate with other NPI engineers to develop recurrent banking product configurations.",
            "Conduct validation campaigns on banking configurations.",
        ],
        requirements: [
            "Bachelor of Science in Electrical and Electronic Engineering/Computer Science.",
            "Programming skills in Python.",
            "Experience with microcontroller/microprocessor (assembly language) is an advantage.",
            "Critical thinker and problem-solving skills.",
            "Able to commit 5-6 months, preferably on a full-time basis.",
        ],
        keywords: [
            "Software Engineer", "Python", "Banking Product Configuration",
            "Validation Campaign", "Microcontroller", "Microprocessor",
            "Assembly Language", "Critical Thinking", "Problem Solving",
            "Mentorship", "Software Development Life Cycle",
        ]
    )

    // MARK: - Sections

    //    @Test("Sections")
    //    func sections() async throws {
    //        let result = try await runSectionsAgent(
    //            for: SECTIONS_PROMPT_TEMPLATE_V1(
    //                RESULT_JOB_DESCRIPTION.role,
    //                RESULT_JOB_DESCRIPTION.abstract,
    //                RESULT_JOB_DESCRIPTION.responsibilities,
    //                RESULT_JOB_DESCRIPTION.requirements,
    //                RESULT_JOB_DESCRIPTION.keywords,
    //                [
    //                    "summary",
    //                    "experience",
    //                    "education",
    //                    "project",
    //                ]
    //            )
    //        )
    //
    //        print(result)
    //
    //        #expect(!result.sections.isEmpty)
    //    }

    // Test "Sections" passed after 5.300 seconds.
    let RESULT_SECTIONS = SectionsGenerable(sections: [
        Costume.SectionGenerable(
            title: Costume.SectionTitleGenerable.summary,
            description:
                "Provide a concise overview of your skills, experiences, and career aspirations relevant to the Software Engineer Intern position. Highlight your ability to collaborate, problem-solve, and contribute to software development.",
            keywords: [
                "Software Engineer Intern", "Collaboration", "Problem Solving",
                "Software Development",
            ]
        ),
        Costume.SectionGenerable(
            title: Costume.SectionTitleGenerable.experience,
            description:
                "Detail your relevant work experience, emphasizing roles where you demonstrated skills in programming, software development, and teamwork. Include any experience with banking products or validation processes.",
            keywords: [
                "Software Engineer", "Programming",
                "Banking Product Configuration", "Validation Campaign",
            ]
        ),
        Costume.SectionGenerable(
            title: Costume.SectionTitleGenerable.education,
            description:
                "List your educational background, including degrees and relevant coursework. Highlight any coursework or projects that demonstrate your understanding of programming, software development, and related fields.",
            keywords: [
                "Bachelor of Science",
                "Electrical and Electronic Engineering/Computer Science",
                "Programming", "Software Development",
            ]
        ),
        Costume.SectionGenerable(
            title: Costume.SectionTitleGenerable.project,
            description:
                "Describe a relevant project or initiative where you demonstrated your skills in software development, problem-solving, and collaboration. Include specific achievements and the technologies you used.",
            keywords: [
                "Project", "Software Development", "Problem Solving",
                "Collaboration",
            ]
        ),
    ])

    // MARK: - Experience

    let EXPERIENCE: Experience = .init(
        role: "Software Engineer",
        employmentType: .internship,
        company: "Kuasar",
        location: "Remote, Indonesia",
        startDate: Date.now,
        descriptionText: [
            "Contributed to the development of an AI-powered chatbot platform by implementing new RAG features and enhancing existing functionalities.",
            "Built and maintained frontend components using Svelte, ensuring responsiveness and usability.",
            "Developed and integrated backend services using Python FastAPI, enhancing API efficiency and scalability",
        ]
    )

    @Test("Experience")
    func experience() async throws {
        let result = try await runExperienceAgent(
            for: EXPERIENCE_PROMPT_TEMPLATE_V1(
                RESULT_SECTIONS.sections[1].description,
                RESULT_SECTIONS.sections[1].keywords,
                EXPERIENCE.descriptionText
            )
        )

        print(result)

        #expect(!result.descriptions.isEmpty)
    }

    // Test "Experience" passed after 23.571 seconds.
    let RESULT_EXPERIENCE = ExperienceGenerable(descriptions: [
        "Enhanced an AI-powered chatbot platform by implementing new RAG features and improving existing functionalities.",
        "Developed and maintained frontend components using Svelte, ensuring high responsiveness and usability for the application.",
        "Integrated robust backend services using Python FastAPI, significantly enhancing overall API efficiency and scalability.",
    ])

    // MARK: - Project

    let PROJECT: Project = .init(
        role: "Full-Stack Developer",
        name: "Digital Twin Portfolio",
        startDate: Date.now,
        descriptionText: [
            "I implemented a RESTful API using Python FastAPI to handle user authentication, data validation, and CRUD operations for the digital twin portfolio application. The idea is to make a interviewable platform that can answer technical question about my skill based on my past work and experiences. Implemented RAG, Agentic, and Prompt Engineering on the Backend side and implemented Basic simple intuitive React UI tailored specifically for easy navigation related to professional experiences."
        ]
    )

    @Test("Project")
    func project() async throws {
        let result = try await runProjectAgent(
            for: PROJECT_PROMPT_TEMPLATE_V1(
                RESULT_SECTIONS.sections[3].description,
                RESULT_SECTIONS.sections[3].keywords,
                EXPERIENCE.descriptionText
            )
        )

        print(result)

        #expect(!result.descriptions.isEmpty)
    }

    // Test "Project" passed after 1.768 seconds.
    let RESULT_PROJECT = ProjectGenerable(descriptions: [
        "Built and maintained frontend components using Svelte, ensuring responsiveness and usability.",
        "Developed and integrated backend services using Python FastAPI, enhancing API efficiency and scalability.",
        "Contributed to the development of an AI-powered chatbot platform by implementing new RAG features and enhancing existing functionalities.",
        "Collaborated with cross-functional teams to streamline the development process.",
        "Optimized the codebase for better performance and maintainability.",
    ])

    // E2E Testing

    let PROFILE: Profile = .init(
        name: "Saujana Shafi",
        email: "hello@saujanashafi.com",
        location: "Surabaya, Indonesia",
        phone: "08921348019",
        summary: "",
        experiences: [
            .init(
                role: "Software Engineer",
                employmentType: .internship,
                company: "Kuasar",
                location: "Remote, Indonesia",
                startDate: Date.now,
                descriptionText: [
                    "Contributed to the development of an AI-powered chatbot platform by implementing new RAG features and enhancing existing functionalities.",
                    "Built and maintained frontend components using Svelte, ensuring responsiveness and usability.",
                    "Developed and integrated backend services using Python FastAPI, enhancing API efficiency and scalability",
                ]
            ),
            .init(
                role: "Software Engineer",
                employmentType: .internship,
                company: "Kuasar",
                location: "Remote, Indonesia",
                startDate: Date.now,
                descriptionText: [
                    "Contributed to the development of an AI-powered chatbot platform by implementing new RAG features and enhancing existing functionalities.",
                    "Built and maintained frontend components using Svelte, ensuring responsiveness and usability.",
                    "Developed and integrated backend services using Python FastAPI, enhancing API efficiency and scalability",
                ]
            ),
            .init(
                role: "Software Engineer",
                employmentType: .internship,
                company: "Kuasar",
                location: "Remote, Indonesia",
                startDate: Date.now,
                descriptionText: [
                    "Contributed to the development of an AI-powered chatbot platform by implementing new RAG features and enhancing existing functionalities.",
                    "Built and maintained frontend components using Svelte, ensuring responsiveness and usability.",
                    "Developed and integrated backend services using Python FastAPI, enhancing API efficiency and scalability",
                ]
            ),
            .init(
                role: "Software Engineer",
                employmentType: .internship,
                company: "Kuasar",
                location: "Remote, Indonesia",
                startDate: Date.now,
                descriptionText: [
                    "Contributed to the development of an AI-powered chatbot platform by implementing new RAG features and enhancing existing functionalities.",
                    "Built and maintained frontend components using Svelte, ensuring responsiveness and usability.",
                    "Developed and integrated backend services using Python FastAPI, enhancing API efficiency and scalability",
                ]
            ),
        ],
        educations: [
            .init(
                school: "Jenderal Soedirman University",
                degree: "Bachelor of Engineering",
                fieldOfStudy: "Electrical Engineering",
                startDate: Date.now,
            )
        ],
        projects: [
            .init(
                role: "Full-Stack Developer",
                name: "Digital Twin Portfolio",
                startDate: Date.now,
                descriptionText: [
                    "I implemented a RESTful API using Python FastAPI to handle user authentication, data validation, and CRUD operations for the digital twin portfolio application. The idea is to make a interviewable platform that can answer technical question about my skill based on my past work and experiences. Implemented RAG, Agentic, and Prompt Engineering on the Backend side and implemented Basic simple intuitive React UI tailored specifically for easy navigation related to professional experiences."
                ]
            ),
            .init(
                role: "Full-Stack Developer",
                name: "Digital Twin Portfolio",
                startDate: Date.now,
                descriptionText: [
                    "I implemented a RESTful API using Python FastAPI to handle user authentication, data validation, and CRUD operations for the digital twin portfolio application. The idea is to make a interviewable platform that can answer technical question about my skill based on my past work and experiences. Implemented RAG, Agentic, and Prompt Engineering on the Backend side and implemented Basic simple intuitive React UI tailored specifically for easy navigation related to professional experiences."
                ]
            ),
            .init(
                role: "Full-Stack Developer",
                name: "Digital Twin Portfolio",
                startDate: Date.now,
                descriptionText: [
                    "I implemented a RESTful API using Python FastAPI to handle user authentication, data validation, and CRUD operations for the digital twin portfolio application. The idea is to make a interviewable platform that can answer technical question about my skill based on my past work and experiences. Implemented RAG, Agentic, and Prompt Engineering on the Backend side and implemented Basic simple intuitive React UI tailored specifically for easy navigation related to professional experiences."
                ]
            ),
            .init(
                role: "Full-Stack Developer",
                name: "Digital Twin Portfolio",
                startDate: Date.now,
                descriptionText: [
                    "I implemented a RESTful API using Python FastAPI to handle user authentication, data validation, and CRUD operations for the digital twin portfolio application. The idea is to make a interviewable platform that can answer technical question about my skill based on my past work and experiences. Implemented RAG, Agentic, and Prompt Engineering on the Backend side and implemented Basic simple intuitive React UI tailored specifically for easy navigation related to professional experiences."
                ]
            ),
        ]
    )

    @Test("E2E")
    func e2e() async throws {
        let jdResult = try await runJobDescriptionAgent(for: JOB_DESCRIPTION)

        print(jdResult)

        #expect(jdResult.role.contains("Software Engineer"))

        let sectionsResult = try await runSectionsAgent(
            for: SECTIONS_PROMPT_TEMPLATE_V1(
                jdResult.role,
                jdResult.abstract,
                jdResult.responsibilities,
                jdResult.requirements,
                jdResult.keywords,
                [
                    "summary",
                    "experience",
                    "education",
                    "project",
                ]
            )
        )

        print(sectionsResult)

        #expect(sectionsResult.sections.count == 4)

        var profile: Profile = PROFILE.duplicate()

        for section in sectionsResult.sections {
            switch section.title {
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

            default:
                continue
            }
        }

        print(profile)
        print(profile.experiences.first?.descriptionText)
        print(profile.educations.first?.degree)
        print(profile.projects.first?.descriptionText)

        //        #expect(profile.hasChanges)
        #expect(profile.experiences.count == PROFILE.experiences.count)
        #expect(
            profile.experiences.first?.descriptionText
                != PROFILE.experiences.first?.descriptionText
        )
        #expect(profile.projects.count == PROFILE.projects.count)
        #expect(
            profile.projects.first?.descriptionText
                != PROFILE.projects.first?.descriptionText
        )

    }

    func getLanguageModel() async -> LanguageModelProtocol {
        return OpenAIService.init(
            temperature: TEMPERATURE,
            endpoint: ENDPOINT,
            apiKey: API_KEY,
            model: MODEL,
        )
    }

    func runJobDescriptionAgent(for message: String) async throws
        -> JobDescriptionGenerable
    {
        let jobDescriptionAgent: JobDescriptionAgentService = await .init(
            languageModel: getLanguageModel()
        )

        return try await jobDescriptionAgent.invoke(for: message)
    }

    func runSectionsAgent(for message: String) async throws -> SectionsGenerable
    {
        let sectionsAgent: SectionsAgentService = await .init(
            languageModel: getLanguageModel()
        )

        return try await sectionsAgent.invoke(for: message)
    }

    func runSummaryAgent(for message: String) async throws -> SummaryGenerable {
        let summaryAgent: SummaryAgentService = .init()

        return try await summaryAgent.invoke(for: message)
    }

    func runExperienceAgent(for message: String) async throws
        -> ExperienceGenerable
    {
        let experienceAgent: ExperienceAgentService = await .init(
            languageModel: getLanguageModel()
        )

        return try await experienceAgent.invoke(for: message)
    }

    func runEducationAgent(for message: String) async throws
        -> EducationGenerable
    {
        let educationAgent: EducationAgentService = await .init(
            languageModel: getLanguageModel()
        )

        return try await educationAgent.invoke(for: message)
    }

    func runProjectAgent(for message: String) async throws -> ProjectGenerable {
        let projectAgent: ProjectAgentService = await .init(
            languageModel: getLanguageModel()
        )

        return try await projectAgent.invoke(for: message)
    }
}

