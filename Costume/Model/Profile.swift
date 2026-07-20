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

    /// Performs a deep copy of the profile and all its related SwiftData relationship models,
    /// so the master profile remains unaffected during job description tailoring.
    func duplicate() -> Profile {
        let copy = Profile(
            name: self.name,
            email: self.email,
            location: self.location,
            phone: self.phone,
            linkedin: self.linkedin,
            website: self.website,
            summary: self.summary
        )
        
        copy.links = self.links.map { ProfileLink(platform: $0.platform, url: $0.url) }
        copy.experiences = self.experiences.map { exp in
            Experience(
                role: exp.role,
                employmentType: exp.employmentType,
                company: exp.company,
                location: exp.location,
                startDate: exp.startDate,
                endDate: exp.endDate,
                descriptionText: exp.descriptionText
            )
        }
        copy.educations = self.educations.map { edu in
            Education(
                school: edu.school,
                degree: edu.degree,
                fieldOfStudy: edu.fieldOfStudy,
                startDate: edu.startDate,
                endDate: edu.endDate,
                grade: edu.grade
            )
        }
        copy.certifications = self.certifications.map { cert in
            Certification(
                name: cert.name,
                issuer: cert.issuer,
                issueDate: cert.issueDate,
                expirationDate: cert.expirationDate,
                credentialID: cert.credentialID,
                credentialURL: cert.credentialURL
            )
        }
        copy.projects = self.projects.map { proj in
            Project(
                role: proj.role,
                name: proj.name,
                startDate: proj.startDate,
                endDate: proj.endDate,
                website: proj.website,
                descriptionText: proj.descriptionText
            )
        }
        copy.awards = self.awards.map { aw in
            Award(title: aw.title, issuer: aw.issuer, issueDate: aw.issueDate)
        }
        copy.languages = self.languages.map { lang in
            Language(name: lang.name, proficiency: lang.proficiency)
        }
        copy.skills = self.skills.map { sk in
            Skill(name: sk.name)
        }
        
        return copy
    }
}

