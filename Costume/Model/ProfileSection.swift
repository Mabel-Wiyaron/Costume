//
//  ProfileSection.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import Foundation

enum ProfileSection: String, CaseIterable, Identifiable {
    case personalInfo
    case education
    case skills
    case experience
    case project
    case certification
    case awards

    var id: String { rawValue }

    var title: String {
        switch self {
        case .personalInfo: return "Personal Info"
        case .education: return "Education"
        case .skills: return "Skills"
        case .experience: return "Experience"
        case .project: return "Project"
        case .certification: return "Certification"
        case .awards: return "Awards"
        }
    }

    var iconName: String {
        switch self {
        case .personalInfo: return "doc.text"
        case .education: return "graduationcap"
        case .skills: return "clock"
        case .experience: return "briefcase"
        case .project: return "folder"
        case .certification: return "medal"
        case .awards: return "trophy"
        }
    }
}
