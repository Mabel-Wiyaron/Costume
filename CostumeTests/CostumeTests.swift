//
//  CostumeTests.swift
//  CostumeTests
//
//  Created by William Constantine Jioe on 10/07/26.
//

import Testing

@testable import Costume

struct CostumeTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        // Swift Testing Documentation
        // https://developer.apple.com/documentation/testing
    }

}

@Suite("LanguageModel")
struct LanguageModelTests {

    // MARK: - Default Variable

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

    // MARK: - Job Description

    @Test("Running fine")
    func jobDescriptionRunningFine() async throws {
        let agent = await JobDescriptionAgentService()

        let result = try await agent.invoke(for: JOB_DESCRIPTION)

        #expect(type(of: result) == JobDescriptionGenerable.self)
    }

    @Test("Check Content")
    func jobDescriptionContent() async throws {
        let agent = await JobDescriptionAgentService()

        let result = try await agent.invoke(for: JOB_DESCRIPTION)

        #expect(result.role.contains("Software Engineer"))
        #expect(result.company.contains("Thales"))
    }
}
