//
//  JobDescription.swift
//  Costume
//
//  Created by William Constantine Jioe on 13/07/26.
//

import Foundation
import SwiftData

@Model
final class JobDescription {
    var content: String
    var role: String?
    var company: String?
    var extractedData: Data // Keeps your original JSON/Binary backup

    @Relationship(deleteRule: .cascade, inverse: \Keyword.jobDescription)
    var keywords: [Keyword] = []

    var profile: Profile?

    var extractionStatus: String // e.g., "idle", "processing", "completed", "failed"
    var createdAt: Date
    var updatedAt: Date

    var characterCount: Int {
        content.count
    }

    init(
        content: String,
        role: String? = nil,
        company: String? = nil,
        extractedData: Data = Data(),
        extractionStatus: String = "idle",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        keywords: [Keyword] = []
    ) {
        self.content = content
        self.role = role
        self.company = company
        self.extractedData = extractedData
        self.extractionStatus = extractionStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.keywords = keywords
    }
}
