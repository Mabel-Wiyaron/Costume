//
//  Project.swift
//  Costume
//
//  Created by William Constantine Jioe on 10/07/26.
//

import Foundation
import SwiftData

@Model
final class Project {
    var role: String
    var name: String
    var startDate: Date
    var website: URL?
    var descriptionText: [String]

    @Relationship
    var skills: [Skill]

    init(
        role: String,
        name: String,
        startDate: Date,
        website: URL? = nil,
        descriptionText: [String] = [],
        skills: [Skill] = []
    ) {
        self.role = role
        self.name = name
        self.startDate = startDate
        self.website = website
        self.descriptionText = descriptionText
        self.skills = skills
    }
}
