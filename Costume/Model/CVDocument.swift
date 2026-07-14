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
    // The single source of truth for the entire CV editor session
    var profile: Profile
    
    // Convenient computed properties to easily access individual sections in the UI
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
    
    var languages: [Language] {
        get { profile.languages }
        set { profile.languages = newValue }
    }
    
    init(profile: Profile) {
        self.profile = profile
    }
}
