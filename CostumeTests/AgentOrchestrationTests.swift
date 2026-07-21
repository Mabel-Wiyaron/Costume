//
//  AgentOrchestrationTests.swift
//  CostumeTests
//

import Testing
import Foundation
import FoundationModels
@testable import Costume

// 1. Mock implementation of LanguageModelProtocol
class MockLanguageModel: LanguageModelProtocol {
    var mockGenerable: Any?
    var shouldFailWithContextLimit = false
    
    func invoke(for message: String) async throws -> String {
        if shouldFailWithContextLimit {
            throw LanguageModelSession.GenerationError.exceededContextWindowSize
        }
        return "mock response"
    }
    
    func generate<Content>(content type: Content.Type, for message: String) async throws -> Content where Content: Generable {
        if shouldFailWithContextLimit {
            throw LanguageModelSession.GenerationError.exceededContextWindowSize
        }
        
        if let mock = mockGenerable as? Content {
            return mock
        }
        
        throw NSError(
            domain: "MockLanguageModel",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "No mock provided for \(type)"]
        )
    }
    
    func reset() {}
}

@MainActor
struct AgentOrchestrationTests {
    
    @Test("JobDescriptionAgentService returns correct structure when language model succeeds")
    func testJobDescriptionAgentServiceSuccess() async throws {
        // Arrange
        var service = JobDescriptionAgentService()
        let mockModel = MockLanguageModel()
        
        let expectedResult = JobDescriptionGenerable(
            role: "iOS Engineer",
            company: "Costume Inc",
            abstract: "Build great apps",
            responsibilities: ["Develop features"],
            requirements: ["SwiftUI"],
            keywords: ["Swift", "SwiftUI"]
        )
        mockModel.mockGenerable = expectedResult
        service.languageModel = mockModel
        
        // Act
        let result = try await service.invoke(for: "Dummy job description")
        
        // Assert
        #expect(result.role == "iOS Engineer")
        #expect(result.company == "Costume Inc")
        #expect(result.keywords == ["Swift", "SwiftUI"])
    }
    
    @Test("JobDescriptionAgentService throws jobDescriptionTooLong when context limit exceeded")
    func testJobDescriptionAgentServiceContextLimit() async throws {
        // Arrange
        var service = JobDescriptionAgentService()
        let mockModel = MockLanguageModel()
        mockModel.shouldFailWithContextLimit = true
        service.languageModel = mockModel
        
        // Act & Assert
        await #expect(throws: JobDescriptionAgentError.jobDescriptionTooLong) {
            try await service.invoke(for: "Very long job description")
        }
    }
    
    @Test("SectionsAgentService returns correct sections when language model succeeds")
    func testSectionsAgentServiceSuccess() async throws {
        // Arrange
        var service = SectionsAgentService()
        let mockModel = MockLanguageModel()
        
        let expectedSections = SectionsGenerable(
            sections: [
                SectionGenerable(
                    title: .experience,
                    description: "Experience tailoring summary",
                    keywords: ["Swift", "iOS"]
                )
            ]
        )
        mockModel.mockGenerable = expectedSections
        service.languageModel = mockModel
        
        // Act
        let result = try await service.invoke(for: "Dummy section request")
        
        // Assert
        #expect(result.sections.count == 1)
        #expect(result.sections.first?.title == .experience)
        #expect(result.sections.first?.description == "Experience tailoring summary")
    }
}
