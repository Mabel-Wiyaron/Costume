//
//  Award.swift
//  Costume
//
//  Created by William Constantine Jioe on 10/07/26.
//


import Foundation
import SwiftData

@Model
final class Award {
    var title: String
    var issuer: String
    var issueDate: Date

    init(
        title: String,
        issuer: String,
        issueDate: Date,
    ) {
        self.title = title
        self.issuer = issuer
        self.issueDate = issueDate
    }
}
