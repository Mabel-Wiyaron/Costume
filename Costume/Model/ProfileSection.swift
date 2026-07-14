// MARK: - ProfileSection.swift

import Foundation

enum ProfileSection: String, CaseIterable, Identifiable {
    case personalInfo
    case education
    case skills
    case experience
    case project
    case certificationAndAwards
    case volunteers

    var id: String { rawValue }

    var title: String {
        switch self {
        case .personalInfo: return "Personal Info"
        case .education: return "Education"
        case .skills: return "Skills"
        case .experience: return "Experience"
        case .project: return "Project"
        case .certificationAndAwards: return "Certification & Awards"
        case .volunteers: return "Volunteers"
        }
    }

    var iconName: String {
        switch self {
        case .personalInfo: return "doc.text"
        case .education: return "graduationcap"
        case .skills: return "clock"
        case .experience: return "briefcase"
        case .project: return "folder"
        case .certificationAndAwards: return "medal"
        case .volunteers: return "person.2"
        }
    }
}