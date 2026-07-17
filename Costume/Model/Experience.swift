//
//  Experience.swift
//  Costume
//
//  Created by William Constantine Jioe on 10/07/26.
//

import Foundation
import SwiftData

enum EmploymentType: String, Codable, CaseIterable, Identifiable {
    case fullTime
    case partTime
    case freelance
    case selfEmployed
    case internship
    case contracted
    case volunteer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fullTime: return "Full-time"
        case .partTime: return "Part-time"
        case .freelance: return "Freelance"
        case .selfEmployed: return "Self-employed"
        case .internship: return "Internship"
        case .contracted: return "Contracted"
        case .volunteer: return "Volunteer"
        }
    }
}

@Model
final class Experience {
    var role: String
    var employmentType: EmploymentType
    var company: String
    var location: String
    var startDate: Date
    var endDate: Date?
    
    var descriptionText: [String]

    @Relationship
    var skills: [Skill] = []

    init(
        role: String,
        employmentType: EmploymentType,
        company: String,
        location: String,
        startDate: Date,
        endDate: Date? = nil,
        descriptionText: [String] = [],
        skills: [Skill] = []
    ) {
        self.role = role
        self.employmentType = employmentType
        self.company = company
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.descriptionText = descriptionText
        self.skills = skills
    }
}
