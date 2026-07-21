//
//  CVDocument.swift
//  Costume
//
//  Created by William Constantine Jioe on 14/07/26.
//

import Foundation
import Observation

@Observable
final class CVDocument {
    var profile: Profile

    var name: String {
        get { profile.name }
        set { profile.name = newValue }
    }
    var email: String {
        get { profile.email }
        set { profile.email = newValue }
    }
    var phone: String {
        get { profile.phone }
        set { profile.phone = newValue }
    }
    var location: String {
        get { profile.location }
        set { profile.location = newValue }
    }
    var linkedin: URL? {
        get { profile.linkedin }
        set { profile.linkedin = newValue }
    }
    var website: URL? {
        get { profile.website }
        set { profile.website = newValue }
    }
    var links: [ProfileLink] {
        get { profile.links }
        set { profile.links = newValue }
    }

    var summary: String? {
        get { profile.summary }
        set { profile.summary = newValue }
    }

    var experiences: [Experience] {
        get { profile.experiences }
        set { profile.experiences = newValue }
    }

    var educations: [Education] {
        get { profile.educations }
        set { profile.educations = newValue }
    }

    var skills: [Skill] {
        get { profile.skills }
        set { profile.skills = newValue }
    }

    var certifications: [Certification] {
        get { profile.certifications }
        set { profile.certifications = newValue }
    }

    var projects: [Project] {
        get { profile.projects }
        set { profile.projects = newValue }
    }

    var awards: [Award] {
        get { profile.awards }
        set { profile.awards = newValue }
    }

//    var languages: [Language] {
//        get { profile.languages }
//        set { profile.languages = newValue }
//    }

    init(profile: Profile) {
        self.profile = profile
    }
}
