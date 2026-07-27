//
//  CVParsingViewModelTests.swift
//  Costume Tests
//
//  Created by William Constantine Jioe on 24/07/26.
//

import XCTest
import SwiftData
@testable import Costume

final class CVParsingViewModelTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var mainContext: ModelContext!
    var childContext: ModelContext!
    var viewModel: CVParsingViewModel!

    @MainActor
    override func setUpWithError() throws {
        // Set up an in-memory SwiftData container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: Profile.self, Experience.self, Education.self,
                Project.self, Certification.self, Award.self,
                Skill.self, Language.self,
            configurations: config
        )
        
        mainContext = modelContainer.mainContext
        
        // Setup child context sandboxing
        childContext = ModelContext(modelContainer)
        childContext.autosaveEnabled = false
        
        viewModel = CVParsingViewModel()
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        mainContext = nil
        childContext = nil
        viewModel = nil
    }

    @MainActor
    func testCVParsingPipeline() async throws {
        // 1. Arrange: Create Master Profile in mainContext
        let masterProfile = Profile(name: "", email: "", location: "", phone: "")
        mainContext.insert(masterProfile)
        try mainContext.save()

        // Fetch sandboxed profile in childContext using the master persistentModelID
        let profileID = masterProfile.persistentModelID
        guard let sandboxedProfile = childContext.model(for: profileID) as? Profile else {
            XCTFail("Failed to resolve sandboxed profile in childContext.")
            return
        }

        // 2. Locate test PDF file in test bundle
        guard let samplePDFURL = Bundle(for: type(of: self)).url(forResource: "SampleCV", withExtension: "pdf") else {
            XCTFail("SampleCV.pdf not found in test bundle. Please add a test PDF.")
            return
        }

        // 3. Act: Run processing function with all 5 required arguments
        await viewModel.processDroppedCV(
            fileURL: samplePDFURL,
            sandboxedProfile: sandboxedProfile,
            masterProfile: masterProfile,
            childContext: childContext,
            mainContext: mainContext
        )

        // 4. Assert: Check if ViewModel succeeded and populated SwiftData
        XCTAssertNil(viewModel.errorMessage, "Expected no error, got: \(viewModel.errorMessage ?? "")")
        XCTAssertFalse(viewModel.isProcessing, "ViewModel should finish processing")

        // Verify basic fields parsed on masterProfile
        XCTAssertFalse(masterProfile.name.isEmpty, "Profile name should not be empty")
        
        // Verify relationships populated
        XCTAssertFalse(masterProfile.experiences.isEmpty, "Experiences should be populated")
        if let firstExp = masterProfile.experiences.first {
            XCTAssertFalse(firstExp.descriptionText.isEmpty, "Experience should have bullet points")
        }
        
        // Print output to Xcode console
        print("--- PARSED PROFILE RESULT ---")
        print("Name: \(masterProfile.name)")
        print("Email: \(masterProfile.email)")
        print("Summary: \(masterProfile.summary)")
        print("LinkedIn: \(masterProfile.linkedin?.absoluteString ?? "None")")
        print("Experiences Count: \(masterProfile.experiences.count)")
        print("Skills: \(masterProfile.skills.map { $0.name })")
        print("Educations: \(masterProfile.educations.count)")
    }
}
