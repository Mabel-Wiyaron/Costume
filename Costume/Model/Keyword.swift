//
//  Keyword.swift
//  Costume
//
//  Created by William Constantine Jioe on 14/07/26.
//

import Foundation
import SwiftData

enum KeywordStatus: String, Codable {
    case included   // Already present in the CV content
    case match      // Matches profile data but not yet reflected in CV wording
    case missing    // Relevant to the job but not found in profile or CV
}

@Model
final class Keyword {
    var name: String
    var status: KeywordStatus

    // Relationship back to the parent job description
    var jobDescription: JobDescription?

    init(name: String, status: KeywordStatus = .missing) {
        self.name = name
        self.status = status
    }
}
