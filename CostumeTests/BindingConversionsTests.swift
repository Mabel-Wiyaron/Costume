//
//  BindingConversionsTests.swift
//  CostumeTests
//

import Testing
import SwiftUI
import Foundation
@testable import Costume

@MainActor
struct BindingConversionsTests {
    
    @Test("URL? stringValue binding conversion tests")
    func testURLBindingConversion() async throws {
        var testURL: URL? = URL(string: "https://apple.com")
        
        let binding = Binding<URL?>(
            get: { testURL },
            set: { testURL = $0 }
        )
        
        let stringBinding = binding.stringValue
        
        // Test getter
        #expect(stringBinding.wrappedValue == "https://apple.com")
        
        // Test setting to empty string (should set URL to nil)
        stringBinding.wrappedValue = ""
        #expect(testURL == nil)
        
        // Test setting to a valid URL string
        stringBinding.wrappedValue = "https://github.com"
        #expect(testURL == URL(string: "https://github.com"))
    }
    
    @Test("String? stringValue binding conversion tests")
    func testOptionalStringBindingConversion() async throws {
        var testString: String? = "Hello World"
        
        let binding = Binding<String?>(
            get: { testString },
            set: { testString = $0 }
        )
        
        let stringBinding = binding.stringValue
        
        // Test getter
        #expect(stringBinding.wrappedValue == "Hello World")
        
        // Test setting to empty string (should set to nil)
        stringBinding.wrappedValue = ""
        #expect(testString == nil)
        
        // Test setting to a non-empty string
        stringBinding.wrappedValue = "New Value"
        #expect(testString == "New Value")
    }
    
    @Test("[ProfileLink] urlString(forPlatform:) binding conversion tests")
    func testProfileLinkArrayBindingConversion() async throws {
        var links: [ProfileLink] = [
            ProfileLink(platform: .github, url: URL(string: "https://github.com/test")!)
        ]
        
        let binding = Binding<[ProfileLink]>(
            get: { links },
            set: { links = $0 }
        )
        
        // Test getting github URL
        let githubBinding = binding.urlString(forPlatform: .github)
        #expect(githubBinding.wrappedValue == "https://github.com/test")
        
        // Test getting non-existent platform URL
        let figmaBinding = binding.urlString(forPlatform: .figma)
        #expect(figmaBinding.wrappedValue == "")
        
        // Test setting figma URL (should append a new ProfileLink)
        figmaBinding.wrappedValue = "https://figma.com/test"
        #expect(links.count == 2)
        #expect(links.first(where: { $0.platform == .figma })?.url == URL(string: "https://figma.com/test"))
        
        // Test updating existing github URL
        githubBinding.wrappedValue = "https://github.com/updated"
        #expect(links.first(where: { $0.platform == .github })?.url == URL(string: "https://github.com/updated"))
        
        // Test setting existing platform URL to empty string (should remove it)
        githubBinding.wrappedValue = ""
        #expect(links.count == 1)
        #expect(links.first(where: { $0.platform == .github }) == nil)
    }
}
