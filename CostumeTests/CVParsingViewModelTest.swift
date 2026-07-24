//
//  CVParsingViewModelTest.swift
//  Costume
//
//  Created by William Constantine Jioe on 24/07/26.
//

import XCTest
import SwiftData
@testable import Costume

final class CVParsingViewModelTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
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
        modelContext = modelContainer.mainContext
        viewModel = CVParsingViewModel()
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
        viewModel = nil
    }

    @MainActor
    func testCVParsingPipeline() async throws {
        // 1. Arrange: Create a fresh Master Profile
        let masterProfile = Profile(name: "", email: "", location: "", phone: "")
        modelContext.insert(masterProfile)
        try modelContext.save()

        // 2. Locate your test PDF file in the test bundle
        guard let samplePDFURL = Bundle(for: type(of: self)).url(forResource: "SampleCV", withExtension: "pdf") else {
            XCTFail("SampleCV.pdf not found in test bundle. Please add a test PDF.")
            return
        }

        // 3. Act: Run the processing function
        await viewModel.processDroppedCV(
            fileURL: samplePDFURL,
            masterProfile: masterProfile,
            modelContext: modelContext
        )

        // 4. Assert: Check if the ViewModel succeeded and populated SwiftData
        XCTAssertNil(viewModel.errorMessage, "Expected no error, got: \(viewModel.errorMessage ?? "")")
        XCTAssertFalse(viewModel.isProcessing, "ViewModel should finish processing")

        // Check if basic fields were parsed
        XCTAssertFalse(masterProfile.name.isEmpty, "Profile name should not be empty")
        
        // Check if arrays were populated
        XCTAssertFalse(masterProfile.experiences.isEmpty, "Experiences should be populated")
        if let firstExp = masterProfile.experiences.first {
            XCTAssertFalse(firstExp.descriptionText.isEmpty, "Experience should have bullet points")
        }
        
        // Print output to Xcode console for quick inspection
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
