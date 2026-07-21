//
//  TestHelpers.swift
//  CostumeTests
//

import SwiftData
import Foundation
@testable import Costume

@MainActor
enum TestHelpers {
    // Helper function to assemble a clean in-memory ModelContainer for each test case
    static func createTestContext() throws -> (context: ModelContext, profile: Profile, container: ModelContainer) {
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
}
