//
//  Education.swift
//  Costume
//
//  Created by William Constantine Jioe on 10/07/26.
//

import Foundation
import SwiftData

@Model
final class Education {
    var school: String
    var degree: String
    var fieldOfStudy: String
    var startDate: Date
    var endDate: Date?
    var grade: String?

    @Relationship
    var skills: [Skill]

    init(
        school: String,
        degree: String,
        fieldOfStudy: String,
        startDate: Date,
        endDate: Date? = nil,
        grade: String? = nil,
        skills: [Skill] = []
    ) {
        self.school = school
        self.degree = degree
        self.fieldOfStudy = fieldOfStudy
        self.startDate = startDate
        self.endDate = endDate
        self.grade = grade
        self.skills = skills
    }
}
