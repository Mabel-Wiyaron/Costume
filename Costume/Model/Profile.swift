//
//  Profile.swift
//  Costume
//
//  Created by William Constantine Jioe on 10/07/26.
//

import Foundation
import SwiftData

@Model
final class Profile {
    var name: String
    var email: String
    var location: String
    var phone: String

    var linkedin: URL?
    var website: URL?
    
    @Relationship(deleteRule: .cascade)
    var links: [ProfileLink]

    var summary: String?

    @Relationship(deleteRule: .cascade)
    var experiences: [Experience]

    @Relationship(deleteRule: .cascade)
    var educations: [Education]

    @Relationship(deleteRule: .cascade)
    var certifications: [Certification]

    @Relationship(deleteRule: .cascade)
    var projects: [Project]

    @Relationship(deleteRule: .cascade)
    var awards: [Award]

    @Relationship(deleteRule: .cascade)
    var languages: [Language]

    @Relationship(deleteRule: .cascade)
    var skills: [Skill]
    
    @Relationship(deleteRule: .cascade)
    var jobDescription: JobDescription?

    init(
        name: String,
        email: String,
        location: String,
        phone: String,
        linkedin: URL? = nil,
        website: URL? = nil,
        summary: String? = nil,
        profileLinks: [ProfileLink] = [],
        experiences: [Experience] = [],
        educations: [Education] = [],
        certifications: [Certification] = [],
        projects: [Project] = [],
        awards: [Award] = [],
        languages: [Language] = [],
        skills: [Skill] = [],
        jobDescription: JobDescription? = nil
    ) {
        self.name = name
        self.email = email
        self.location = location
        self.phone = phone
        self.linkedin = linkedin
        self.website = website
        self.summary = summary
        self.links = profileLinks
        self.experiences = experiences
        self.educations = educations
        self.certifications = certifications
        self.projects = projects
        self.awards = awards
        self.languages = languages
        self.skills = skills
        self.jobDescription = jobDescription
    }
}
