//
//  Experience.swift
//  Costume
//
//  Created by William Constantine Jioe on 10/07/26.
//

import Foundation
import SwiftData

@Model
final class Experience {
    var role: String
    var company: String
    var location: String
    var startDate: Date
    var endDate: Date?
    
    var descriptionText: [String]

    @Relationship
    var skills: [Skill] = []

    init(
        role: String,
        company: String,
        location: String,
        startDate: Date,
        endDate: Date? = nil,
        descriptionText: [String] = [],
        skills: [Skill] = []
    ) {
        self.role = role
        self.company = company
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.descriptionText = descriptionText
        self.skills = skills
    }
}
