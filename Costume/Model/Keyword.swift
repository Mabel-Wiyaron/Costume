//
//  Keyword.swift
//  Costume
//
//  Created by William Constantine Jioe on 14/07/26.
//

import Foundation
import SwiftData

@Model
final class Keyword {
    var name: String
    var isMatched: Bool
    
    // Relationship back to the parent job description
    var jobDescription: JobDescription?

    init(name: String, isMatched: Bool = false) {
        self.name = name
        self.isMatched = isMatched
    }
}
