//
//  CostumeTests.swift
//  CostumeTests
//
//  Created by William Constantine Jioe on 10/07/26.
//

import Testing
import SwiftData
import Foundation
@testable import Costume

@MainActor
@Suite(.serialized)
struct CostumeTests {

    // Helper function untuk merakit ModelContainer in-memory yang bersih untuk setiap test case
    private func createTestContext() throws -> (context: ModelContext, profile: Profile, container: ModelContainer) {
        let schema = Schema([
            Profile.self,
            ProfileLink.self,
            Experience.self,
            Education.self,
            Certification.self,
            Project.self,
            Award.self,
            Language.self,
            Skill.self
        ])
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext
        
        // Menggunakan parameter inisialisasi Profile terbaru yang kamu miliki
        let profile = Profile(
            name: "William Constantine",
            email: "william@example.com",
            location: "Surabaya",
            phone: "08123456789"
        )
        
        context.insert(profile)
        try context.save()
        
        return (context, profile, container)
    }

    // MARK: - EDUCATION TESTS
    
    @Test("Menambahkan data Education baru ke database")
    func testSaveNewEducation() async throws {
        let (context, profile, _container) = try createTestContext()
        let viewModel = EditProfileViewModel(profile: profile, modelContext: context)
        
        #expect(profile.educations.isEmpty)

        viewModel.saveEducation(
            school: "Binus University",
            degree: "Bachelor",
            fieldOfStudy: "Computer Science",
            grade: "3.90",
            startDate: Date(),
            endDate: nil
        )

        #expect(profile.educations.count == 1)
        #expect(profile.educations.first?.school == "Binus University")
        
        let saved = try context.fetch(FetchDescriptor<Education>())
        #expect(saved.count == 1)
    }

    @Test("Menghapus data Education dari database")
    func testDeleteEducation() async throws {
        let (context, profile, _container) = try createTestContext()
        let viewModel = EditProfileViewModel(profile: profile, modelContext: context)
        
        let education = Education(school: "Apple Academy", degree: "Professional", fieldOfStudy: "iOS", startDate: Date())
        context.insert(education)
        profile.educations.append(education)
        try context.save()

        viewModel.deleteEducation(education)

        #expect(profile.educations.isEmpty)
        let saved = try context.fetch(FetchDescriptor<Education>())
        #expect(saved.isEmpty)
    }

    // MARK: - EXPERIENCE TESTS

    @Test("Menambahkan data Experience baru")
    func testSaveNewExperience() async throws {
        let (context, profile, _container) = try createTestContext()
        let viewModel = EditProfileViewModel(profile: profile, modelContext: context)

        viewModel.saveExperience(
            role: "iOS Engineer",
            employmentType: .fullTime,
            company: "Apple Inc",
            location: "Jakarta",
            startDate: Date(),
            endDate: nil,
            descriptionText: ["Membangun aplikasi Costume"]
        )

        #expect(profile.experiences.count == 1)
        #expect(profile.experiences.first?.role == "iOS Engineer")
        #expect(profile.experiences.first?.employmentType == .fullTime)
        
        let saved = try context.fetch(FetchDescriptor<Experience>())
        #expect(saved.count == 1)
    }

    @Test("Menghapus data Experience dari database")
    func testDeleteExperience() async throws {
        let (context, profile, _container) = try createTestContext()
        let viewModel = EditProfileViewModel(profile: profile, modelContext: context)
        
        let experience = Experience(role: "Android Developer", employmentType: .fullTime, company: "Google", location: "Singapore", startDate: Date())
        context.insert(experience)
        profile.experiences.append(experience)
        try context.save()

        viewModel.deleteExperience(experience)

        #expect(profile.experiences.isEmpty)
        let saved = try context.fetch(FetchDescriptor<Experience>())
        #expect(saved.isEmpty)
    }

    // MARK: - PROJECT TESTS

    @Test("Menambahkan data Project baru")
    func testSaveNewProject() async throws {
        let (context, profile, _container) = try createTestContext()
        let viewModel = EditProfileViewModel(profile: profile, modelContext: context)

        viewModel.saveProject(
            name: "Costume App",
            role: "Lead iOS Engineer",
            startDate: Date(),
            endDate: nil,
            website: "https://github.com/william/costume",
            descriptionText: ["Aplikasi portofolio berbasis AI"]
        )

        #expect(profile.projects.count == 1)
        #expect(profile.projects.first?.name == "Costume App")
        #expect(profile.projects.first?.role == "Lead iOS Engineer")
        #expect(profile.projects.first?.website == URL(string: "https://github.com/william/costume"))
        
        let saved = try context.fetch(FetchDescriptor<Project>())
        #expect(saved.count == 1)
    }

