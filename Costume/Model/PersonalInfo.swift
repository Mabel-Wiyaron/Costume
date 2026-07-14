// MARK: - PersonalInfo.swift

import Foundation

struct PersonalInfo: Identifiable, Codable {
    let id: UUID
    var name: String
    var contact: String
    var email: String
    var linkedIn: String
    var personalWebsite: String
    var location: String
    var github: String
    var aboutMe: String

    init(
        id: UUID = UUID(),
        name: String = "",
        contact: String = "",
        email: String = "",
        linkedIn: String = "",
        personalWebsite: String = "",
        location: String = "",
        github: String = "",
        aboutMe: String = ""
    ) {
        self.id = id
        self.name = name
        self.contact = contact
        self.email = email
        self.linkedIn = linkedIn
        self.personalWebsite = personalWebsite
        self.location = location
        self.github = github
        self.aboutMe = aboutMe
    }
}