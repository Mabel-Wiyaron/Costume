//
//  ProfileSection.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import Foundation

enum ProfileSection: String, CaseIterable, Identifiable {
    case uploadCV
    case personalInfo
    case education
    case experience
    case skills
    case project
    case certification
    case awards

    var id: String { rawValue }

    var title: String {
        switch self {
        case .uploadCV:return "Upload CV"
        case .personalInfo: return "Personal Info*"
        case .education: return "Education*"
        case .experience: return "Experience*"
        case .skills: return "Skills"
        case .project: return "Project"
        case .certification: return "Certification"
        case .awards: return "Awards"
        }
    }

    var iconName: String {
        switch self {
        case .uploadCV: return "square.and.arrow.up"
        case .personalInfo: return "doc.text"
        case .education: return "graduationcap"
        case .experience: return "briefcase"
        case .skills: return "clock"
        case .project: return "folder"
        case .certification: return "medal"
        case .awards: return "trophy"
        }
    }
}