    @Test("Menghapus data Project dari database")
    func testDeleteProject() async throws {
        let (context, profile, _container) = try createTestContext()
        let viewModel = EditProfileViewModel(profile: profile, modelContext: context)
        
        let project = Project(role: "Developer", name: "Old Project", startDate: Date())
        context.insert(project)
        profile.projects.append(project)
        try context.save()

        viewModel.deleteProject(project)

        #expect(profile.projects.isEmpty)
        let saved = try context.fetch(FetchDescriptor<Project>())
        #expect(saved.isEmpty)
    }

    // MARK: - CERTIFICATION TESTS

    @Test("Menambahkan data Certification baru")
    func testSaveNewCertification() async throws {
        let (context, profile, _container) = try createTestContext()
        let viewModel = EditProfileViewModel(profile: profile, modelContext: context)

        viewModel.saveCertification(
            name: "WWDC Scholar",
            issuer: "Apple",
            issueDate: Date(),
            expirationDate: nil,
            credentialID: "ID-9921",
            credentialURL: "https://developer.apple.com"
        )

        #expect(profile.certifications.count == 1)
        #expect(profile.certifications.first?.name == "WWDC Scholar")
        #expect(profile.certifications.first?.credentialURL == URL(string: "https://developer.apple.com"))
        
        let saved = try context.fetch(FetchDescriptor<Certification>())
        #expect(saved.count == 1)
    }

    @Test("Menghapus data Certification dari database")
    func testDeleteCertification() async throws {
        let (context, profile, _container) = try createTestContext()
        let viewModel = EditProfileViewModel(profile: profile, modelContext: context)
        
        let certificate = Certification(name: "Basic Swift Course", issuer: "Udemy", issueDate: Date(), credentialID: "UDEMY-123")
        context.insert(certificate)
        profile.certifications.append(certificate)
        try context.save()

        viewModel.deleteCertification(certificate)

        #expect(profile.certifications.isEmpty)
        let saved = try context.fetch(FetchDescriptor<Certification>())
        #expect(saved.isEmpty)
    }

    // MARK: - AWARD TESTS

    @Test("Menambahkan data Award baru")
    func testSaveNewAward() async throws {
        let (context, profile, _container) = try createTestContext()
        let viewModel = EditProfileViewModel(profile: profile, modelContext: context)

        viewModel.saveAward(
            title: "1st Place Hackathon",
            issuer: "Tech Corp",
            issueDate: Date()
        )

        #expect(profile.awards.count == 1)
        #expect(profile.awards.first?.title == "1st Place Hackathon")
        
        let saved = try context.fetch(FetchDescriptor<Award>())
        #expect(saved.count == 1)
    }

    @Test("Menghapus data Award dari database")
    func testDeleteAward() async throws {
        let (context, profile, _container) = try createTestContext()
        let viewModel = EditProfileViewModel(profile: profile, modelContext: context)
        
        let award = Award(title: "Participation Ribbons", issuer: "Local Event", issueDate: Date())
        context.insert(award)
        profile.awards.append(award)
        try context.save()

        viewModel.deleteAward(award)

        #expect(profile.awards.isEmpty)
        let saved = try context.fetch(FetchDescriptor<Award>())
        #expect(saved.isEmpty)
    }

    // MARK: - COMPILER & TEMPLATE TESTS

    @Test("Menyebarkan halaman ATSCVTemplateView dengan benar")
    func testATSCVTemplateViewDistribution() async throws {
        let (_, profile, _container) = try createTestContext()
        
        let pages = ATSCVTemplateView.distribute(profile: profile)
        #expect(!pages.isEmpty)
        #expect(pages.first?.hasHeader == true)
    }

    @Test("Mengompilasi CVDocument menjadi HTML menggunakan CVHTMLCompiler")
    func testCVHTMLCompilerCompile() async throws {
        let (_, profile, _container) = try createTestContext()
        let document = CVDocument(profile: profile)
        
        let html = CVHTMLCompiler.compile(document: document)
        #expect(html.contains("<!DOCTYPE html>"))
        #expect(html.contains(profile.name))
        #expect(html.contains(profile.email))
    }
}
