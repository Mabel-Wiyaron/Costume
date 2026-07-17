//
//  Certification.swift
//  Costume
//
//  Created by William Constantine Jioe on 10/07/26.
//


import Foundation
import SwiftData

@Model
final class Certification {
    var name: String
    var issuer: String
    var issueDate: Date
    var expirationDate: Date?
    var credentialID: String
    var credentialURL: URL?

    @Relationship
    var skills: [Skill]

    init(
        name: String,
        issuer: String,
        issueDate: Date,
        expirationDate: Date? = nil,
        credentialID: String,
        credentialURL: URL? = nil,
        skills: [Skill] = []
    ) {
        self.name = name
        self.issuer = issuer
        self.issueDate = issueDate
        self.expirationDate = expirationDate
        self.credentialID = credentialID
        self.credentialURL = credentialURL
        self.skills = skills
    }
}
